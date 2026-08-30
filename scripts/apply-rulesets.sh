#!/usr/bin/env bash
# Apply the standard `main` ruleset to inten-gg repositories.
#
#   ./scripts/apply-rulesets.sh                  # every rimworld-* repo, plus .github
#   ./scripts/apply-rulesets.sh rimworld-ci      # just these
#
# Idempotent: creates the ruleset if absent, updates it in place if present.
#
# Repositories that GitHub refuses are reported and skipped rather than failing the run.
# On the free plan that is every private repo — rulesets there need a paid plan. Re-run
# this script after any plan change and the skipped repos get the same ruleset.
set -uo pipefail

ORG=inten-gg
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
WITH_CI="$HERE/rulesets/main.json"
WITHOUT_CI="$HERE/rulesets/main-no-ci.json"

# Repos with no workflow that runs on push or pull_request produce no check run, so
# requiring a status check there would block every merge forever.
no_ci_repo() { [[ "$1" == "rimworld-ci" || "$1" == ".github" ]]; }

if [ $# -gt 0 ]; then
  repos=("$@")
else
  mapfile -t repos < <(gh repo list "$ORG" --limit 200 --json name \
    --jq '.[] | select(.name | startswith("rimworld-")) | .name' | sort)
  repos+=(".github")
fi

applied=0; skipped=0; failed=0

for repo in "${repos[@]}"; do
  if no_ci_repo "$repo"; then payload="$WITHOUT_CI"; kind="no status check"
  else payload="$WITH_CI"; kind="with status check"; fi

  existing=$(gh api "/repos/$ORG/$repo/rulesets" --jq '.[] | select(.name=="main") | .id' 2>/dev/null)
  rc=$?

  if [ $rc -ne 0 ]; then
    reason=$(gh api "/repos/$ORG/$repo/rulesets" 2>&1 | grep -oiE 'upgrade to github[^"]*' | head -1)
    printf '  %-45s SKIP   %s\n' "$repo" "${reason:-cannot read rulesets}"
    skipped=$((skipped + 1)); continue
  fi

  if [ -n "$existing" ]; then
    verb="updated"
    out=$(gh api -X PUT "/repos/$ORG/$repo/rulesets/$existing" --input "$payload" 2>&1); rc=$?
  else
    verb="created"
    out=$(gh api -X POST "/repos/$ORG/$repo/rulesets" --input "$payload" 2>&1); rc=$?
  fi

  if [ $rc -eq 0 ]; then
    printf '  %-45s OK     %s, %s\n' "$repo" "$verb" "$kind"
    applied=$((applied + 1))
  else
    printf '  %-45s FAIL   %s\n' "$repo" "$(echo "$out" | head -1)"
    failed=$((failed + 1))
  fi
done

echo
echo "applied=$applied skipped=$skipped failed=$failed"
[ "$failed" -eq 0 ]
