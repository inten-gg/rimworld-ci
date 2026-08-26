# templates

Canonical copies of the files that must be **byte-identical** in every `rimworld-*`
repository. Copy from here; never hand-edit a repo's copy.

| Template | Destination |
|---|---|
| `Directory.Build.targets` | `<repo>/Directory.Build.targets` |
| `Directory.Packages.props` | `<repo>/Directory.Packages.props` |
| `gitignore` | `<repo>/.gitignore` |
| `workflows-build.yml` | `<repo>/.github/workflows/build.yml` |
| `workflows-publish.yml` | `<repo>/.github/workflows/publish.yml` |

The two workflow stubs carry a `<ModName>.slnx` placeholder — that solution name is the
only permitted difference. `Directory.Build.props` is deliberately **not** templated: it
holds each mod's identity (`AssemblyName`, `RootNamespace`, `ModDevName`,
`ModDevPackageId`).

Drift check across clones:

```bash
md5sum */Directory.Build.targets | sort | uniq -c -w32
md5sum */Directory.Packages.props | sort | uniq -c -w32
```
