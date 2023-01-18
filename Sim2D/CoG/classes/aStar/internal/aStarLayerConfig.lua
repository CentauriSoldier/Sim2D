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

--[[██╗░░░░░░█████╗░██╗░░░██╗███████╗██████╗░  ░█████╗░░█████╗░███╗░░██╗███████╗██╗░██████╗░
	██║░░░░░██╔══██╗╚██╗░██╔╝██╔════╝██╔══██╗  ██╔══██╗██╔══██╗████╗░██║██╔════╝██║██╔════╝░
	██║░░░░░███████║░╚████╔╝░█████╗░░██████╔╝  ██║░░╚═╝██║░░██║██╔██╗██║█████╗░░██║██║░░██╗░
	██║░░░░░██╔══██║░░╚██╔╝░░██╔══╝░░██╔══██╗  ██║░░██╗██║░░██║██║╚████║██╔══╝░░██║██║░░╚██╗
	███████╗██║░░██║░░░██║░░░███████╗██║░░██║  ╚█████╔╝╚█████╔╝██║░╚███║██║░░░░░██║╚██████╔╝
	╚══════╝╚═╝░░╚═╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝  ░╚════╝░░╚════╝░╚═╝░░╚══╝╚═╝░░░░░╚═╝░╚═════╝░]]
aStarLayerConfig = class "aStarLayerConfig" {

	__construct = function (this, prot, sName, ...)
		local tInputAspects = {...} or arg;

		--TODO assertions | also make sure each aspect is in the aStar Object before adding to the layer

		tRepo[this] = {
			aspects = {}, --TODO make decoy table for this
			name 	= sName:upper(),
		};

		--add all user aspect
		local tAspects = tRepo[this].aspects;
		for _, sAspect in pairs(tInputAspects) do
			tAspects[#tAspects + 1] = sAspect:upper();
		end

	end,
	getName = function(this)
		return tRepo[this].name;
	end,
	getAspect = function(this, sAspect)--TODO CHECK TYPE AND UPPER THIS PARAMETER
		return tRepo[this].aspects[sAspect] or nil;
	end,
	getAspects = function(this)
		return tRepo[this].aspects; --TODO decoy this
	end,
	hasAspect = function(this, sAspect)--TODO CHECK TYPE AND UPPER THIS PARAMETER
		return rawtype(tRepo[this].aspects[sAspect] ~= nil);
	end
};

local bHasInit = false;
function aStarLayerConfig.init(cStar, cStarMap, cStarLayer, cStarNode, cStarAspect, cStarPath, cStarRover, cStarUtil)

	if not (bHasInit) then
		aStar 		= cStar;
		aStarMap 	= cStarMap;
		aStarLayer 	= cStarLayer;
		aStarNode 	= cStarNode;
		aStarAspect = cStarAspect;
		aStarPath 	= cStarPath;
		aStarRover 	= cStarRover;
		aStarUtil	= cStarUtil;
		bHasInit 	= true;
	end

end

return aStarLayerConfig;
