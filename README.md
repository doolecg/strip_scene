<p align="center">
  <img src="docs/logo.svg" alt="Strip Scene" width="140">
</p>

<h1 align="center">Strip Scene</h1>

<p align="center">
  <strong>Turn a dressed 3ds Max scene into a clean, plain copy in one click.</strong><br>
  No materials, no textures, no cameras, no lights, no scatters. One neutral V-Ray material on everything.<br>
  Your original file is never touched, and every step is logged.
</p>

<p align="center">
  <a href="https://github.com/doolecg/strip_scene/actions/workflows/release.yml"><img alt="Release workflow" src="https://github.com/doolecg/strip_scene/actions/workflows/release.yml/badge.svg?branch=main"></a>
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-FF5B23?style=flat-square&labelColor=151515"></a>
  <img alt="3ds Max 2024 and 2026" src="https://img.shields.io/badge/3ds%20Max-2024%20%7C%202026-FF5B23?style=flat-square&labelColor=151515">
  <img alt="V-Ray CPU and GPU" src="https://img.shields.io/badge/V--Ray-CPU%20%7C%20GPU-FF5B23?style=flat-square&labelColor=151515">
  <img alt="Windows" src="https://img.shields.io/badge/Windows-FF5B23?style=flat-square&labelColor=151515">
</p>

<p align="center">
  <a href="#quick-start">Quick start</a> ·
  <a href="#why-strip-scene">Why Strip Scene</a> ·
  <a href="#what-it-does">What it does</a> ·
  <a href="#what-strip-scene-changes">What it changes</a> ·
  <a href="docs/GUIDE.md">Guide</a> ·
  <a href="#releasing">Releasing</a> ·
  <a href="https://github.com/doolecg/strip_scene/releases">Releases</a>
</p>

---

A finished scene carries a lot of baggage: hundreds of bitmaps, scatter libraries, lights, cameras and render settings tuned for one shot. **Strip Scene is a 3ds Max tool that saves a copy of the scene with all of that taken out**, leaving just the geometry under one plain V-Ray material. Use it to hand geometry to someone else, set up a clay render, or start a new look on a clean base.

## Quick start

1. Download `StripScene.mzp` from the latest [release](https://github.com/doolecg/strip_scene/releases).
2. Drag it into a 3ds Max viewport. The Strip Scene window opens.
3. Open a saved scene, press **Strip Scene**, and check the message at the end.

To add a toolbar button: Customize > Customize User Interface > Toolbars, category **Doole's Tools**, then drag **Strip Scene** onto a toolbar. The [guide](docs/GUIDE.md) covers each step in detail.

## Why Strip Scene

**Your original is safe.** It saves a dated backup before it starts and writes the result to a new file in a `Stripped` folder. Afterwards you are working in that copy, so Ctrl+S can't flatten the original.

**It gets the hidden stuff too.** Materials don't only live on objects. The material editors, Slate views, environment map and Forest Pack's hidden template layer all keep old bitmaps tied to the file, and Strip Scene clears them as well.

**You can see what it did.** Every object deleted, every material removed and every texture the scene used is written to the MAXScript Listener and a log file, with warnings for anything worth a second look.

**You choose the steps.** Every step is a tick box, all on by default.

## What it does

| Step | What happens |
| --- | --- |
| Backup | Saves a copy of the scene as it is now, unsaved changes included. If that save fails, the run stops before anything is changed. |
| Cameras | Deletes every camera, targets included. |
| Lights | Deletes every light, V-Ray lights and dome HDRIs included. |
| Forest Pack | Deletes every Forest Pack object, plus the hidden `forest_templates` layer where Forest keeps the library items it imports for scattering. |
| RailClone | Deletes every RailClone object. |
| Materials | Takes the material off every object, hidden and frozen ones included. |
| VRayMtl | Puts one plain `Stripped_VRayMtl` on all geometry. |
| Editors | Resets the Compact material editor slots, closes Slate views and clears the environment map. |
| Render settings | Resets V-Ray to its defaults. A V-Ray GPU scene stays on GPU; any other renderer is switched to V-Ray. |
| Save | Saves the result as `Stripped\<scene>_Stripped.max`. |

Everything it makes goes next to the original scene:

```text
Projects\House\
├── House.max                                  your original, never touched
├── Backup\House_Backup_2026-11-11_1432.max
├── Stripped\House_Stripped.max
└── Logs\House_StripLog_2026-11-11_1432.txt
```

## What Strip Scene changes

Read this before the first run. By using Strip Scene you agree to it making these changes.

- **The open scene, without undo.** Deleting objects and removing materials can't be undone with Ctrl+Z. The backup is your undo, which is why it is ticked by default.
- **Files it creates.** The `Backup`, `Stripped` and `Logs` folders next to your scene, and the files in them.
- **Files it overwrites.** Only its own output: a second run on the same scene replaces the earlier `_Stripped.max`, and two runs in the same minute share a backup and log name.
- **Files it never touches.** Your original `.max`, texture files, Forest Pack and RailClone libraries, proxies and XRef scenes are never deleted or written to.
- **The install.** Dropping in the `.mzp` copies `StripScene.mcr` to your 3ds Max user macros folder, replacing any older copy there. Nothing else is installed.

If you untick **Save**, the changes stay in your open original, and saving it would overwrite it. The tool asks before it starts in that case.

## Privacy

Strip Scene makes no network connections of any kind. It has no analytics, tracking or updates. Everything it reads and writes stays on your computer, next to your scene.

## Development

The package is built from three files:

| File | Purpose |
| --- | --- |
| `StripScene.mcr` | The tool: a macroscript with the window and every step |
| `install.ms` | Copies the macroscript to the user macros folder and opens the tool |
| `mzp.run` | Tells 3ds Max what to run when the package is dropped in or run |

Build the package locally (needs `bash` and `zip`):

```bash
./build.sh
```

This writes `StripScene.mzp` with Windows line endings. It is not committed: each release carries its own copy.

## Releasing

The [release workflow](.github/workflows/release.yml) builds the package on every push and pull request. On `main`, it releases any version that has no release yet.

1. Make the change on a branch.
2. Bump the number in `VERSION`, for example `1.1`.
3. Add a `# Strip Scene 1.1` section to the top of `RELEASE_NOTES.md`.
4. Open a pull request. Its checks attach a test `StripScene.mzp` you can try in Max first.
5. Merge it. GitHub makes the `v1.1` tag and the release with the notes and package attached.

A push that leaves `VERSION` alone builds the package and releases nothing.

## License

Strip Scene is released under the [MIT License](LICENSE). Copyright © 2026 doolecg.

3ds Max is a trademark of Autodesk. V-Ray is a trademark of Chaos. Forest Pack and RailClone are trademarks of iToo Software. Strip Scene is not made by, endorsed by or affiliated with any of them; their names are used only to say what it works with. Each is separate software under its own licence and terms.

## Disclaimer

This software is provided "as is", without warranty of any kind, as set out in the [LICENSE](LICENSE). To the extent permitted by law, the authors are not liable for any loss or damage from using it, including lost data, lost work or damage to scenes, files or projects. Nothing here limits liability that cannot be limited by law, such as for death or personal injury caused by negligence.

Back up your work before using it, and check the stripped scene and its log before you rely on it or send it to anyone. You use it at your own risk.

A stripped scene still contains its geometry. If that includes models from paid libraries, scans or a client's project, their licence terms and confidentiality still apply when you share it. You are responsible for having the right to pass it on.

Strip Scene has been run on real scenes, but not tested on every version of 3ds Max, V-Ray, Forest Pack or RailClone, or every plugin a scene might use. Objects from plugins it doesn't recognise are left alone and listed in the log as warnings.
