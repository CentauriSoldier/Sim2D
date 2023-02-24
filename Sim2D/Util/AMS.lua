local tAutoPlay;

tAutoPlay = {
    Data = {},
	DataDescription = "",--after the data has been parsed, this is created
	CountItems = function(sItemPath, sItemName)
		return XML.Count(tAutoPlay.XML.BasePath..sItemPath, sItemName)
	end,
	GetBoolean = function(sItemPath, sAttribute)
		local bRet = false;

		if (type(sAttribute) == "string") then
			bRet = tonumber(XML.GetAttribute(tAutoPlay.XML.BasePath..sItemPath, sAttribute)) == 1 and true or false;
		else
			bRet = tonumber(XML.GetValue(tAutoPlay.XML.BasePath..sItemPath)) == 1 and true or false;
		end

		return bRet;
	end,
	GetNumber = function(sItemPath, sAttribute)
		local bRet = false;

		if (type(sAttribute) == "string") then
			bRet = tonumber(XML.GetAttribute(tAutoPlay.XML.BasePath..sItemPath, sAttribute));
		else
			bRet = tonumber(XML.GetValue(tAutoPlay.XML.BasePath..sItemPath));
		end

		return bRet;
	end,
	GetString = function(sItemPath, sAttribute)
		local bRet = false;

		if (type(sAttribute) == "string") then
			bRet = XML.GetAttribute(tAutoPlay.XML.BasePath..sItemPath, sAttribute);
		else
			bRet = XML.GetValue(tAutoPlay.XML.BasePath..sItemPath);
		end

		return bRet;
	end,
	GetEventsTable = function(sObjectPageDialogPath)
		local tRet 		= {};
		local tAutoPlay = tAutoPlay;
		local sPath 	= sObjectPageDialogPath.."/Event";
		local DSTT 		= tProject.Functions.DSTT;

		for x = 1, tAutoPlay.CountItems(sObjectPageDialogPath, "Event") do
			local sEventPath 	= sPath..":"..x;
			local sName 		= tAutoPlay.GetString(sEventPath.."/Name");
			local tArgsRaw 		= DSTT(tAutoPlay.GetString(sEventPath.."/Args"), ", ");
			local tArgs			= {};

			for _, sArgInfo in pairs(tArgsRaw) do
				local tArgInfo = DSTT(sArgInfo, " ");

				if (tArgInfo[1]:gsub("%s", "") ~= "" and tArgInfo[1]:gsub("%s", "") ~= "") then
					tArgs[#tArgs + 1] = {
						Name = tArgInfo[2],
						Type = tArgInfo[1],
					};
				end

			end

			tRet[sName] = {
				Args 		= tArgs,
				Script 		= tAutoPlay.GetString(sEventPath.."/Script"),
				Name		= sName,
			};
		end

		return tRet;
	end,
	GetObjectsTable = function(sPageDialogPath)
		local tRet 				= {};
		local tAutoPlay 		= tAutoPlay;
		local sPath 			= sPageDialogPath.."/Object";
		local CountItems 		= tAutoPlay.CountItems;
		local GetEventsTable	= tAutoPlay.GetEventsTable;
		local GetBoolean 		= tAutoPlay.GetBoolean;
		local GetNumber 		= tAutoPlay.GetNumber;
		local GetString 		= tAutoPlay.GetString;

		for x = 1, CountItems(sPageDialogPath, "Object") do
			local sObjectPath = sPath..":"..x;
			local sName = GetString(sObjectPath.."/Name");

			tRet[sName] = {
				Actions 			= GetString(sObjectPath.."/Box/Actions"),--TODO Is this really a string? What is this?
				Box 				= {
					BorderStyle			= GetNumber(sObjectPath.."/Box/BorderStyle"),
					VerticalScrollbar	= GetBoolean(sObjectPath.."/Box/VerticalScrollbar"),
					HorizontalScrollbar	= GetBoolean(sObjectPath.."/Box/HorizontalScrollbar"),
					Style				= GetNumber(sObjectPath.."/Box/Style"),
					Mode				= GetNumber(sObjectPath.."/Box/Mode"),
					Mask				= GetString(sObjectPath.."/Box/Mask"),
					MaskSymbol			= GetString(sObjectPath.."/Box/MaskSymbol"),
					MaskRetMode			= GetNumber(sObjectPath.."/Box/MaskRetMode"),
					ReadOnly			= GetBoolean(sObjectPath.."/Box/ReadOnly"),
				},
				AutoResize			= GetBoolean(sObjectPath.."/AutoResize"),
				Coordinates			= {
					Bottom				= GetNumber(sObjectPath.."/Coordinates/Bottom"),
					Left 				= GetNumber(sObjectPath.."/Coordinates/Left"),
					Right				= GetNumber(sObjectPath.."/Coordinates/Right"),
					Top					= GetNumber(sObjectPath.."/Coordinates/Top"),
				},
				Cursor				= GetNumber(sObjectPath.."/Cursor"),
				Enabled				= GetBoolean(sObjectPath.."/Enabled"),
				Events				= GetEventsTable(sObjectPath),
				Group				= GetNumber(sObjectPath.."/Group"),
				Locked				= GetBoolean(sObjectPath.."/Locked"),
				MaintainAspectRatio	= GetBoolean(sObjectPath.."/MaintainAspectRatio"),
				Name				= sName,
				Pin					= GetBoolean(sObjectPath.."/Pin"),
				Ratios				= {
					WidthRatio			= GetNumber(sObjectPath.."/Ratios/WidthRatio"),
					HeightRatio			= GetNumber(sObjectPath.."/Ratios/HeightRatio"),
				},
				TabIndex			= GetNumber(sObjectPath.."/TabIndex"),
				Text				= {
					Alignment				= GetNumber(sObjectPath.."/Text/Alignment"),
					BackgroundColor			= GetNumber(sObjectPath.."/Text/BackgroundColor"),
					Body					= GetString(sObjectPath.."/Text/Body"),
					TextColor				= GetNumber(sObjectPath.."/Text/TextColor"),
					FontData 				= {
						FontName				= GetString(sObjectPath.."/Text/FontData/FontName"),
						CharacterSet			= GetNumber(sObjectPath.."/Text/FontData/CharacterSet"),
						Height					= GetNumber(sObjectPath.."/Text/FontData/Height"),
						Weight					= GetNumber(sObjectPath.."/Text/FontData/Weight"),
						Italic					= GetBoolean(sObjectPath.."/Text/FontData/Italic"),
						Underline				= GetBoolean(sObjectPath.."/Text/FontData/Underline"),
						StrikeOut				= GetBoolean(sObjectPath.."/Text/FontData/StrikeOut"),
						AntiAlias				= GetBoolean(sObjectPath.."/Text/FontData/AntiAlias"),
					},
					RightToLeftReadingOrder	= GetBoolean(sObjectPath.."/Text/RightToLeftReadingOrder"),
				},
				ToolTip				= GetString(sObjectPath.."/ToolTip"),
				Type				= GetNumber(sObjectPath.."/Type"),
				VisibleAtDesignTime	= GetBoolean(sObjectPath.."/VisibleAtDesignTime"),
				VisibleAtRunTime	= GetBoolean(sObjectPath.."/VisibleAtRunTime"),
			};
		end

		return tRet;
	end,
	GetPageTable = function(sPath)
		local tAutoplay 		= tAutoPlay;
		local CountItems 		= tAutoplay.CountItems;
		local GetBoolean 		= tAutoplay.GetBoolean;
		local GetEventsTable	= tAutoplay.GetEventsTable;
		local GetNumber 		= tAutoplay.GetNumber;
		local GetString 		= tAutoplay.GetString;

		return {
			Background	= {
				Type 						= GetNumber(sPath.."/Background/Type"),
				ImageStyle					= GetNumber(sPath.."/Background/ImageStyle"),
				TopColor					= GetNumber(sPath.."/Background/TopColor"),
				BottomColor					= GetNumber(sPath.."/Background/BottomColor"),
				UseCustomBackgroundSettings	= GetBoolean(sPath.."/Background/UseCustomBackgroundSettings"),
				--TransitionEffect			= GetNumber(sPath.."/"), TODO
				--TransProps				= , TODO
				NormalImage = {
					Filename				= GetString(sPath.."/Background/NormalImage/Filename"),
				},
			},
			Description = GetString(sPath.."/Description"),
			Events		= GetEventsTable(sPath),
			InheritBG	= GetString(sPath.."/InheritBG"),
			InheritObs	= GetString(sPath.."/InheritObs"),
			Keywords	= GetString(sPath.."/Keywords"),
			ObjectCount = CountItems(sPath, "Object"),
			Objects 	= tAutoplay.GetObjectsTable(sPath),
			Name 		= GetString(sPath.."/Name"),
			NormalImage = {
				Filename	= GetString(sPath.."/NormalImage/Filename"),
			},
		};
	end,
	ParseFile = function(pFile)
		local tAutoplay 		= tAutoPlay;
		local CountItems		= tAutoplay.CountItems;
		local GetBoolean		= tAutoplay.GetBoolean;
		local GetEventsTable	= tAutoplay.GetEventsTable;
		local GetNumber			= tAutoplay.GetNumber;
		local GetString			= tAutoplay.GetString;
		local GetPageTable		= tAutoplay.GetPageTable;

		--get the user's xml (if any)
		local sCurrentXML 	= XML.GetXML();

		--store the xml info for later, xml-specific queries
		tAutoPlay.Data.Filepath 	= pFile;
		tAutoPlay.XML.String		= TextFile.ReadToString(pFile);

		--load the xml data
		XML.SetXML(tAutoPlay.XML.String);

		--(re)set the parsed data table
		tAutoPlay.Data = {
			Dialogs 		= {
				Count 			=  CountItems("/SugDialogs", "PageDialog"),
				Info 			= {}, --Done below
				Names 			= {}, --Done below
			},
			DocInfo			= {
				Author 			= GetString("/DocInfo/Author"),
				Comments		= GetString("/DocInfo/Comments"),
				Company			= GetString("/DocInfo/Company"),
				Copyright		= GetString("/DocInfo/Copyright"),
				CreatedVersion	= GetString("/DocInfo/CreatedVersion"),
				Email			= GetString("/DocInfo/Email"),
				LastSavedVersion= GetString("/DocInfo/LastSavedVersion"),
				Title 			= GetString("/DocInfo/Title"),
				URL				= GetString("/DocInfo/URL"),
			},
			Pages 			= {
				Count 			= CountItems("", "Page"),
				Info 			= {}, --Done below
				Names 			= {}, --Done below
			},
			MissingTechs	= {
				DlgTitle		= GetString("/MissingTechs/DlgTitle"),
				DlgMsg			= GetString("/MissingTechs/DlgMsg"),
				BtnAbort		= GetString("/MissingTechs/BtnAbort"),
				BtnCancel		= GetString("/MissingTechs/BtnCancel"),
				BtnHelp			= GetString("/MissingTechs/BtnHelp"),
				ShowHelpBtn		= GetString("/MissingTechs/ShowHelpBtn"),
				HelpURL			= GetString("/MissingTechs/HelpURL"),
			},
			ProjectInfo		= {
				ActionPlugins		= {}, --Done below
				AudioBGMusic 		= {
					ShuffleMode 		= GetBoolean("/ProjectInfo/AudioBGMusic/ShuffleMode"),
					Repeat 				= GetBoolean("/ProjectInfo/AudioBGMusic/Repeat"),
					BackVolume 			= GetNumber("/ProjectInfo/AudioBGMusic/BackVolume"),
					EffectsVolume 		= GetNumber("/ProjectInfo/AudioBGMusic/EffectsVolume"),
					Tracks 				= {},
				},
				CodeSigning			= {}, --TODO Should I do this or does it present a security problem?
				Databases 			= {
					MySQL 				= GetBoolean("/ProjectInfo/Databases/MySQL"),
					SQLite3 			= GetBoolean("/ProjectInfo/Databases/SQLite3"),
					Oracle				= GetBoolean("/ProjectInfo/Databases/Oracle"),
					ODBC 				= GetBoolean("/ProjectInfo/Databases/ODBC"),
					PostgreSQL 			= GetBoolean("/ProjectInfo/Databases/PostgreSQL"),
				},
				Defaults 			= {
					StartupPage 			= GetString("/ProjectInfo/Defaults/StartupPage"),
					MouseOverSoundDefault 	= GetString("/ProjectInfo/Defaults/MouseOverSoundDefault"),
					MouseClickSoundDefault 	= GetString("/ProjectInfo/Defaults/MouseClickSoundDefault"),
					MemMngMethod 			= GetNumber("/ProjectInfo/Defaults/MemMngMethod"),
					UserPrivilegeLevel 		= GetNumber("/ProjectInfo/Defaults/UserPrivilegeLevel"),
				},
				Events 				= GetEventsTable("/ProjectInfo"),
				EXEResourceInfo 	= {
					ReplaceIcon				= GetBoolean("/ProjectInfo/EXEResourceInfo/ReplaceIcon"),
					IconFilename			= GetString("/ProjectInfo/EXEResourceInfo/IconFilename"),
					ReplaceVersionInfo		= GetBoolean("/ProjectInfo/EXEResourceInfo/ReplaceVersionInfo"),
					FileVer1				= GetNumber("/ProjectInfo/EXEResourceInfo/FileVer1"),
					FileVer2				= GetNumber("/ProjectInfo/EXEResourceInfo/FileVer2"),
					FileVer3				= GetNumber("/ProjectInfo/EXEResourceInfo/FileVer3"),
					FileVer4				= GetNumber("/ProjectInfo/EXEResourceInfo/FileVer4"),
					ProductVer1				= GetNumber("/ProjectInfo/EXEResourceInfo/ProductVer1"),
					ProductVer2				= GetNumber("/ProjectInfo/EXEResourceInfo/ProductVer2"),
					ProductVer3				= GetNumber("/ProjectInfo/EXEResourceInfo/ProductVer3"),
					ProductVer4				= GetNumber("/ProjectInfo/EXEResourceInfo/ProductVer4"),
					Comments				= GetString("/ProjectInfo/EXEResourceInfo/Comments"),
					Company					= GetString("/ProjectInfo/EXEResourceInfo/Company"),
					FileDescription			= GetString("/ProjectInfo/EXEResourceInfo/FileDescription"),
					LegalCopyright			= GetString("/ProjectInfo/EXEResourceInfo/LegalCopyright"),
					LegalTrademarks			= GetString("/ProjectInfo/EXEResourceInfo/LegalTrademarks"),
					PrivateBuild			= GetBoolean("/ProjectInfo/EXEResourceInfo/PrivateBuild"),
					ProductName				= GetString("/ProjectInfo/EXEResourceInfo/ProductName"),
					SpecialBuild			= GetBoolean("/ProjectInfo/EXEResourceInfo/SpecialBuild"),
				},
				Globals 			= GetString("/ProjectInfo/Globals/Script"),
				Group				= {
					CurrentGrounp 		= GetNumber("/ProjectInfo/Group/CurrentGrounp"),
				},
				Icon 				= {
					IconFile			= GetString("/ProjectInfo/Icon/IconFile"),
					TaskbarVisibility	= GetBoolean("/ProjectInfo/Icon/TaskbarVisibility"),
					UseCustomIcon		= GetBoolean("/ProjectInfo/Icon/UseCustomIcon"),
				},
				IntroVideo			= {
					AllowClickToSkip 	= GetBoolean("/ProjectInfo/IntroVideo/AllowClickToSkip"),
					MediaWidth 			= GetNumber("/ProjectInfo/IntroVideo/MediaWidth"),
					MediaHeight 		= GetNumber("/ProjectInfo/IntroVideo/MediaHeight"),
					WindowWidth 		= GetNumber("/ProjectInfo/IntroVideo/WindowWidth"),
					WindowHeight 		= GetNumber("/ProjectInfo/IntroVideo/WindowHeight"),
					BackgroundColor 	= GetNumber("/ProjectInfo/IntroVideo/BackgroundColor"),
					MediaMode 			= GetNumber("/ProjectInfo/IntroVideo/MediaMode"),
					WindowMode 			= GetNumber("/ProjectInfo/IntroVideo/WindowMode"),
					VideoFileName 		= GetString("/ProjectInfo/IntroVideo/VideoFileName"),
					UseIntroVideo 		= GetBoolean("/ProjectInfo/IntroVideo/UseIntroVideo"),
					VideoType 			= GetNumber("/ProjectInfo/IntroVideo/VideoType"),
					UseBorder 			= GetBoolean("/ProjectInfo/IntroVideo/UseBorder"),
					TitleBar 			= GetBoolean("/ProjectInfo/IntroVideo/TitleBar"),
					TitleBarText 		= GetString("/ProjectInfo/IntroVideo/TitleBarText"),
				},
				MenuBar				= {
					Enabled				= GetBoolean("/ProjectInfo/MenuBar/Enabled"),
					UseIcons			= GetBoolean("/ProjectInfo/MenuBar/UseIcons"),
					BitmapIconFile		= GetString("/ProjectInfo/MenuBar/BitmapIconFile"),
					TransColor			= GetString("/ProjectInfo/MenuBar/TransColor"),
					MenuItems 			= {}, --Done below
				},
				Office2007Theme 	= GetNumber("/ProjectInfo/Office2007Theme", "Theme"),
				ReadOrder			= {
					RTLReadOrder 		= GetBoolean("/ProjectInfo/ReadOrder/RTLReadOrder"),
				},
				RuntimeSkin			= {
					UseSkinFile			=  GetBoolean("/ProjectInfo/RuntimeSkin/UseSkinFile"),
					SkinFilename		=  GetString("/ProjectInfo/RuntimeSkin/SkinFilename"),
					SkinSubStyle		=  GetString("/ProjectInfo/RuntimeSkin/SkinSubStyle"),
				},
				TargetMedia			= {
					TargetMediaSize 	= GetNumber("/ProjectInfo/TargetMedia/TargetMediaSize"),
					CustomSize 			= GetBoolean("/ProjectInfo/TargetMedia/CustomSize"),
				},
				TemplateInfo		= { --TODO
					Author				= GetString("/ProjectInfo/TemplateInfo/Author"),
					Categories			= GetString("/ProjectInfo/TemplateInfo/Categories"),
					Contact				= GetString("/ProjectInfo/TemplateInfo/Contact"),
					Copyright			= GetString("/ProjectInfo/TemplateInfo/Copyright"),
					Desc				= GetString("/ProjectInfo/TemplateInfo/Desc"),
					Name				= GetString("/ProjectInfo/TemplateInfo/Name"),
					Picture				= GetString("/ProjectInfo/TemplateInfo/Picture"),
					Web					= GetString("/ProjectInfo/TemplateInfo/Web"),
				},
				ToolTipStyle		= GetNumber("/ProjectInfo", "ToolTipStyle"),
				TransparentWindow 	= {
					TransparentImage 	= GetString("/ProjectInfo/TransparentWindow/WindowTitle"),
					FitTrans 			= GetBoolean("/ProjectInfo/TransparentWindow/FitTrans"),
				},
				WindowOptions 		= {
					AlwaysOnTop			= GetBoolean("/ProjectInfo/WindowOptions/AlwaysOnTop"),
					Moveable			= GetBoolean("/ProjectInfo/WindowOptions/Moveable"),
					Resizable			= GetBoolean("/ProjectInfo/WindowOptions/Resizable"),
					MinWidth 			= GetNumber("/ProjectInfo/WindowOptions/MinWidth"),
					MinHeight 			= GetNumber("/ProjectInfo/WindowOptions/MinHeight"),
				},
				WindowStyles		= {
					Ratio		= {
						WidthToHeight 	= 0, --Done below
						HeightToWidth 	= 0, --Done below
					},
					FillColor			= GetNumber("/ProjectInfo/WindowStyles/FillColor"),
					Width 				= GetNumber("/ProjectInfo/WindowStyles/Width"),
					Height 				= GetNumber("/ProjectInfo/WindowStyles/Height"),
					WindowStyle 		= GetNumber("/ProjectInfo/WindowStyles/WindowStyle"),
					WindowTitle 		= GetString("/ProjectInfo/WindowStyles/WindowTitle"),
				},
			},
			ProductID		= GetString("/ProductID"),
			ProgramPrefs	= {
				OutputFolder				= GetString("/ProgramPrefs/OutputFolder"),
				EXEName						= GetString("/ProgramPrefs/EXEName"),
				EnableAutoPlayFeatureBTF	= GetBoolean("/ProgramPrefs/EnableAutoPlayFeatureBTF"),
				EnableAutoPlayFeatureCDRW 	= GetBoolean("/ProgramPrefs/EnableAutoPlayFeatureCDRW"),
				EnableAutoPlayFeatureISO	= GetBoolean("/ProgramPrefs/EnableAutoPlayFeatureISO"),
				EnableAutoPlayFeatureSFX 	= GetBoolean("/ProgramPrefs/EnableAutoPlayFeatureSFX"),
				TimeStampFilesBTF			= GetBoolean("/ProgramPrefs/TimeStampFilesBTF"),
				TimeStampFilesCDRW			= GetBoolean("/ProgramPrefs/TimeStampFilesCDRW"),
				TimeStampFilesISO			= GetBoolean("/ProgramPrefs/TimeStampFilesISO"),
				ISOImageFile				= GetString("/ProgramPrefs/ISOImageFile"),
				SelfExtractingZIPfile		= GetString("/ProgramPrefs/SelfExtractingZIPfile"),
				ZIPMessage					= GetString("/ProgramPrefs/ZIPMessage"),
				ZIPShowProgress				= GetBoolean("/ProgramPrefs/ZIPShowProgress"),
				CDVolumeIdentifier			= GetString("/ProgramPrefs/CDVolumeIdentifier"),
				CacheFileData				= GetBoolean("/ProgramPrefs/CacheFileData"),
				UseBurnProof				= GetBoolean("/ProgramPrefs/UseBurnProof"),
				BuildType					= GetNumber("/ProgramPrefs/BuildType"),
				DriveLetter					= GetString("/ProgramPrefs/DriveLetter"),
				UsePassword					= GetBoolean("/ProgramPrefs/UsePassword"),
				OpenFolder					= GetBoolean("/ProgramPrefs/OpenFolder"),
				ObscureFilenames			= GetBoolean("/ProgramPrefs/ObscureFilenames"),
				ObscureDataFolder			= GetString("/ProgramPrefs/ObscureDataFolder"),
			},
			ProductType		= GetString("/ProductType"),
			ProductVersion	= GetString("/ProductVersion"),
		};

		local tData = tAutoPlay.Data;

		--calculate the build ratio
		tData.ProjectInfo.WindowStyles.Ratio.WidthToHeight = tData.ProjectInfo.WindowStyles.Width 	/ tData.ProjectInfo.WindowStyles.Height;
		tData.ProjectInfo.WindowStyles.Ratio.HeightToWidth = tData.ProjectInfo.WindowStyles.Height 	/ tData.ProjectInfo.WindowStyles.Width;

		--get the action plugins
		for x = 1, CountItems("/ProjectInfo/ActionPlugins", "Plugin") do
			tData.ProjectInfo.ActionPlugins[#tData.ProjectInfo.ActionPlugins + 1] = GetString("/ProjectInfo/ActionPlugins/Plugin:"..x);
		end

		--get the bg audio tracks
		for x = 1, CountItems("/ProjectInfo/AudioBGMusic", "Tracks") do
			tData.ProjectInfo.AudioBGMusic.Tracks[#tData.ProjectInfo.AudioBGMusic.Tracks + 1] = GetString("/ProjectInfo/AudioBGMusic/Tracks/Track:"..x);
		end

		--get the menu items
		local tMenuBar = tData.ProjectInfo.MenuBar;
		for x = 1, CountItems("/ProjectInfo/MenuBar", "MenuItem") do
			local sPath = "/ProjectInfo/MenuBar/MenuItem:"..x;

			tMenuBar.MenuItems[#tMenuBar.MenuItems + 1] = {
				Text 	= GetString(sPath.."/Text"),
				ID 		= GetNumber(sPath.."/ID"),
				Enabled	= GetBoolean(sPath.."/Enabled"),
				Checked = GetBoolean(sPath.."/Checked"),
			};
		end

		--get the page info
		for x = 1, tData.Pages.Count do
			local sPath = "/Page:"..x;
			local sPage = GetString(sPath.."/Name");

			--page names
			tData.Pages.Names[#tData.Pages.Names + 1] = sPage;
			--page table
			tData.Pages.Info[sPage] = GetPageTable(sPath);
		end

		--get the dialog info
		for x = 1, tData.Dialogs.Count do
			local sPath = "/SugDialogs/PageDialog:"..x;
			local sDialog = GetString(sPath.."/Page/Name");

			--dialog name
			tData.Dialogs.Names[#tData.Dialogs.Names + 1] = sDialog;
			--dialog table
			tData.Dialogs.Info[sDialog] = GetPageTable(sPath.."/Page");

			--get the dialog's attributes
			tData.Dialogs.Info[sDialog].Attributes = {
				Width 					= GetNumber(sPath, "width"),
				Height 					= GetNumber(sPath, "height"),
				DialogTitle  			= GetString(sPath, "dialog_title"),
				DialogStyle   			= GetNumber(sPath, "dialog_style"),
				Movable 	  			= GetBoolean(sPath, "movable"),
				UseCustomIcon 			= GetBoolean(sPath, "use_custom_icon"),
				CustomIcon				= GetString(sPath, "custom_icon"),
				AlwaysOnTop	    		= GetBoolean(sPath, "always_on_top"),
				Resizable	    		= GetBoolean(sPath, "resizable"),
				MinWidth 				= GetNumber(sPath, "min_width"),
				MinHeight       		= GetNumber(sPath, "min_height"),
				FitCustomMaskToWindow 	= GetBoolean(sPath, "fit_custom_mask_to_window"),
				CustomMask			    = GetString(sPath, "custom_mask"),
			};
		end

		--reset the user's xml
		XML.SetXML(sCurrentXML);
	end,
	XML 	= {	--xml details of autoplay
		Filepath	= "",
		BasePath 	="DocumentData",
		String 		= "",
	}
};


--==============================
-- Project.LoadAutoPlayFile
--==============================
function Project.LoadAutoPlayFile(pFile)
	local bRet 			= false;
	local pRealFile 	= nil;
	local sInputType 	= type(pFile);

	if (not tProject.Functions.IsCompiled()) then

		--try to find this project's autoplay file
		if (sInputType == "nil") then
			local tFiles = File.Find(_ExeFolder.."\\..\\","*.autoplay",false,false,"","");

			if (tFiles and #tFiles > 0) then
				pRealFile = tFiles[1];
			end

		elseif (sInputType == "string" and File.DoesExist(pFile) and String.SplitPath(pFile).Extension:lower() == ".autoplay") then
			pRealFile = pFile;
		end

		if (pRealFile) then
			tAutoPlay.ParseFile(pRealFile);
			bRet = true;
		end

	end

	return bRet;
end


--==============================
-- Project.GetAutoPlayData
--==============================
--TODO copy this table?
function Project.GetAutoPlayData()
	return tAutoPlay.Data;
end


--==============================
-- Project.GetAutoPlayXML
--==============================
function Project.GetAutoPlayXML()
	return tAutoPlay.XML.String;
end
