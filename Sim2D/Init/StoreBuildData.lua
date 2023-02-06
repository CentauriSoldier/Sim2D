if (Project.LoadAutoPlayFile()) then --get the project build info (stores if not compiled, only)
	local Sim2D 	= Sim2D;
	local tProps 	= Sim2D.__properties;
	local tBuild 	= tProps.Build;

	local tData = Project.GetAutoPlayData();
	local tProjectInfo	= tData.ProjectInfo;
	local tWindowStyles = tProjectInfo.WindowStyles;

	local tSaveData = {
		Dialogs 	= tData.Dialogs,
		ProjectInfo = {
			WindowStyles 	= tProjectInfo.WindowStyles,
			WindowOptions 	= tProjectInfo.WindowOptions,
		},
		Pages 		= tData.Pages,
	};


	--do the factory stuff here!!!!


	--process each page's/dialogex's uicom objects

	--get each uicom object from each state

	--get and process the code from the onclick event

	--create the uicom object

	--set the AMS object to be deleted at the OnPreload Event

	--clean up the BuildDataTable

	--store all normal AMS objects for equalization

	--delete all page/dialog objects from the table

	TextFile.WriteFromString(SIM2D.PATH.USER.FILE.BUILDDATA.value, serialize.table(tSaveData), false);
end
