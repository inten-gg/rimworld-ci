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
- **Identity is derived from the repository name**, with `rimworld-` stripped and the
  rest dot-separated. `packageId` takes a `gg.inten.rimworld.` prefix in lowercase; the
  C# namespace and `AssemblyName` take `Inten.Rimworld.` in PascalCase.

  | | |
  |---|---|
  | repo | `rimworld-storyteller-enclave` |
  | `packageId` | `gg.inten.rimworld.storyteller.enclave` |
  | namespace / `AssemblyName` | `Inten.Rimworld.Storyteller.Enclave` |
  | Harmony id | `gg.inten.rimworld.storyteller.enclave` |

  The display `<name>` in About.xml is *not* prefixed. Never rename a `defName` or a
  translation key to match — those are what keep savegames loadable.

- **`<author>` is `INT`**, with individual contributors in parentheses where there are
  any: `INT (Helljumper, Codex)`. The group is the author; names in the parentheses are
  who worked on it.

  Where a mod is a port, fork or add-on, the upstream author follows an `Original`
  clause so no attribution is lost:

  | Situation | `<author>` |
  |---|---|
  | our own work | `INT (Helljumper)` |
  | port of someone's mod | `INT (Helljumper), Original Arisher` |
  | add-on patching another mod | `INT (Helljumper, Codex), Original kazepsi` |
  | fork of an already-continued mod | `INT, Original RamRod, Continued by Mlie` |

  Only credit an `Original` author you can point to evidence for — a NOTICE, a LICENSE
  copyright line, or the upstream About.xml. A wrong attribution in a published mod is
  worse than a missing one.
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

## Cross-repository dependencies

`mod-build.yml` takes a `compile` input. Leave it `true`. The one exception today is
`rimworld-enclave-territorial-administration`, whose csproj carries a `ProjectReference`
to `rimworld-storyteller-enclave` via a `../../../` sibling path. That resolves on a
developer machine where both repos are cloned side by side, and never on a runner, so
that repo gets XML validation without a compile check.

Setting `compile: false` buys green CI, not correctness — it is a gap, and the repo that
needs it should be fixed rather than left there. `rimworld-warfare-framework` shows the
in-org alternative for a *soft* dependency: a reflection bridge
(`EnclaveTellerReflection.IsPresent`) with no compile-time reference at all.
