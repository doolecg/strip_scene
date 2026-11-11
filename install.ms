-- Runs when StripScene.mzp is dropped into Max: installs the macro for this user and opens the tool.
(
	local src = getFilenamePath (getThisScriptFilename()) + "StripScene.mcr"
	local dst = (getDir #userMacros) + "\\StripScene.mcr"

	-- copyFile won't overwrite, so clear any older install first
	deleteFile dst
	copyFile src dst
	fileIn dst

	macros.run "Doole's Tools" "StripScene"
	messageBox "Strip Scene is installed.\n\nTo put it on a toolbar: Customize > Customize User Interface > Toolbars, category \"Doole's Tools\", drag \"Strip Scene\" onto a toolbar." title:"Strip Scene"
)
