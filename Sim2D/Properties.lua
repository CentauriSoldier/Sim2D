return {
	AllowedImagesTypes 	= { --TODO move to constants
		".bmp", ".ico", ".png", ".jpg", ".jfif",
		".jpeg", ".jpe", ".jpf", ".jpx", ".jp2",
		".j2c", ".j2k", ".jpc", ".tif", ".tiff",
		".tga", ".vda", ".icb", ".vst",
	},
	ObjectSettings 		= {}, --for all states. used to store instance data about each object
	ActiveState			= "",
	ActiveStateID 		= 0,
	BuildData			= {}, --this is the build data gleaned from Project.GetBuildData()
	Canvas 				= {
		Backgrounds = {},
		Mouse = {
			X = 0,
			Y = 0,
			Point = point(),
		},
	},
	DebugWindowVisible = false,
	DrawObjects 		= {},
	EventUtil = {
		ObjectHovered 	= nil,
		OnEnterQueue 	= {},
		OnLeaveQueue 	= nil,
		InCanvas 		= false;
	},
	PageOrDialog = Page,
	Fonts = {
		Baumarkt = -1,
	},
	InfoPane = nil,
	Mouse = {
		X = 0,
		Y = 0,
		Point = point(),
	},
	ObjectsByName = {},
	--ObjectCounter = {},
	PulseObjects = {},
	PollObjects = {},
	Ports = { --contains the app, build, system, and all dialogex ports
		[SIM2D.PORT.APP] 		= {},
		[SIM2D.PORT.BUILD] 		= {},
		[SIM2D.PORT.DIALOGEX] 	= {},
		[SIM2D.PORT.SYSTEM] 	= {},
	},
	StateIDs 	= {}, 		--a table whose keys are states names and values are integers
	StatesExist = {}, 		--a table whose keys are states names and values are booleans
	StateProperties = {},  	--a table whose keys are integers (StateIDs) and whose values are tables containing unique state information
};
