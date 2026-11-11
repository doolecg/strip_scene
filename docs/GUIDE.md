# Strip Scene guide

How to install, use, update and remove Strip Scene, what each option does, and what to do when something looks wrong.

- [Install](#install)
- [Add a toolbar button](#add-a-toolbar-button)
- [Strip a scene](#strip-a-scene)
- [The options](#the-options)
- [After the run](#after-the-run)
- [Reading the log](#reading-the-log)
- [Warnings and what to do](#warnings-and-what-to-do)
- [Troubleshooting](#troubleshooting)
- [Update](#update)
- [Uninstall](#uninstall)

## Install

You need 3ds Max 2024 or 2026 with V-Ray loaded. Forest Pack and RailClone are optional.

1. Download `StripScene.mzp` from the latest [release](https://github.com/doolecg/strip_scene/releases).
2. Drag it from Explorer into any 3ds Max viewport.
3. The Strip Scene window opens and a message says it is installed.

If dragging does nothing, use **Scripting > Run Script**, set the file type to show `.mzp` files, and pick it.

Install once in each version of 3ds Max you use.

## Add a toolbar button

1. **Customize > Customize User Interface**, then the **Toolbars** tab.
2. Set **Category** to **Doole's Tools**.
3. Drag **Strip Scene** from the list onto any toolbar.

You can also put it on a menu or a keyboard shortcut from the same window.

## Strip a scene

1. Open the scene. It must have been saved at least once, because the tool builds its folders next to the file.
2. Click the **Strip Scene** button.
3. Untick any steps you want to skip. The [options](#the-options) are explained below.
4. Press **Strip Scene**.
5. Read the message at the end. It shows where the backup, stripped scene and log went, and how many warnings there were.

If you untick **Save a dated backup first** or **Save as _Stripped in a Stripped folder**, the tool tells you what that means and asks before it starts.

## The options

All of them are ticked by default.

| Option | What it does | Untick it when |
| --- | --- | --- |
| Save a dated backup first | Saves the scene as it is now, unsaved changes included, to `Backup\<scene>_Backup_<date>_<time>.max`. If this fails, the run stops. | Never, unless you have just saved your own backup. |
| Delete all cameras | Deletes every camera and its target. | You want to keep your shot cameras. |
| Delete all lights | Deletes every light, including V-Ray lights, the sun and dome lights with their HDRIs. | You want a clay render under the existing lighting. |
| Delete Forest Pack objects and templates | Deletes every Forest Pack object and the hidden `forest_templates` layer. | You want to keep the scatters (they will get the plain material). |
| Delete RailClone objects | Deletes every RailClone object. | You want to keep the RailClone geometry. |
| Remove all materials | Takes the material off every object. | You only want cameras, lights or scatters removed. |
| Apply a plain VRayMtl to all geometry | Puts one `Stripped_VRayMtl` on all geometry. | You want objects to show their wire colours instead. |
| Clear material editors and environment map | Resets the Compact editor slots, closes Slate views and clears the environment map. | Never, if the goal is no textures in the file. |
| Reset V-Ray render settings | Puts V-Ray back to its defaults. GPU scenes stay on GPU. | You want to keep your render settings. |
| Save as _Stripped in a Stripped folder | Saves the result to `Stripped\<scene>_Stripped.max` and switches you to that file. | Only if you know what you're doing: see the warning below. |

**If you untick Save,** the stripped scene stays open under your original file name, and nothing can be undone. Pressing Ctrl+S then overwrites your original. Keep the backup ticked if you do this.

## After the run

- You are now working in `Stripped\<scene>_Stripped.max`, not your original.
- Your original is unchanged on disk. Open it again from its usual folder when you need it.
- To get back to the scene exactly as it was before the run, open the newest file in `Backup\`.
- To check textures are gone, open **Asset Tracking** (Shift+T) in the stripped scene. Anything still listed is reported in the log too.

## Reading the log

Every run writes the same log in two places:

- **The MAXScript Listener.** Press F11. Each line starts with `[Strip Scene]`. It is cleared when 3ds Max closes.
- **A text file** in `Logs\<scene>_StripLog_<date>_<time>.txt`, next to your scene. This one is kept.

The log contains, in order:

1. The scene, the 3ds Max version and the object count.
2. Which options were ticked.
3. Every texture file the scene used before stripping.
4. Where the backup went.
5. Every camera, light, Forest Pack, RailClone and template object deleted, by name and type.
6. Every material removed, and how many objects had one.
7. How many objects got the plain material.
8. The editors, environment map and render settings that were reset.
9. Where the stripped scene went.
10. Any materials or textures still left, and the number of warnings.

Search the file for `WARNING` to jump to anything that needs a look.

## Warnings and what to do

| Warning | What it means | What to do |
| --- | --- | --- |
| No backup was saved | You unticked the backup. | Nothing, if you meant to. |
| Changes were left in the open scene | You unticked Save. | Use File > Save As to a new name before you press Ctrl+S. |
| Objects come from plugins that aren't installed | 3ds Max loaded them as placeholders, so the tool can't tell what they are and leaves them alone. | Open the scene on a machine with the plugin, or delete them by hand if you don't need them. |
| XRef scenes are attached | Objects inside XRef scenes are not changed. | Merge the XRefs first if they need stripping too. |
| BACKUP FAILED | The backup couldn't be saved, so nothing was changed. | Check the folder isn't read-only and the drive isn't full, then run again. |
| The forest_templates layer could not be removed | The layer was emptied, but 3ds Max kept it, usually because it is the current layer. | Set another layer as current and delete it by hand. It is empty, so it does no harm. |
| The renderer was switched to V-Ray | The scene used another renderer. | Nothing, unless you wanted to keep that renderer. |
| Materials are still held by the scene | Something other than an object still holds a material. | Check the listed names. Untick nothing next time, or remove them by hand. |
| Texture files are still referenced | Something outside materials still points at an image, such as a Displace modifier or a map in a modifier. | Check the listed files in Asset Tracking (Shift+T) to see what uses them. |
| STRIPPED SCENE NOT SAVED | The stripped scene couldn't be written. | Check the folder isn't read-only and the drive isn't full, then use File > Save As. |

## Troubleshooting

**Nothing happens when I drag the .mzp in.** Use Scripting > Run Script and pick the file. If that does nothing either, press F11, run it again and look for red text in the Listener.

**"V-Ray isn't loaded".** V-Ray isn't loaded in this 3ds Max session. Load it, or untick the two V-Ray options to run without it.

**"Save the scene once first".** The scene has never been saved, so there is no folder to put things in. Save it anywhere and run again.

**I can't find Doole's Tools in Customize User Interface.** Restart 3ds Max after installing. If an older install used a different category, it may still be listed there; see [Uninstall](#uninstall) to clear it.

**Red text in the Listener during a run.** The log file stops at the step that failed, and everything before it has already been done. Your backup has the scene as it was. Send the red text and the log with your report.

## Update

Download the new `StripScene.mzp` from [Releases](https://github.com/doolecg/strip_scene/releases) and drag it in, the same as the first install. It replaces the old copy. Toolbar buttons keep working.

## Uninstall

1. Close 3ds Max.
2. Open your user macros folder. In 3ds Max you can find it by running `getDir #userMacros` in the Listener (F11). It is usually under `%LOCALAPPDATA%\Autodesk\3dsMax\<version> - 64bit\ENU\usermacros`.
3. Delete `StripScene.mcr`, and any file whose name ends in `-StripScene.mcr` (3ds Max can keep its own copy there).
4. Start 3ds Max and remove the toolbar button if you added one.

Your `Backup`, `Stripped` and `Logs` folders are yours to keep or delete.
