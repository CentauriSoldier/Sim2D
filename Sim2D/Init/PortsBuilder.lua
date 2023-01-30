local tSim2D 		= Sim2D.__properties;
local SIM2D 		= SIM2D;
local Application	= Application;
local const 		= const;
local DialogEx		= DialogEx;
local File			= File;
local point 		= point;
local type			= type;

local nX 		= 0;
local nY 		= 0;
local nWidth 	= 0;
local nHeight 	= 0;
local nCoV_HX 	= 0;
local nCoV_VY 	= 0;
local hWnd 		= 0;
local tDisplay 	= System.GetDisplayInfo();

--read in the data from the project data file (assumes the file exists and is valid)
tSim2D.BuildData = deserialize.table(TextFile.ReadToString(SIM2D.VAR.USER_BUILD_DATA_FILE_PATH));
local tBuildData = tSim2D.BuildData;

local function NewPortTable()
	return {
		CoV 	= {
			HX 		= 1,
			VY 		= 1,
		},
		Ratios	= {
			WH 		= {left = 1, right = 1},
			HW 		= {left = 1, right = 1},
		},
		Rect	= 0,
		Wnd		= 0,
	};
end

tSim2D.Ports[SIM2D.PORT.APP]		= NewPortTable();
tSim2D.Ports[SIM2D.PORT.BUILD]		= NewPortTable();
tSim2D.Ports[SIM2D.PORT.DIALOGEX]	= NewPortTable();
tSim2D.Ports[SIM2D.PORT.SYSTEM]		= NewPortTable();

local tApp 		= tSim2D.Ports[SIM2D.PORT.APP];
local tBuild 	= tSim2D.Ports[SIM2D.PORT.BUILD];
local tDialogEx	= tSim2D.Ports[SIM2D.PORT.DIALOGEX];
local tSystem 	= tSim2D.Ports[SIM2D.PORT.SYSTEM];

--create the system port
--tSystem 			= NewPortTable();
tSystem.Rect 		= rectangle(point(0, 0), tDisplay.Width, tDisplay.Height);
tSystem.Ratios.WH 	= math.ratio(tDisplay.Width, tDisplay.Height);
tSystem.Ratios.HW 	= math.ratio(tDisplay.Height, tDisplay.Width);

--create the build port
local tWindowStyles = tBuildData.ProjectInfo.WindowStyles;
tBuild.Rect 		= rectangle(point(), tWindowStyles.Width, tWindowStyles.Height);
--determine the ratios for use in creating and fitting the app rectangle inside the system rectangle
tBuild.Ratios.WH 	= math.ratio(tWindowStyles.Width, tWindowStyles.Height);
tBuild.Ratios.HW 	= math.ratio(tWindowStyles.Height, tWindowStyles.Width);

--create the app port (based on the build size ratio)
--tApp				= NewPortTable();
--create and fit the app rectangle into the system rectangle
local tAppRect 		= math.fitrect(tDisplay.Width, tDisplay.Height, 0, 0, tBuild.Ratios.WH.left, tBuild.Ratios.WH.right, 1, true);
tApp.Rect			= rectangle(point(tAppRect.x, tAppRect.y), tAppRect.width, tAppRect.height);

--technically this is the same as the build ratio but we also store the values here in this table for easy and consistent reference
tApp.Ratios.WH 		= math.ratio(tApp.Rect:getWidth(), tApp.Rect:getHeight());
tApp.Ratios.HW 		= math.ratio(tApp.Rect:getHeight(), tApp.Rect:getWidth());
--determine the coefficient of variation
tApp.CoV.HX 		= tApp.Rect:getWidth() 	/ tBuild.Rect:getWidth()
tApp.CoV.HX 		= tApp.Rect:getHeight()	/ tBuild.Rect:getHeight();

--create all the dialogex ports
--tSim2D.Ports.DialogEx	= {};--NewPortTable();
