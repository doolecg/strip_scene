# Strip Scene

A 3ds Max tool that turns a dressed scene into a clean, plain copy: no materials, no textures, no cameras, no lights, no scatters. Every object gets one neutral V-Ray material, and the result is saved beside the original as a separate file.

It's handy for sending geometry to someone without your textures and libraries, for clay renders, or for slimming down a heavy scene before you rebuild its look.

Works in 3ds Max 2024 and 2026 with V-Ray (CPU or GPU).

## What it does

Open the tool and you get a window of tick boxes, all on by default, and a Strip Scene button. In order, it:

| Step | What happens |
| --- | --- |
| Backup | Saves a copy of the scene as it is now, unsaved changes included, to `Backup\<scene>_Backup_<date>_<time>.max`. If that save fails, the run stops before anything is changed. |
| Cameras | Deletes every camera, targets included. |
| Lights | Deletes every light, V-Ray lights and dome HDRIs included. |
| Forest Pack | Deletes every Forest Pack object, plus the hidden `forest_templates` layer where Forest keeps the library items it imports for scattering. |
| RailClone | Deletes every RailClone object. |
| Materials | Takes the material off every object, hidden and frozen ones included. |
| VRayMtl | Puts one plain `Stripped_VRayMtl` on all geometry. |
| Editors | Resets the Compact material editor slots, closes Slate views and clears the environment map, so old bitmaps aren't kept in the file. |
| Render settings | Resets V-Ray to its defaults. A V-Ray GPU scene stays on GPU. Any other renderer is switched to V-Ray. |
| Save | Saves the result as `Stripped\<scene>_Stripped.max`. You're then working in that copy, so Ctrl+S can't overwrite your original. |

All the folders are made next to the original scene:

```text
Projects\House\
├── House.max                                  your original, never touched
├── Backup\House_Backup_2026-11-11_1432.max
├── Stripped\House_Stripped.max
└── Logs\House_StripLog_2026-11-11_1432.txt
```

## It never deletes your files

Everything it removes is removed from the open scene only. Texture files, Forest Pack and RailClone libraries, proxies and your original `.max` are never deleted or written to.

The only files it overwrites are its own output: running it again on the same scene replaces the earlier `_Stripped.max`, and two runs in the same minute share a backup and log name.

## Logging and warnings

Every run is written to the MAXScript Listener (press F11, lines start `[Strip Scene]`) and to a text file in `Logs\`. The log lists the options used, every texture file the scene referenced, each object deleted by name, each material removed, and where the backup and stripped files went.

Anything worth a second look is marked `WARNING`, and the count shows in the final message:

- the backup or save option was unticked (it also asks before starting)
- objects from plugins that aren't installed, which are left alone
- XRef scenes, whose contents aren't changed
- materials or texture files still held by the scene after stripping
- the renderer was switched to V-Ray from something else
- the backup or stripped file failed to save

## Install

1. Drag `StripScene.mzp` into a 3ds Max viewport, or use Scripting > Run Script and pick it.
2. The Strip Scene window opens with a message saying it's installed.
3. To add a toolbar button: Customize > Customize User Interface > Toolbars, category **Doole's Tools**, then drag **Strip Scene** onto a toolbar.

Install once in each version of Max you use. To update, drop the new `.mzp` in the same way.

## Use

1. Open and save your scene (it needs a file location to build its folders).
2. Click the Strip Scene button.
3. Untick anything you want kept, then press **Strip Scene**.
4. Check the message for warnings, and the log if there are any.

## Limits

- Scatter sources you picked by hand from your own layers are kept, and they get the plain material.
- RailClone has no template layer that I know of, so only the RailClone objects themselves are removed.
- Textures used outside materials, such as by a Displace modifier, are left in place and listed as a warning.
- If you untick Save, the changes stay in your open original and can't be undone, so saving would overwrite it. Keep Backup ticked if you do this.

## Building from source

The package is built from three files:

| File | Purpose |
| --- | --- |
| `StripScene.mcr` | The tool itself (a macroscript with the window and all the steps) |
| `install.ms` | Copies the macroscript to your Max user macros folder and opens the tool |
| `mzp.run` | Tells Max what to run when the package is dropped in or run |

After changing any of them, rebuild the package:

```bash
./build.sh
```

This writes a fresh `StripScene.mzp` with Windows line endings.
