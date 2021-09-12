SIM2D								= const("SIM2D", 				"", true);

SIM2D.SOUND_CHANNEL					= CHANNEL_USER4; --this channel MUST be reserved for Sim2D
--TODO add more channels--basically, sim2d will take over AMS completely
SIM2D.CANVAS						= "__sim2d canvas__";--the canvas on the page MUST be named this

SIM2D.TYPE							= const("SIM2D.TYPE", 			"", true); --used to during object creation to identify item type

SIM2D.TIMER							= const("SIM2D.TIMER", 			"", true);
SIM2D.TIMER.EVENT					= const("SIM2D.TIMER.EVENT", 	"", true);
SIM2D.TIMER.EVENT.ID				= 34580;
SIM2D.TIMER.EVENT.INTERVAL			= 50;
SIM2D.TIMER.DRAW					= const("SIM2D.TIMER.DRAW", 	"", true);
SIM2D.TIMER.DRAW.ID					= 34581;
SIM2D.TIMER.DRAW.INTERVAL			= 17;

SIM2D.PULSE							= const("SIM2D.PULSE", 		"", true);
SIM2D.PULSE.OFF						= -1;
SIM2D.PULSE.ULTRA_SLOW				= const("SIM2D.PULSE.ULTRA_SLOW", "", true);
SIM2D.PULSE.ULTRA_SLOW.ID			= 34583;
SIM2D.PULSE.ULTRA_SLOW.INTERVAL		= 500;
SIM2D.PULSE.SLOW 					= const("SIM2D.PULSE.SLOW", 		"", true);
SIM2D.PULSE.SLOW.ID					= 34584;
SIM2D.PULSE.SLOW.INTERVAL			= 250;
SIM2D.PULSE.MEDIUM					= const("SIM2D.PULSE.MEDIUM",		"", true);
SIM2D.PULSE.MEDIUM.ID				= 34585;
SIM2D.PULSE.MEDIUM.INTERVAL			= 100;
SIM2D.PULSE.FAST					= const("SIM2D.PULSE.FAST",		"", true);
SIM2D.PULSE.FAST.ID					= 34586;
SIM2D.PULSE.FAST.INTERVAL			= 50;
SIM2D.PULSE.ULTRA_FAST				= const("SIM2D.PULSE.ULTRA_FAST",	"", true);
SIM2D.PULSE.ULTRA_FAST.ID			= 34587;
SIM2D.PULSE.ULTRA_FAST.INTERVAL 	= 17; -- ~60 FPS

--these serve as super-layers. These are drawn and polled in their ordinal order. These stratum are further sub-divided by layers (listed below).
SIM2D.STRATUM						= const("SIM2D.STRATUM");
SIM2D.STRATUM.GO					= 1; --for drawing game objects
SIM2D.STRATUM.EFFECT				= 2; --for drawing effects
SIM2D.STRATUM.UI					= 3; --for drawing UI objects
SIM2D.STRATUM.COUNT					= 3;
SIM2D.STRATUM.DEFAULT				= SIM2D.STRATUM.GO;

SIM2D.LAYER 						= const("SIM2D.LAYER", 		"", true);
SIM2D.LAYER.COUNT					= 9;
SIM2D.LAYER.BACKGROUND				= const("SIM2D.LAYER.BACKGROUND",	"", true);
SIM2D.LAYER.BACKGROUND_BACK			= 1;
SIM2D.LAYER.BACKGROUND_MID			= 2;
SIM2D.LAYER.BACKGROUND_FRONT		= 3;
SIM2D.LAYER.MIDGROUND				= const("SIM2D.LAYER.MIDGROUND",	"", true);
SIM2D.LAYER.MIDGROUND_BACK			= 4;
SIM2D.LAYER.MIDGROUND_MID			= 5;
SIM2D.LAYER.MIDGROUND_FRONT			= 6;
SIM2D.LAYER.FOREGROUND				= const("SIM2D.LAYER.FOREGROUND",	"", true);
SIM2D.LAYER.FOREGROUND_BACK			= 7;
SIM2D.LAYER.FOREGROUND_MID			= 8;
SIM2D.LAYER.FOREGROUND_FRONT		= 9;
SIM2D.LAYER.DEFAULT					= SIM2D.LAYER.MIDGROUND_MID;

SIM2D.AMS_OBJECT					= const("SIM2D.AMS_OBJECT");
SIM2D.AMS_OBJECT.DELIMITER			= " ";
SIM2D.AMS_OBJECT.DELIMITER_LENGTH	= SIM2D.AMS_OBJECT.DELIMITER:len();
SIM2D.AMS_OBJECT.PREFIX 			= "s2d";
SIM2D.AMS_OBJECT.PREFIX_LENGTH 		= SIM2D.AMS_OBJECT.PREFIX:len();

SIM2D.PORT						= const("SIM2D.PORT",	"", true);
SIM2D.PORT.APP					= 0;
SIM2D.PORT.BUILD				= 1;
SIM2D.PORT.DIALOGEX				= 2;
SIM2D.PORT.SYSTEM				= 3;
