constant("SIM2D_PATH_DIR_BASE",                     _Scripts.."\\Sim2D");
constant("SIM2D_PATH_DIR_OBJECTS",                  SIM2D_PATH_DIR_BASE.."\\Objects");
constant("SIM2D_PATH_DIR_TEMPLATES",                SIM2D_PATH_DIR_BASE.."\\Templates");
constant("SIM2D_PATH_FILE_PATHS_TEMPLATE",          SIM2D_PATH_DIR_TEMPLATES.."\\Path Template.lua");
constant("SIM2D_PATH_FILE_TYPES",                   SIM2D_PATH_DIR_OBJECTS.."\\Types.lua");
--constant("SIM2D_PATH_USER_DIR_IMAGES",              _Images.."\\Sim2D");

constant("SIM2D_PATH_USER_DIR_BASE",                _Scripts.."\\Sim2D User");
constant("SIM2D_PATH_USER_DIR_FACTORY",             _Scripts.."\\Sim2D User\\Factory");
constant("SIM2D_PATH_USER_DIR_OBJECTS",             _Scripts.."\\Sim2D User\\Objects");
constant("SIM2D_PATH_USER_DIR_FONTS",               _Fonts.."\\Sim2D Auto Registered");


local pUserPaths = SIM2D_PATH_USER_DIR_BASE     .."\\Paths.lua";
local pUserTypes = SIM2D_PATH_USER_DIR_OBJECTS  .."\\Types.lua";
constant("SIM2D_PATH_USER_FILE_BUILDDATA_FILE",     SIM2D_PATH_USER_DIR_BASE.."\\BuildData.lua");
constant("SIM2D_PATH_USER_FILE_PATHS",              File.DoesExist(pUserPaths) and pUserPaths or SIM2D_PATH_FILE_PATHS_TEMPLATE);
constant("SIM2D_PATH_USER_FILE_TYPES",              File.DoesExist(pUserTypes) and pUserTypes or "");


--import the user's project settings
local tDetails  = Project.GetDetails();
local sTitle	= type(tDetails.Title) 	 == "string" 	and tDetails.Title 	    or "Unknown Project";
local sCompany	= type(tDetails.Company) == "string" 	and tDetails.Company    or "Unknown Company";
local bIsGame	= type(tDetails.IsGame)  == "boolean" 	and tDetails.IsGame     or false;
constant("SIM2D_TITLE",     sTitle);
constant("SIM2D_COMPANY",   sCompany);
constant("SIM2D_IS_GAME",   bIsGame);


local sMyGames                  = SIM2D_IS_GAME and "My Games\\" or "";
--set the userdata path for saving/loading info
local nStart, nEnd              = _DesktopFolder:reverse():find("\\");
local pWriteDir                 = _DesktopFolder:sub(1, _DesktopFolder:len() - nStart).."\\Documents\\"..sMyGames..SIM2D_COMPANY.."\\"..SIM2D_TITLE;--TODO sanitize name for Windows
constant("SIM2D_PATH_DIR_WRITE",      pWriteDir);
