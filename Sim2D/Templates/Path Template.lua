--[[this is the base enum and MUST remain intact
    in order for Sim2D to function properly. You
    may add to it as much as you wish but DO NOT
    delete or alter existing items.

    All directories in which your app will write
    data should be created in SIM2D_PATH_DIR_WRITE
]]

local USER                          = enum.prep("USER", true);
--directories
USER.DIR                            = enum.prep("DIR", true);
USER.DIR.BASE                       = SIM2D_PATH_USER_DIR_BASE;
USER.DIR.FACTORY                    = SIM2D_PATH_USER_DIR_FACTORY;
USER.DIR.OBJECTS                    = SIM2D_PATH_USER_DIR_OBJECTS;
USER.DIR.FONTS                      = SIM2D_PATH_USER_DIR_FONTS;
--ADD YOUR DIRECTORY PATHS HERE

--files
USER.FILE                           = enum.prep("FILE", true);
USER.FILE.BUILDDATA                 = SIM2D_PATH_USER_FILE_BUILDDATA_FILE;
USER.FILE.PATHS                     = SIM2D_PATH_USER_FILE_PATHS;--this file
--ADD YOUR FILE PATHS HERE

--hand this prepped enum off to Sim2D's 'Enums.lua' file for processing. "You mean execution?"..."Processing"
return USER;
