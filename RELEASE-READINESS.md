# Release readiness

What each mod still needs before `publish.yml` can run. Snapshot taken 2026-08-27 — the
credential columns go stale as soon as someone sets a value, so re-check with the commands
at the bottom rather than trusting this table blindly.

`publish.yml` needs two things per repo: the `WORKSHOP_PUBLISHED_FILE_ID` **variable**, and
the three `STEAM_*` **secrets**. A missing or empty file ID stops the run up front with a
clear error rather than deploying against an empty ID, which is what previously created
duplicate Workshop items.

## Status

| Repo | Workshop file ID | `STEAM_*` secrets | `main` protected | Can publish? |
|---|---|---|---|---|
| `rimworld-fallout-zetas` | `3774663099` | per-repo | no — private, free plan | **yes** — the only one proven end to end |
| `rimworld-fallout-ncrlegion` | `3777136023` | per-repo | no — private, free plan | **yes** |
| `rimworld-storyteller-enclave` | **missing** | per-repo (+ legacy `PUBLISHED_FILE_ID`) | no — private, free plan | no — see 1 below |
| `rimworld-fallout-powerarmor-expansion` | `0` (placeholder) | per-repo | no — private, free plan | no — needs a real ID |
| `rimworld-fallout-robots` | `0` (placeholder) | **none** | yes | no — needs both |
| `rimworld-fallout-vehicles` | **missing** | **none** | no — private, free plan | no — needs both |
| `rimworld-fallout-research` | **missing** | **none** | no — private, free plan | no — needs both |
| `rimworld-warfare-framework` | **missing** | **none** | no — private, free plan | no — needs both |
| `rimworld-enclave-territorial-administration` | **missing** | **none** | no — private, free plan | no — needs both, and it does not compile |
| `rimworld-fallout-icbmpatch` | **missing** | **none** | no — private, free plan | no — needs both, and CI cannot compile it |
| `rimworld-fallout-animals` | **missing** | **none** | no — private, free plan | **blocked on licensing**, not credentials |
| `rimworld-fallout-vertibirds` | `3764280645` | per-repo | no — private, free plan | **blocked on licensing** — credentials are otherwise ready |

Branch protection is unavailable on private repos on the free plan; see the branch
protection section of [CONTRIBUTING.md](CONTRIBUTING.md).

## What needs doing

1. **`storyteller-enclave` publish is currently broken.** Its workflow now reads the
   `WORKSHOP_PUBLISHED_FILE_ID` variable, but the ID still lives only in the legacy
   `PUBLISHED_FILE_ID` secret, which a reusable workflow's `with:` block cannot read.
   GitHub masks secret values in logs, so the ID has to come from whoever set it.
   It fails safely — the run stops with an error instead of publishing wrongly.
   ```bash
   gh variable set WORKSHOP_PUBLISHED_FILE_ID -R inten-gg/rimworld-storyteller-enclave --body <id>
   gh secret delete PUBLISHED_FILE_ID -R inten-gg/rimworld-storyteller-enclave
   ```

2. **Six repos have no Steam credentials at all.** Move to org-level secrets rather than
   copying them into each repo. Needs `admin:org`, which the current token lacks:
   ```bash
   gh auth refresh -h github.com -s admin:org
   REPOS=$(gh repo list inten-gg --limit 200 --json name --jq \
     '[.[]|select(.name|startswith("rimworld-"))|select(.name!="rimworld-ci")|.name]|join(",")')
   gh secret set STEAM_USERNAME      --org inten-gg --visibility selected --repos "$REPOS"
   gh secret set STEAM_PASSWORD      --org inten-gg --visibility selected --repos "$REPOS"
   gh secret set STEAM_SHARED_SECRET --org inten-gg --visibility selected --repos "$REPOS"
   ```
   Then delete the per-repo `STEAM_*` copies from `ncrlegion`, `zetas`, `powerarmor`,
   `vertibirds` and `storyteller-enclave`, so there is one place to rotate them.

3. **Eight repos need a real Workshop file ID.** `powerarmor` and `robots` hold the
   placeholder `0`; six have no variable at all. Any repo that has never been published
   needs its item created on Steam first, then:
   ```bash
   gh variable set WORKSHOP_PUBLISHED_FILE_ID -R inten-gg/<repo> --body <id>
   ```
   Do **not** reuse `robots`' committed `2347136687` — that was the upstream mod's item,
   which this org cannot publish to.

4. **Two repos would publish an empty mod.** `enclave-territorial-administration` and
   `icbmpatch` build with `compile: false`, so a release would ship no assembly. Fix the
   underlying problems first — ETA calls `StatePower`/`SpendStatePower`, which do not
   exist in EnclaveTeller; icbmpatch needs `IRBM.dll` from a Workshop subscription, or a
   reflection rewrite like `warfare-framework` uses.

5. **`animals` and `vertibirds` stay unreleased and private** until their licensing is
   ruled out. Their standardization PRs are deliberately left open. See open items 3 and 4
   in [ATTRIBUTION.md](ATTRIBUTION.md).

## Re-checking

```bash
for d in $(gh repo list inten-gg --limit 200 --json name --jq \
    '.[]|select(.name|startswith("rimworld-"))|select(.name!="rimworld-ci")|.name'); do
  v=$(gh api /repos/inten-gg/$d/actions/variables/WORKSHOP_PUBLISHED_FILE_ID --jq .value 2>/dev/null || echo MISSING)
  s=$(gh secret list -R inten-gg/$d --json name --jq '[.[].name]|sort|join(",")' 2>/dev/null)
  printf '%-45s %-12s %s\n' "$d" "$v" "${s:-none}"
done
```
