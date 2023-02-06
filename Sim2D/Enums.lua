--preps the tables for use in creating the TYPE enum
local function prepTypesTables(pSim2DTypes, pUserTypes)
    local tSim2DTypes = dofile(pSim2DTypes);
    local tUserTypes  = dofile(pUserTypes);
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

--ams object
local eAMSObject        = enum("AMS_OBJECT",    {"DELIMITER", "DELIMITER_LENGTH", "PREFIX", "PREFIX_LENGTH"}, {" ", 1, "s2d", 3}); --length values must equal associated string lengths
--canvas
local eCanvas           = enum("CANVAS",        {"NAME", "COLOR"}, {"__SIM2D_CANVAS__", Color.RGBA(0, 0, 0, 0)}, true);--the canvas on the page MUST be named this
--layer (sub divisions of each stratum)
local eLayerBackground  = enum("BACKGROUND",    {"BACK", "MID", "FRONT"}, {1, 2, 3}, true);
local eLayerMidground   = enum("MIDGROUND",     {"BACK", "MID", "FRONT"}, {4, 5, 6}, true);
local eLayerForeground  = enum("FOREGROUND",    {"BACK", "MID", "FRONT"}, {7, 8, 9}, true);
local eLayer            = enum("LAYER",         {"COUNT", "BACKGROUND", "MIDGROUND", "FOREGROUND", "DEFAULT"}, {9, eLayerBackground, eLayerMidground, eLayerForeground, 5}, true);
--led
local eLEDState         = enum("STATE",         {"OFF", "ON", "PULSE", "BLINK", "FLICKER"}, {0, 1, 2, 3, 4}, true);
local eLED              = enum("LED",           {"STATE"}, {eLEDState}, true);
--port
local ePort             = enum("PORT",          {"APP", "BUILD", "DIALOGEX", "SYSTEM"}, {0, 1, 2, 3}, true);
--pulse
local ePulseUltraSlow   = enum("ULTRA_SLOW",    {"ID", "INTERVAL"}, {34583, 500},   true);
local ePulseSlow        = enum("SLOW",          {"ID", "INTERVAL"}, {34584, 250},   true);
local ePulseMedium      = enum("MEDIUM",        {"ID", "INTERVAL"}, {34585, 100},   true);
local ePulseFast        = enum("FAST",          {"ID", "INTERVAL"}, {34586, 50},    true);
local ePulseUltraFast   = enum("ULTRA_FAST",    {"ID", "INTERVAL"}, {34587, 17},    true); --17 = ~60 FPS
local ePulse            = enum("PULSE",         {"OFF", "ULTRA_SLOW", "SLOW", "MEDIUM", "FAST", "ULTRA_FAST"},
                                                {-1, ePulseUltraSlow, ePulseSlow, ePulseMedium, ePulseFast, ePulseUltraFast}, true);
--sound
--local eSoundChannel     = enum("CHANNEL",       {"BACKGROUND", "EFFECTS", "NARRATION", "USER1", "USER2", "USER3", "USER4", "ALL"}, {5, 0, 6, 1, 2, 3, 4, -3}, true);
local eSoundChannel     = enum("CHANNEL",       {"AMBIENT", "MUSIC", "SFX", "SFX2", "VOICE", "AUX", "AUX2", "ALL"}, {5, 0, 6, 1, 2, 3, 4, -3}, true);
local eSound            = enum("SOUND",         {"CHANNEL"}, {eSoundChannel}, true);
--stratum (1 for drawing game objects, 2 for drawing effects, 3 for drawing UI objects)
--these serve as super-layers. These are drawn and polled in their ordinal order. These stratum are further sub-divided by layers (listed below).
local eStratum          = enum("STRATUM",       {"GO", "EFFECT", "UI", "COUNT", "DEFAULT"}, {1, 2, 3, 3, 1}, true);
--timer
local eTimerDraw        = enum("DRAW",          {"ID", "INTERVAL"}, {34581, 17}, true);
local eTimerEvent       = enum("EVENT",         {"ID", "INTERVAL"}, {34580, 50}, true);
local eTimer            = enum("TIMER",         {"DRAW", "EVENT"}, {eTimerDraw, eTimerEvent}, true);
--path
local ePath             = enum("PATH", {"SIM2D", "USER"}, {dofile(SIM2D_PATHS_FILE), dofile(SIM2D_USER_PATHS_FILE)}, true);
--var
local eVar              = enum("VAR",{"IS_GAME", "PATH"}, {true,    "ePath"}, true);--TODO clean this up......
--type (used to during object creation to identify item type)
local tTypeTables       = prepTypesTables(SIM2D_OBJECTS_DIR.."\\Types.lua", SIM2D_USER_OBJECTS_DIR.."\\Types.lua");
local eType             = enum("TYPE", tTypeTables.Names, tTypeTables.Values, true); --Note: DO NOT depend on ordinal position as the order is unreliable!
--SIM2D
enum("SIM2D",   {"AMS_OBJECT",  "CANVAS",   "LAYER",    "LED",  "PORT", "PULSE",    "SOUND",    "STRATUM",  "TIMER",    "TYPE",     "PATH",     "VAR"},
                {eAMSObject,    eCanvas,    eLayer,     eLED,   ePort,  ePulse,     eSound,     eStratum,   eTimer,     eType,      ePath,      eVar});
