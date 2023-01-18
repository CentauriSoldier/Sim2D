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

--[[██╗░░░░░░█████╗░██╗░░░██╗███████╗██████╗░
	██║░░░░░██╔══██╗╚██╗░██╔╝██╔════╝██╔══██╗
	██║░░░░░███████║░╚████╔╝░█████╗░░██████╔╝
	██║░░░░░██╔══██║░░╚██╔╝░░██╔══╝░░██╔══██╗
	███████╗██║░░██║░░░██║░░░███████╗██║░░██║
	╚══════╝╚═╝░░╚═╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝]]
aStarLayer = class "aStarLayer" {
	__construct = function(this, prot, oAStarMap, nLayerID, oConfig, nWidth, nHeight)
		tRepo[this] = {
			id 			= nLayerID,
			--config 		= oConfig,
			owner 		= oAStarMap,
			name		= oConfig:getName(),
			nodes 		= {},
			nodesDecoy	= {}, --a decoy table for returning to the client
		};

		local tFields = tRepo[this];
		local tNodes = tFields.nodes;

		aStarUtil.setupActualDecoy(	tFields.nodes,
									tFields.nodesDecoy,
									"Attempting to modify read-only nodes table for layer, '"..tFields.name.."'.");

		--get the aspects that will be on the node
		local tAspects = oConfig:getAspects();

		--create the nodes
		for x = 1, nWidth do
			tNodes[x] = {};

			for y = 1, nHeight do
				tNodes[x][y] = aStarNode(this, x, y, tAspects);
			end

		end

	end,

	containsRoverAt = function(this, oRover, nX, nY)
		local bRet		= false;
		local tFields 	= tRepo[this];
		local tNodes 	= tFields.nodes;

		if (tNodes[nX] and tNodes[nX][nY]) then
			bRet = tNodes[nX][nY]:containsRover(oRover);
		end

		return bRet;
	end,

	createRoverAt = function(this, nX, nY)
		local tFields 	= tRepo[this];
		local tNodes 	= tFields.nodes;

		if (tNodes[nX] and tNodes[nX][nY]) then
			return tNodes[nX][nY]:createRover();
		end

	end,

	destroy = function(this)

		--destroy each node
		for x, tNodes in pairs(tRepo[this].nodes) do

			for y, oNode in pairs(tNodes) do
				oNode:destroy();
			end

		end

		tRepo[this] = nil;
		this = nil;
	end,

	getName = function(this)
		return tRepo[this].name;
	end,

	getNode = function(this, nX, nY)
		local tNodes = tRepo[this].nodesDecoy[nX];

		if (tNodes) then
			return tNodes[nY] or nil;
		end

	end,

	getNodes = function(this)
		return tRepo[this].nodesDecoy;
	end,

	getOwner = function(this)
		return tRepo[this].owner;
	end,

	hasNode = function(this, oNode)
		assert(type(oNode) == "aStarNode", "Port must be of type, aStarNode.");
		return oNode:getOwner() == this;
	end,

	hasNodeAt = function(this, nX, nY)
		local tNodes = tRepo[this].nodes;
		return rawtype(tNodes[nX]) ~= "nil" and rawtype(tNodes[nX][nY]) ~= "nil";
	end,
};

local bHasInit = false;
function aStarLayer.init(cStar, cStarMap, cStarLayerConfig, cStarNode, cStarAspect, cStarPath, cStarRover, cStarUtil)

	if not (bHasInit) then
		aStar 				= cStar;
		aStarMap 			= cStarMap;
		aStarLayerConfig 	= cStarLayerConfig;
		aStarNode 			= cStarNode;
		aStarAspect 		= cStarAspect;
		aStarPath 			= cStarPath;
		aStarRover 			= cStarRover;
		aStarUtil			= cStarUtil;
		bHasInit 			= true;
	end

end

return aStarLayer;
