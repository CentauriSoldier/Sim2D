constant("SIM2D_DIR",            _Scripts.."\\Sim2D");
constant("SIM2D_OBJECTS_DIR",    SIM2D_DIR.."\\Objects");
constant("SIM2D_TEMPLATES_DIR",  SIM2D_DIR.."\\Templates");
constant("SIM2D_TEMPLATE_FILE",  SIM2D_TEMPLATES_DIR.."\\Path Template.lua");
constant("SIM2D_PATHS_FILE",     SIM2D_DIR.."\\Paths.lua");

constant("SIM2D_USER_DIR",                  _Scripts.."\\Sim2D_User");
constant("SIM2D_USER_FACTORY_DIR",          _Scripts.."\\Sim2D_User\\Factory");
constant("SIM2D_USER_OBJECTS_DIR",          _Scripts.."\\Sim2D_User\\Objects");
constant("SIM2D_USER_BUILD_DATA_FILE",      _Scripts.."\\Sim2D_User\\BuildData.lua");
local pUserPaths = SIM2D_USER_DIR.."\\Paths.lua";
constant("SIM2D_USER_PATHS_FILE", File.DoesExist(pUserPaths) and pUserPaths or SIM2D_TEMPLATE_FILE);

--import the user's project settings
local tDetails				    = Project.GetDetails();
local sTitle			        = type(tDetails.Title) 	 == "string" 	and tDetails.Title 	    or "Unknown Project";
local sCompany			        = type(tDetails.Company) == "string" 	and tDetails.Company    or "Unknown Company";
local bIsGame			        = type(tDetails.IsGame)  == "boolean" 	and tDetails.IsGame     or false;
constant("SIM2D_TITLE",     sTitle);
constant("SIM2D_COMPANY",   sCompany);
constant("SIM2D_IS_GAME",   bIsGame);

local sMyGames                  = SIM2D_IS_GAME and "My Games\\" or "";
--set the userdata path for saving/loading info
local nStart, nEnd              = _DesktopFolder:reverse():find("\\");
local pWriteDir                 = _DesktopFolder:sub(1, _DesktopFolder:len() - nStart).."\\Documents\\"..sMyGames..SIM2D_COMPANY.."\\"..SIM2D_TITLE;--TODO sanitize name for Windows
local pSaveDir                  = pWriteDir.."\\Save";

constant("SIM2D_WRITE_DIR", pWriteDir);
constant("SIM2D_SAVE_DIR", pSaveDir);
