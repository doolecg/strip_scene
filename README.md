# Strip Scene

3ds Max 2024 / 2026 tool (needs V-Ray) that strips a scene down to plain geometry and saves a copy.

With every option ticked it:

- saves a dated backup to `Backup\<scene>_Backup_<date>_<time>.max`
- deletes cameras, lights, Forest Pack objects (and the `forest_templates` layer) and RailClone objects
- removes every material and puts one plain `Stripped_VRayMtl` on all geometry
- clears the material editors and environment map
- resets the V-Ray render settings
- saves the result to `Stripped\<scene>_Stripped.max`
- logs everything, warnings included, to the MAXScript Listener (F11) and `Logs\<scene>_StripLog_<date>_<time>.txt`

All folders are created beside the original scene. It only changes the open scene: no texture, library or original `.max` file is deleted or written to.

## Install

Drag `StripScene.mzp` into a Max viewport (or Scripting > Run Script). Then add the button from Customize > Customize User Interface > Toolbars, category "Doole's Tools".

## Build

```bash
./build.sh
```

Rebuilds `StripScene.mzp` from `mzp.run`, `install.ms` and `StripScene.mcr`.
