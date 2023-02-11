--preps the tables for use in creating the TYPE enum
local function prepTypesTables()
    local tSim2DTypes = dofile(SIM2D_PATH_FILE_TYPES);
    local tUserTypes  = File.DoesExist(SIM2D_PATH_USER_FILE_TYPES) and dofile(SIM2D_PATH_USER_FILE_TYPES) or {};
    local tTypeNames    = {};
    local tTypeValues   = {};

    --Sim2D types
    for _, tType in pairs(tSim2DTypes) do

        for sName, sValue in pairs(tType) do
            tTypeNames[#tTypeNames + 1]     = sName;
            tTypeValues[#tTypeValues + 1]   = sValue;
        end

    end

    --Sim2D types
    for _, tType in pairs(tUserTypes) do

        for sName, sValue in pairs(tType) do
            tTypeNames[#tTypeNames + 1]     = sName;
            tTypeValues[#tTypeValues + 1]   = sValue;
        end

    end

    return {
        Names   = tTypeNames,
        Values  = tTypeValues,
    };
end

--SIM2D
local SIM2D                             = enum.prep("SIM2D");
--ams object
SIM2D.AMS_OBJECT                        = enum.prep("AMS_OBJECT", true);
SIM2D.AMS_OBJECT.DELIMITER              = " ";
SIM2D.AMS_OBJECT.DELIMITER_LENGTH       = #SIM2D.AMS_OBJECT.DELIMITER;
SIM2D.AMS_OBJECT.PREFIX                 = "s2d";
SIM2D.AMS_OBJECT.PREFIX_LENGTH          = #SIM2D.AMS_OBJECT.PREFIX;--length values must equal associated string lengths
--canvas
SIM2D.CANVAS                            = enum.prep("CANVAS", true);
SIM2D.CANVAS.NAME                       = "__SIM2D_CANVAS__";--the canvas on the page MUST be named this
SIM2D.CANVAS.COLOR                      = Color.RGBA(0, 0, 0, 0);
--layer (sub divisions of each stratum)
SIM2D.LAYER                             = enum.prep("LAYER", true);
--SIM2D.LAYER.BACKGROUND                  = enum.prep("BACKGROUND", true);
SIM2D.LAYER.BACKGROUND_BACK             = 1;
SIM2D.LAYER.BACKGROUND_MID              = 2;
SIM2D.LAYER.BACKGROUND_FRONT            = 3;
--SIM2D.LAYER.MIDGROUND                   = enum.prep("MIDGROUND", true);
SIM2D.LAYER.MIDGROUND_BACK              = 4;
SIM2D.LAYER.MIDGROUND_MID               = 5;
SIM2D.LAYER.MIDGROUND_FRONT             = 6;
--SIM2D.LAYER.FOREGROUND                  = enum.prep("FOREGROUND", true);
SIM2D.LAYER.FOREGROUND_BACK             = 7;
SIM2D.LAYER.FOREGROUND_MID              = 8;
SIM2D.LAYER.FOREGROUND_FRONT            = 9;
--SIM2D.LAYER.COUNT                       = 9;
--SIM2D.LAYER.DEFAULT                     = 5;
--led
SIM2D.LED                               = enum.prep("LED", true);
SIM2D.LED.STATE                         = enum.prep("STATE", true);
SIM2D.LED.STATE.OFF                     = 0;
SIM2D.LED.STATE.ON                      = 1;
SIM2D.LED.STATE.PULSE                   = 2;
SIM2D.LED.STATE.BLINK                   = 3;
SIM2D.LED.STATE.FLICKER                 = 4;
--port
SIM2D.PORT                              = enum.prep("PORT", true);
SIM2D.PORT.APP                          = 0;
SIM2D.PORT.BUILD                        = 1;
SIM2D.PORT.DIALOGEX                     = 2;
SIM2D.PORT.SYSTEM                       = 3;
--pulse
SIM2D.PULSE                             = enum.prep("PULSE", true);
SIM2D.PULSE.OFF                         = -1;
SIM2D.PULSE.ULTRA_SLOW                  = enum.prep("ULTRA_SLOW", true);
SIM2D.PULSE.ULTRA_SLOW.ID               = 34583;
SIM2D.PULSE.ULTRA_SLOW.INTERVAL         = 500;
SIM2D.PULSE.SLOW                        = enum.prep("SLOW", true);
SIM2D.PULSE.SLOW.ID                     = 34584;
SIM2D.PULSE.SLOW.INTERVAL               = 250;
SIM2D.PULSE.MEDIUM                      = enum.prep("MEDIUM", true);
SIM2D.PULSE.MEDIUM.ID                   = 34585;
SIM2D.PULSE.MEDIUM.INTERVAL             = 100;
SIM2D.PULSE.FAST                        = enum.prep("FAST", true);
SIM2D.PULSE.FAST.ID                     = 34586;
SIM2D.PULSE.FAST.INTERVAL               = 50;
SIM2D.PULSE.ULTRA_FAST                  = enum.prep("ULTRA_FAST", true);
SIM2D.PULSE.ULTRA_FAST.ID               = 34587;
SIM2D.PULSE.ULTRA_FAST.INTERVAL         = 17;
--local eSoundChannel     = enum("CHANNEL",       {"BACKGROUND", "EFFECTS", "NARRATION", "USER1", "USER2", "USER3", "USER4", "ALL"}, {5, 0, 6, 1, 2, 3, 4, -3}, true);
SIM2D.SOUND                             = enum.prep("SOUND", true);
SIM2D.SOUND.CHANNEL                     = enum.prep("CHANNEL", true);
--SIM2D.SOUND.CHANNEL.AUX2                = 0;--RESERVED FOR HOVER, DOWN AND CLICK SOUNDS FOR AMS OBJECTS
SIM2D.SOUND.CHANNEL.MUSIC               = 1;
SIM2D.SOUND.CHANNEL.SFX                 = 2;
SIM2D.SOUND.CHANNEL.SFX2                = 3;
SIM2D.SOUND.CHANNEL.AUX                 = 4;
SIM2D.SOUND.CHANNEL.AMBIENT             = 5;
SIM2D.SOUND.CHANNEL.VOICE               = 6;
SIM2D.SOUND.CHANNEL.ALL                 = -3
--stratum (1 for drawing game objects, 2 for drawing effects, 3 for drawing UI objects)
--these serve as super-layers. These are drawn and polled in their ordinal order. These stratum are further sub-divided by layers (listed below).
SIM2D.STRATUM                           = enum.prep("STRATUM", true);
SIM2D.STRATUM.GO                        = 1;
SIM2D.STRATUM.EFFECT                    = 2;
SIM2D.STRATUM.UI                        = 3;
--SIM2D.STRATUM.COUNT                     = 3;
--SIM2D.STRATUM.DEFAULT                   = 1;
--timer
SIM2D.TIMER                             = enum.prep("TIMER", true);
SIM2D.TIMER.DRAW                        = enum.prep("DRAW", true);
SIM2D.TIMER.DRAW.ID                     = 34581;
SIM2D.TIMER.DRAW.INTERVAL               = 17;
SIM2D.TIMER.EVENT                       = enum.prep("EVENT", true);
SIM2D.TIMER.EVENT.ID                    = 34580;
SIM2D.TIMER.EVENT.INTERVAL              = 50;
--path
SIM2D.PATH                              = enum.prep("PATH", true);
--sim2d
--SIM2D.PATH.SIM2D                        = enum.prep("SIM2D", true);
SIM2D.PATH.DIR                          = enum.prep("DIR", true);
SIM2D.PATH.DIR.BASE                     = SIM2D_PATH_DIR_BASE;
SIM2D.PATH.DIR.OBJECTS                  = SIM2D_PATH_DIR_OBJECTS;
SIM2D.PATH.DIR.TEMPLATES                = SIM2D_PATH_DIR_TEMPLATES;
SIM2D.PATH.DIR.WRITE                    = SIM2D_PATH_DIR_WRITE;
--files
SIM2D.PATH.FILE                         = enum.prep("FILE", true);
SIM2D.PATH.FILE.PATHS_TEMPLATE          = SIM2D_PATH_FILE_PATHS_TEMPLATE;
--user
SIM2D.PATH.USER                         = dofile(SIM2D_PATH_USER_FILE_PATHS);
--var
SIM2D.VAR                               = enum.prep("VAR", true);
SIM2D.VAR.IS_GAME                       = true;
SIM2D.VAR.PATH                          = "ePath";--????
--type (used to during object creation to identify item type)
local tTypeTables                       = prepTypesTables();
SIM2D.TYPE                              = enum("TYPE", tTypeTables.Names, tTypeTables.Values, true); --Note: DO NOT depend on ordinal position as the order is unreliable! TODO redo this to have the structure as PATH where there is a USER subenum
--finalize the enum
SIM2D();
