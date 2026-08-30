# rimworld-ci

Shared GitHub Actions workflows and the repository standard for the `rimworld-*` mod
repositories in this organisation.

- [`.github/workflows/mod-build.yml`](.github/workflows/mod-build.yml) — restore, build,
  validate XML, upload the packaged mod.
- [`.github/workflows/mod-publish.yml`](.github/workflows/mod-publish.yml) — pack, tag,
  release, deploy to the Steam Workshop.
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — repository layout, build conventions, required
  credentials and the release procedure.
- [`ATTRIBUTION.md`](ATTRIBUTION.md) — per-mod provenance and the evidence behind each
  `Original` author credit.
- [`RELEASE-READINESS.md`](RELEASE-READINESS.md) — what each mod still needs before it can
  publish.
- [`rulesets/`](rulesets/) + [`scripts/apply-rulesets.sh`](scripts/apply-rulesets.sh) —
  the `main` branch ruleset and the script that applies it.

Mod repositories consume these through thin caller stubs pinned to `@v1`:

```yaml
jobs:
  build:
    uses: inten-gg/rimworld-ci/.github/workflows/mod-build.yml@v1
    with:
      solution: <ModName>.slnx
```

Changing CI for every mod means changing it here and moving the `v1` tag.
