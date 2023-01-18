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

--[[███╗░░░███╗░█████╗░██████╗░
	████╗░████║██╔══██╗██╔══██╗
	██╔████╔██║███████║██████╔╝
	██║╚██╔╝██║██╔══██║██╔═══╝░
	██║░╚═╝░██║██║░░██║██║░░░░░
	╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝░░░░░]]
aStarMap = class "aStarMap" {

	__construct = function(this, prot, oAStar, sName, nMapType, tLayerConfigs, nWidth, nHeight, ...)
		--local tLayerConfigs = arg or {...}; --TODO check the keywords

		--check the input
		assert(aStarUtil.isNonBlankString(sName), 	"Argument 1: aStar map name must be a non-blank string.");
		assert(aStarUtil.mapTypeIsValid(nMapType), 	"Argument 2: map type is invalid.");
		assert(aStarUtil.mapDimmIsValid(nWidth),	"Argument 4: map width must be positive integer.");
		assert(aStarUtil.mapDimmIsValid(nHeight),	"Argument 5: map height must be positive integer.");
		--TODO assert(#tLayerConfigs > 0)
		--TODO assert(type(oLayerConfigs) == "aStarLayerConfig", 	"Argument 3: must be an aStarLayerConfig object.\nGot type, '"..type(type(tLayerConfig)).."'");

		--create the map table
		tRepo[this] = {
			layers 			= {},--(ORDERED BY ID)
			layersDecoy		= {},--a decoy table for returning layers to the client
			layersByName	= {},
			name 			= sName,
			owner 			= oAStar,
			type			= nMapType,
			width 			= nWidth,
			height			= nHeight,
		};

		local tFields 	= tRepo[this];

		aStarUtil.setupActualDecoy(	tFields.layers,
									tFields.layersDecoy,
									"Attempting to modifer read-only layers table for map, '"..tFields.name.."'.");

		--create the layers and their nodes
		for nLayerID, oConfig in pairs(tLayerConfigs) do
			--create the actual layer elements
			local oLayer = aStarLayer(this, nLayerID, oConfig, nWidth, nHeight);
			tFields.layers[nLayerID] = oLayer;
			tFields.layersByName[oConfig:getName()] = oLayer;
		end

	end,

	destroy = function(this)

		--destroy each layer
		for _, oLayer in pairs(tRepo[this].layers) do
			oLayer:destroy();
		end

		tRepo[this] = nil;
		this = nil;
	end,

	getHeight = function(this)
		return tRepo[this].height;
	end,

	getLayer = function(this, sLayer)
		assert(rawtype(sLayer) == "string", "Layer name must be of type string.");
		return tRepo[this].layersByName[sLayer:upper()] or nil;
	end,

	getLayers = function(this)
		return tRepo[this].layersDecoy;
	end,

	getName = function(this)
		return tRepo[this].name;
	end,

	getNode = function(this, sLayer, nX, nY)
		local oLayer = tRepo[this].layersByName[sLayer] or nil;

		if (oLayer) then
			return tRepo[this].layersByName[sLayer]:getNode(nX, nY);
		end

	end,

	getOwner = function(this)
		return tRepo[this].owner;
	end,

	getSize = function(this)
		local tFields = tRepo[this];
		return {width = tFields.width, height = tFields.height};
	end,

	getType = function(this)
		return tRepo[this].type;
	end,

	getWidth = function(this)
		return tRepo[this].width;
	end,
};

local bHasInit = false;
function aStarMap.init(cStar, cStarLayer, cStarLayerConfig, cStarNode, cStarAspect, cStarPath, cStarRover, cStarUtil)

	if not (bHasInit) then
		aStar 				= cStar;
		aStarLayer 			= cStarLayer;
		aStarLayerConfig 	= cStarLayerConfig;
		aStarNode 			= cStarNode;
		aStarAspect 		= cStarAspect;
		aStarPath 			= cStarPath;
		aStarRover 			= cStarRover;
		aStarUtil			= cStarUtil;
		bHasInit 			= true;
	end

end

return aStarMap;
