--[[this is the base enum and MUST remain intact
    in order for Sim2D to function properly. You
    may add to these as much as you wish but Do NOT
    delete these base values or alter existing items.]]
local pUserDir      = SIM2D_USER_DIR;
local pFactory      = SIM2D_USER_FACTORY_DIR;
local pObjects      = SIM2D_USER_OBJECTS_DIR;
local pBuildData    = SIM2D_USER_BUILD_DATA_FILE;
local pPaths        = SIM2D_USER_PATHS_FILE;
local eDir  = enum("DIR",   {"USER", "FACTORY", "OBJECTS"}, {pUserDir, pFactory, pObjects}, true);
local eFile = enum("FILE", {"BUILDDATA", "PATHS"}, {pBuildData, "PATHS"}, true);
return enum(
    "USER",
    {"DIR", "FILE"},
    {eDir,  eFile},
    true
);
