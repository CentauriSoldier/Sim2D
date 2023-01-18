--🅻🅾🅲🅰🅻🅸🆉🅰🆃🅸🅾🅽
local ASTAR_MAP_TYPE_HEX_FLAT 			= ASTAR_MAP_TYPE_HEX_FLAT;
local ASTAR_MAP_TYPE_HEX_POINTED 		= ASTAR_MAP_TYPE_HEX_POINTED;
local ASTAR_MAP_TYPE_SQUARE 			= ASTAR_MAP_TYPE_SQUARE;
local ASTAR_MAP_TYPE_TRIANGLE_FLAT 		= ASTAR_MAP_TYPE_TRIANGLE_FLAT;
local ASTAR_MAP_TYPE_TRIANGLE_POINTED	= ASTAR_MAP_TYPE_TRIANGLE_POINTED;
local ASTAR_NODE_ENTRY_COST_BASE		= ASTAR_NODE_ENTRY_COST_BASE;
local ASTAR_NODE_ENTRY_COST_MIN 		= ASTAR_NODE_ENTRY_COST_MIN
local ASTAR_NODE_ENTRY_COST_MAX_RATE 	= ASTAR_NODE_ENTRY_COST_MAX_RATE
local ASTAR_NODE_ENTRY_COST_MAX 		= ASTAR_NODE_ENTRY_COST_MAX
local PROTEAN_BASE_BONUS 				= PROTEAN_BASE_BONUS;
local PROTEAN_BASE_PENALTY 				= PROTEAN_BASE_PENALTY;
local PROTEAN_MULTIPLICATIVE_BONUS 		= PROTEAN_MULTIPLICATIVE_BONUS;
local PROTEAN_MULTIPLICATIVE_PENALTY 	= PROTEAN_MULTIPLICATIVE_PENALTY;
local PROTEAN_ADDATIVE_BONUS 			= PROTEAN_ADDATIVE_BONUS;
local PROTEAN_ADDATIVE_PENALTY 			= PROTEAN_ADDATIVE_PENALTY;
local PROTEAN_VALUE_BASE 				= PROTEAN_VALUE_BASE;
local PROTEAN_VALUE_FINAL 				= PROTEAN_VALUE_FINAL;
local PROTEAN_LIMIT_MIN 				= PROTEAN_LIMIT_MIN;
local PROTEAN_LIMIT_MAX 				= PROTEAN_LIMIT_MAX;

local assert		= assert;
local class 		= class;
local math 			= math;
local protean		= protean;
local rawtype 		= rawtype;
local setmetatable	= setmetatable;
local table 		= table;
local type 			= type;

--🅳🅴🅲🅻🅰🆁🅰🆃🅸🅾🅽🆂
local aStar;
local aStarMap;
local aStarLayer;
local aStarLayerConfig;
local aStarNode;
local aStarAspect;
local aStarPath;
local aStarRover;
local aStarUtil;

--🅵🅸🅴🅻🅳🆂 🆁🅴🅿🅾🆂🅸🆃🅾🆁🆈
local tRepo = {};

local DEFAULT_ASPECT_IMPACTOR_BASE_VALUE = 1;
--[[░█████╗░░██████╗██████╗░███████╗░█████╗░████████╗
	██╔══██╗██╔════╝██╔══██╗██╔════╝██╔══██╗╚══██╔══╝
	███████║╚█████╗░██████╔╝█████╗░░██║░░╚═╝░░░██║░░░
	██╔══██║░╚═══██╗██╔═══╝░██╔══╝░░██║░░██╗░░░██║░░░
	██║░░██║██████╔╝██║░░░░░███████╗╚█████╔╝░░░██║░░░
	╚═╝░░╚═╝╚═════╝░╚═╝░░░░░╚══════╝░╚════╝░░░░╚═╝░░░]]
aStarAspect = class "aStarAspect" {
	__construct = function(this, prot, oAStarNode, sName)
		tRepo[this] = {
			impactor	= protean(DEFAULT_ASPECT_IMPACTOR_BASE_VALUE, 0, 0, 0, 0, 0, 0, 0, 1, nil, true),--a percentage referencing the extremity of the aspect (0%-100%)
			name 		= sName,
			owner 		= oAStarNode,
		};
	end,

	destroy = function(this)
		tRepo[this].impactor:destroy();
		tRepo[this] = nil;
		this = nil;
	end,

	getImpactor = function(this)
		return tRepo[this].impactor;
	end,

	getName = function(this)
		return tRepo[this].name;
	end,

	getOwner = function(this)
		return tRepo[this].owner;
	end,

};

local bHasInit = false;
function aStarAspect.init(cStar, cStarMap, cStarLayer, cStarLayerConfig, cStarNode, cStarPath, cStarRover, cStarUtil)

	if not (bHasInit) then
		aStar 				= cStar;
		aStarMap 			= cStarMap;
		aStarLayer 			= cStarLayer;
		aStarLayerConfig 	= cStarLayerConfig;
		aStarNode 			= cStarNode;
		aStarPath 			= cStarPath;
		aStarRover 			= cStarRover;
		aStarUtil			= cStarUtil;
		bHasInit 			= true;
	end

end

return aStarAspect;
