--these are declared in the Sim2D Contants.lua file.
local pWriteDir                 = SIM2D_WRITE_DIR;
local pSaveDir                  = SIM2D_SAVE_DIR;
local pSim2D                    = SIM2D_DIR;
local pObjects                  = SIM2D_OBJECTS_DIR;
local pTemplates                = SIM2D_TEMPLATES_DIR;
local pWriteDir                 = SIM2D_WRITE_DIR;
local pSaveDir                  = SIM2D_SAVE_DIR;
local ePathDir                  = enum("DIR", {"BASE", "OBJECTS", "TEMPLATES", "WRITE", "SAVE"}, {pSim2D, pObjects, pTemplates, pWriteDir, pSaveDir}, true);
local ePathFile                 = enum("FILE", {"PATHS", "PATHS_TEMPLATE"}, {SIM2D_PATHS_FILE, SIM2D_TEMPLATE_FILE});
return enum(
    "SIM2D",
    {"DIR",     "FILE"},
    {ePathDir,  ePathFile},
    true
);
