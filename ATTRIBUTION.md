# Attribution status

Who wrote what, and where each mod's content came from. Every `Original` credit below is
backed by a link — none is assigned on inference. If you are adding a mod or changing an
`<author>`, add or update its row here at the same time; the point of this file is that
nobody has to redo the research.

Format of the `<author>` field is defined in [CONTRIBUTING.md](CONTRIBUTING.md).

Last researched: 2026-08-26.

## Adapted

| Repo | Kind | `<author>` | Upstream | Evidence |
|---|---|---|---|---|
| `rimworld-fallout-ncrlegion` | port | `INT (Helljumper), Original Kurtus_Mob` | Fallout factions : NCR and Caesar's Legion (JDS) | [Workshop 2481321856](https://steamcommunity.com/sharedfiles/filedetails/?id=2481321856) — creator `kurtus_mob`; repo README says the same |
| `rimworld-fallout-vertibirds` | port | `INT (Helljumper), Original Kurtus_Mob` | Vertibird Transport - Standalone | [Workshop 1893953698](https://steamcommunity.com/sharedfiles/filedetails/?id=1893953698) — creator `kurtus_mob`; repo `NOTICE.md` agrees |
| `rimworld-fallout-animals` | port | `INT (Helljumper), Original Arisher` | Mojave Wasteland Creatures | [Workshop 2449930064](https://steamcommunity.com/sharedfiles/filedetails/?id=2449930064) — creator `Arisher`; repo `NOTICE.md` agrees |
| `rimworld-fallout-robots` | fork | `INT, Original RamRod & Arisher, Continued by Mlie` | Fallout Races: The Robots Pack | [Workshop 1907125167](https://steamcommunity.com/sharedfiles/filedetails/?id=1907125167) — `RamRod` is the marked author, `Arisher` is in the creators panel and credited for most textures; continued by Mlie at [emipa606/FalloutRacesTheRobotsPack](https://github.com/emipa606/FalloutRacesTheRobotsPack) (MIT, © 2020 Mlie) |
| `rimworld-fallout-icbmpatch` | add-on | `INT (Helljumper, Codex), Original kazepsi` | InterRim Ballistic Missile | [Workshop 3682304832](https://steamcommunity.com/sharedfiles/filedetails/?id=3682304832). The uploader shows as "Psionic Ψ Zephyr", but [IRBM Expand](https://steamcommunity.com/sharedfiles/filedetails/?id=3695591404) credits "kazepsi for allowing me to use the IRBM framework", and the packageId is `kazepsi.irbm`. Same person, Steam display name |
| `rimworld-fallout-powerarmor-expansion` | add-on | `INT, Original Kurtus_Mob` | The Brotherhood Compendium | [Workshop 2010861354](https://steamcommunity.com/sharedfiles/filedetails/?id=2010861354) — creator `kurtus_mob`. Identified from the defs: this repo parents onto `BC_PowerArmorBase` and gates on `BC_PowerArmor`, neither defined here, and `BC_` is that mod's prefix |

`Kurtus_Mob` is upstream of three of these — NCR/Legion, Vertibird Transport and The
Brotherhood Compendium. Steam spells the handle lowercase (`kurtus_mob`); we capitalise it.

## Original work — no `Original` credit

Searched READMEs, About descriptions, `NOTICE`/`LICENSE` files and git history. No source
mod appears for any of these.

| Repo | `<author>` | Note |
|---|---|---|
| `rimworld-fallout-vehicles` | `INT (Helljumper)` | The old author field read "Vehicle Framework adaptation by Helljumper", which looks like a fork credit. It is not: "adaptation" means adapted *to* Vehicle Framework. Vanilla Vehicles Expanded supplies construction parts as a dependency only |
| `rimworld-fallout-zetas` | `INT (Helljumper, Codex)` | "inspired by Fallout-style alien encounters", no source mod |
| `rimworld-fallout-research` | `INT (Helljumper)` | |
| `rimworld-enclave-territorial-administration` | `INT (Helljumper)` | Add-on to our own `rimworld-storyteller-enclave`, so no external credit |
| `rimworld-warfare-framework` | `INT` | Integrates with other mods purely through reflection bridges; no upstream content |
| `rimworld-storyteller-enclave` | `INT (VelvetDeveloper)` | See open item 1 |

## Open

| # | Repo | What is open | Next step |
|---|---|---|---|
| 1 | `storyteller-enclave` | `<author>` says `VelvetDeveloper`, `LICENSE.txt` says `Copyright (c) 2026 JunkO`. Not resolvable from outside the group | Decide which name is right, then align the other file to match |
| 2 | `powerarmor` | No `modDependencies` and no `loadAfter` for The Brotherhood Compendium, yet the defs use `ParentName="BC_PowerArmorBase"`. RimWorld cannot resolve the parent unless the base happens to load first | Decide which build to target — Kurtus_Mob's [original](https://steamcommunity.com/sharedfiles/filedetails/?id=2010861354) or [The Brotherhood Compendium 1.6](https://steamcommunity.com/sharedfiles/filedetails/?id=3571412768) by альтушка — then add the entry with that packageId |
| 3 | `powerarmor` | Description reads "Brotherhood Compendium - a content expansion for the Fallout Power Armor Expansion", but the defs say the thing being extended is The Brotherhood Compendium. The two halves look swapped | Reword the description |
| 4 | `animals` | `LICENSE.txt`: "Do not redistribute this repository, publish releases, or upload it to Steam Workshop/GitHub as public content unless you have the necessary permission from the original rights holder." The repo now has a working `publish.yml` | Either get and record permission from Arisher, or do not run that workflow |
| 5 | `vertibirds` | Source Workshop item 1893953698 was removed from Steam for violating content guidelines. This port redistributes its textures and sounds, per the repo's own `NOTICE.md` | Decide deliberately before publishing rather than at upload time |
| 6 | six repos | No `LICENSE.txt` in `ncrlegion`, `zetas`, `powerarmor`, `research`, `vehicles`, `warfare-framework`. Three of those are ports or add-ons, where this is more than housekeeping | Choose terms per repo; the shared packaging target ships `LICENSE.txt` automatically once it exists |
