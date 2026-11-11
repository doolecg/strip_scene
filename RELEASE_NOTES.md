# Strip Scene 1.0

**Install:** download `StripScene.mzp` from the assets below and drag it into a 3ds Max 2024 or 2026 viewport.

## New
- **Strips a scene to plain geometry.** Deletes cameras, lights, Forest Pack (with its `forest_templates` layer) and RailClone objects, removes every material and puts one plain `Stripped_VRayMtl` on all geometry.
- **Cleans out what keeps old textures alive.** Resets the material editor slots, closes Slate views, clears the environment map and resets V-Ray to its defaults.
- **Saves a copy, never your original.** A dated backup first, then the result as `Stripped\<scene>_Stripped.max`.
- **Logs every step.** To the MAXScript Listener and a text file in `Logs\`, with warnings for anything worth a second look.
- **Every step is a tick box,** all on by default.
