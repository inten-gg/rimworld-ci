# inten-gg RimWorld mod standard

Every `rimworld-*` repository in this organisation follows the layout and CI contract
below. `rimworld-fallout-ncrlegion` is the reference implementation — when in doubt,
copy it.

## Repository layout

```
<repo>/
  .devcontainer/                    # identical across repos; local secrets in project.env (gitignored)
  .github/workflows/
    build.yml                       # caller stub -> inten-gg/.github mod-build.yml
    publish.yml                     # caller stub -> inten-gg/.github mod-publish.yml
  assets/                           # ships verbatim to the Workshop
    About/About.xml
    Defs/ Textures/ Languages/ Patches/ Sounds/
  src/<ModName>/<ModName>.csproj    # one project; content-only mods keep a stub csproj
  Directory.Build.props             # per-repo identity (AssemblyName, ModDevName, ...)
  Directory.Build.targets           # shared PackMod target — identical in every repo
  Directory.Packages.props          # shared package pins — identical in every repo
  <ModName>.slnx
  .gitignore .gitattributes
  LICENSE.txt README.md
```

Rules:

- **Flat asset layout.** `assets/Defs`, never `assets/1.6/Defs`. Introduce
  `LoadFolders.xml` and versioned subfolders only when a mod genuinely ships for two
  RimWorld versions at once.
- **`dist/` is build output.** Gitignored, never committed. Neither are `.dll`, `.pdb`,
  `.zip` or `About/PublishedFileId.txt`.
- **License file is `LICENSE.txt`.** `PackMod` copies it into `dist/`; a `.md` variant
  is silently skipped.
- **Namespace is `Rimworld.<Domain>.<Mod>`**, e.g. `Rimworld.Fallout.Vertibirds`.
- **Tags are plain semver** (`v1.2.3`), decoupled from the RimWorld version.
- **Commits follow Conventional Commits.** The release changelog is generated from
  them; anything else shows up as an empty release body.

## Build

```bash
dotnet build -c Release      # packs into dist/
dotnet build -c Debug        # same, but About.xml gets the (DEV) name and .dev packageId
```

`Directory.Build.targets` owns packaging. It copies `assets/**` and `LICENSE.txt` into
`dist/`, copies the built assembly into `dist/Assemblies/` for code mods only, and
rewrites `About.xml` for Debug builds so a dev copy can sit alongside the Workshop one
in the mod list.

Per-repo values live in `Directory.Build.props`:

| Property | Example |
|---|---|
| `AssemblyName` / `RootNamespace` | `Rimworld.Fallout.NCRLegion` |
| `ModDevName` | `Fallout: NCR and Legion Factions (DEV)` |
| `ModDevPackageId` | `helljumper.falloutncrlegion.dev` |

## CI

Both workflows are thin callers into the reusable workflows in `inten-gg/rimworld-ci`. Do not
inline CI logic into a mod repo — change it here and every repo picks it up.

```yaml
# .github/workflows/build.yml
name: Build
on:
  push: { branches: ["main"] }
  pull_request:
  workflow_dispatch:
jobs:
  build:
    uses: inten-gg/rimworld-ci/.github/workflows/mod-build.yml@v1
    with:
      solution: <ModName>.slnx
```

```yaml
# .github/workflows/publish.yml
name: Publish to Steam Workshop
on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Pure semver, e.g. 1.2.3'
        required: true
jobs:
  publish:
    uses: inten-gg/rimworld-ci/.github/workflows/mod-publish.yml@v1
    with:
      version: ${{ inputs.version }}
      solution: <ModName>.slnx
      published-file-id: ${{ vars.WORKSHOP_PUBLISHED_FILE_ID }}
    secrets: inherit
```

## Credentials

| Name | Kind | Scope |
|---|---|---|
| `STEAM_USERNAME` | secret | organisation, visible to `rimworld-*` |
| `STEAM_PASSWORD` | secret | organisation, visible to `rimworld-*` |
| `STEAM_SHARED_SECRET` | secret | organisation, visible to `rimworld-*` |
| `WORKSHOP_PUBLISHED_FILE_ID` | variable | per repository |

Per-repo `STEAM_*` secrets and the older `PUBLISHED_FILE_ID` name are retired. A
missing `WORKSHOP_PUBLISHED_FILE_ID` fails the publish run up front rather than
uploading against an empty ID.

## Releasing

1. Land your work on `main` with conventional commit messages.
2. Run the **Publish to Steam Workshop** workflow, entering the new version as pure
   semver (`1.2.3`, not `v1.2.3`).
3. The workflow packs the mod, generates the changelog, creates the `v1.2.3` GitHub
   release, and updates the existing Workshop item in place.
