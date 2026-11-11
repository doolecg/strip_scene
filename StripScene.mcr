-- Strip Scene : 3ds Max 2024 / 2026 with V-Ray
-- Each step is a tick box. With everything ticked it saves a dated backup, deletes cameras, lights,
-- Forest Pack and RailClone objects, removes every material, puts one plain VRayMtl on all geometry,
-- resets the V-Ray render settings, then saves the scene as <name>_Stripped.max in a "Stripped" folder
-- beside the original file. Every run is logged, warnings included, to the MAXScript Listener and to
-- a text file in a "Logs" folder beside the original file.
macroScript StripScene
category:"Doole's Tools"
buttonText:"Strip Scene"
toolTip:"Strip Scene"
(
	rollout stripSceneRoll "Strip Scene" width:300
	(
		local logFile
		local warnCount = 0

		checkbox chkBackup "Save a dated backup first" checked:true
		checkbox chkCameras "Delete all cameras" checked:true
		checkbox chkLights "Delete all lights" checked:true
		checkbox chkForest "Delete Forest Pack objects and templates" checked:true
		checkbox chkRailClone "Delete RailClone objects" checked:true
		checkbox chkStrip "Remove all materials" checked:true
		checkbox chkVRayMtl "Apply a plain VRayMtl to all geometry" checked:true
		checkbox chkEditors "Clear material editors and environment map" checked:true
		checkbox chkRender "Reset V-Ray render settings" checked:true
		checkbox chkSave "Save as _Stripped in a Stripped folder" checked:true
		button btnRun "Strip Scene" width:276 height:32

		-- flushed on every line so the log is still complete up to the failure if a step errors
		fn logLine msg =
		(
			format "%\n" msg to:logFile
			flush logFile
			format "[Strip Scene] %\n" msg
		)

		fn warn msg =
		(
			warnCount += 1
			logLine ("WARNING: " + msg)
		)

		fn deleteLogged nodes label =
		(
			logLine (label + " deleted: " + (nodes.count as string))
			for o in nodes do logLine ("    " + o.name + "  (" + (classOf o as string) + ")")
			delete nodes
		)

		on btnRun pressed do
		(
			local risk = ""
			if not chkBackup.checked do risk += "No backup will be saved.\n"
			if not chkSave.checked do risk += "The changes will stay in your open scene, so saving it afterwards would overwrite the original.\n"

			if (chkVRayMtl.checked or chkRender.checked) and VRayMtl == undefined then
				messageBox "V-Ray isn't loaded. Untick the two V-Ray options or load V-Ray." title:"Strip Scene"
			else if maxFilePath == "" then
				messageBox "Save the scene once first, so I know where to make the Logs, Backup and Stripped folders." title:"Strip Scene"
			else if risk == "" or (queryBox (risk + "\nCarry on?") title:"Strip Scene") then
			(
				-- worked out up front: maxFilePath and maxFileName change once the stripped file is saved
				local sceneDir = maxFilePath
				local baseName = getFilenameFile maxFileName
				local stamp = (dotNetClass "System.DateTime").Now.ToString "yyyy-MM-dd_HHmm"
				local logPath = sceneDir + "Logs\\" + baseName + "_StripLog_" + stamp + ".txt"
				local report = "Done."

				makeDir (sceneDir + "Logs\\")
				logFile = createFile logPath
				warnCount = 0

				logLine ("Strip Scene log, " + stamp)
				logLine ("Scene: " + sceneDir + maxFileName)
				logLine ("3ds Max version info: " + (maxVersion() as string))
				logLine ("Objects in scene at start: " + (objects.count as string))
				logLine "Options:"
				for c in #(chkBackup, chkCameras, chkLights, chkForest, chkRailClone, chkStrip, chkVRayMtl, chkEditors, chkRender, chkSave) do
					logLine ("    [" + (if c.checked then "x" else " ") + "] " + c.caption)

				if not chkBackup.checked do warn "No backup was saved (option unticked)."
				if not chkSave.checked do warn "Changes were left in the open scene (save option unticked). Saving it would overwrite the original."

				-- these load as placeholders, so they can't be recognised as cameras, lights, Forest Pack or RailClone
				local missing = for o in objects where matchPattern (classOf o as string) pattern:"Missing*" collect o
				if missing.count > 0 do
				(
					warn ((missing.count as string) + " objects come from plugins that aren't installed and were left alone:")
					for o in missing do logLine ("    " + o.name + "  (" + (classOf o as string) + ")")
				)
				if xrefs.getXRefFileCount() > 0 do
					warn ((xrefs.getXRefFileCount() as string) + " XRef scenes are attached. Nothing inside them is changed.")

				-- listed before anything is changed, so there's a record of what the scene pointed at
				local texFiles = usedMaps()
				logLine ("Texture files referenced before stripping: " + (texFiles.count as string))
				for t in texFiles do logLine ("    " + t)

				local backupOk = true
				if chkBackup.checked do
				(
					local backupDir = sceneDir + "Backup\\"
					local backupFile = backupDir + baseName + "_Backup_" + stamp + ".max"
					makeDir backupDir
					-- copy of the scene as it is right now, unsaved changes included; the open file stays the original
					saveMaxFile backupFile useNewFile:false quiet:true
					backupOk = doesFileExist backupFile
					if backupOk then logLine ("Backup saved: " + backupFile)
					else warn ("BACKUP FAILED, nothing was changed: " + backupFile)
					report += "\n\nBackup:\n" + backupFile
				)

				if not backupOk then
				(
					close logFile
					messageBox ("The backup could not be saved, so nothing was changed.\n\nLog:\n" + logPath) title:"Strip Scene"
				)
				else
				(
					-- collected into arrays first: deleting a camera or light also removes its target mid-loop
					if chkCameras.checked do deleteLogged (for o in objects where superClassOf o == camera collect o) "Cameras"
					if chkLights.checked do deleteLogged (for o in objects where superClassOf o == light collect o) "Lights"

					-- matched by class name so Pro and Lite both count, and nothing breaks if the plugin isn't installed
					if chkForest.checked do
					(
						deleteLogged (for o in objects where matchPattern (classOf o as string) pattern:"Forest_*" collect o) "Forest Pack objects"

						-- Forest Pack parks the library items it imports for scattering on this hidden layer
						local templateLayer = LayerManager.getLayerFromName "forest_templates"
						if templateLayer != undefined do
						(
							local templateNodes
							templateLayer.nodes &templateNodes
							deleteLogged templateNodes "Forest Pack templates (forest_templates layer)"
							if LayerManager.deleteLayerByName "forest_templates" then logLine "Layer removed: forest_templates"
							else warn "The forest_templates layer was emptied but could not be removed (it may be the current layer)."
						)
					)
					if chkRailClone.checked do
						deleteLogged (for o in objects where matchPattern (classOf o as string) pattern:"RailClone_*" collect o) "RailClone objects"

					if chkStrip.checked do
					(
						local withMtl = for o in objects where o.material != undefined collect o
						local mtls = makeUniqueArray (for o in withMtl collect o.material)
						logLine ("Materials removed: " + (mtls.count as string) + " materials, taken off " + (withMtl.count as string) + " objects")
						for m in mtls do logLine ("    " + m.name + "  (" + (classOf m as string) + ")")
						objects.material = undefined
					)

					if chkVRayMtl.checked do
					(
						local mtl = VRayMtl name:"Stripped_VRayMtl"
						-- camera and light targets count as geometry in Max, skip them
						local geo = for o in geometry where classOf o != Targetobject collect o
						for o in geo do o.material = mtl
						logLine ("Stripped_VRayMtl applied to " + (geo.count as string) + " geometry objects")
					)

					-- the material editors and environment slot keep old materials and bitmaps alive in the file
					if chkEditors.checked do
					(
						local viewCount = sme.GetNumViews()
						for i = 1 to meditMaterials.count do meditMaterials[i] = PhysicalMaterial()
						for i = viewCount to 1 by -1 do sme.DeleteView i false
						logLine ("Material editor cleared: " + (meditMaterials.count as string) + " compact slots reset, " + (viewCount as string) + " Slate views deleted")
						logLine ("Environment map removed: " + (if environmentMap == undefined then "none set" else environmentMap.name))
						environmentMap = undefined
						useEnvironmentMap = false
					)

					-- a fresh renderer instance is V-Ray's reset to defaults; stays on V-Ray GPU if the scene was using it
					if chkRender.checked do
					(
						local rc = classOf renderers.current
						renderers.current = if matchPattern (rc as string) pattern:"V_Ray*" then rc() else VRay()
						logLine ("Render settings reset: was " + (rc as string) + ", now a default " + (classOf renderers.current as string))
						if rc != classOf renderers.current do warn ("The renderer was switched from " + (rc as string) + " to V-Ray.")
					)

					-- Max keeps removed materials in its scene material list until it is refreshed or the file is saved,
					-- which can make the leftover checks further down report things that are already gone
					UpdateSceneMaterialLib()

					logLine ("Objects in scene at end: " + (objects.count as string))

					-- saves as the new file, so Ctrl+S afterwards can't overwrite the original
					if chkSave.checked do
					(
						local outDir = sceneDir + "Stripped\\"
						local outFile = outDir + baseName + "_Stripped.max"
						makeDir outDir
						saveMaxFile outFile
						if doesFileExist outFile then logLine ("Stripped scene saved: " + outFile)
						else warn ("STRIPPED SCENE NOT SAVED: " + outFile)
						report += "\n\nSaved to:\n" + outFile
					)

					if chkStrip.checked do
					(
						local mtlsLeft = for m in sceneMaterials where m.name != "Stripped_VRayMtl" collect m
						if mtlsLeft.count > 0 do
						(
							warn ((mtlsLeft.count as string) + " materials are still held by the scene:")
							for m in mtlsLeft do logLine ("    " + m.name + "  (" + (classOf m as string) + ")")
						)
					)
					local texLeft = usedMaps()
					if texLeft.count > 0 do
					(
						warn ((texLeft.count as string) + " of " + (texFiles.count as string) + " texture files are still referenced by the scene (for example by modifiers, or by the material editor if that option was unticked):")
						for t in texLeft do logLine ("    " + t)
					)

					logLine ("Finished with " + (warnCount as string) + " warnings.")
					close logFile
					if warnCount > 0 do report += "\n\nWarnings: " + (warnCount as string) + ". They are marked WARNING in the log and the MAXScript Listener (F11)."
					messageBox (report + "\n\nLog:\n" + logPath) title:"Strip Scene"
				)
			)
		)
	)

	on execute do
	(
		-- closes an already-open copy; errors if there isn't one, which is fine
		try (destroyDialog stripSceneRoll) catch ()
		createDialog stripSceneRoll
	)
)
