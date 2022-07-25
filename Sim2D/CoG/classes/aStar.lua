--[[
Alter these to fit your game.
]]
--[[enum("ASTAR", 			{"MAP", "NODE", "PATH", "ROVER"});
enum("ASTAR_LAYER", 	{"SUBTERRAIN", "SUBMARINE", "MARINE", "TERRAIN", "AIR", "SPACE"}, {
	enum("ASTAR_LAYER_SUBTERRAIN", 	{"sd", "sd", "sd", "sd", "sd"}),
	enum("ASTAR_LAYER_SUBMARINE", 	{"PRESSURE", "SALINITY", "sd", "sd", "sd"}),
	enum("ASTAR_LAYER_MARINE", 		{"sd", "sd", "sd", "sd", "sd"}),
	enum("ASTAR_LAYER_TERRAIN", 	{"AQUIFER", "COMPACTION", "DETRITUS", "FORAGEABILITY", "FORESTATION",
							 		 "GRADE", "ICINESS", "PALUDALISM", "ROCKINESS", "ROAD", "SNOWINESS",
							 		 "TEMPERATURE", "TOXICITY", "VERDURE"}),
	enum("ASTAR_LAYER_AIR", 		{"sd", "sd", "sd", "sd", "sd"}),
	enum("ASTAR_LAYER_SPACE", 		{"sd", "sd", "sd", "sd", "sd"}),
});
]]
--🅲🅾🅽🆂🆃🅰🅽🆃🆂
constant("ASTAR_MAP_TYPE_HEX_FLAT", 			0);
constant("ASTAR_MAP_TYPE_HEX_POINTED", 			1);
constant("ASTAR_MAP_TYPE_SQUARE", 			2);
constant("ASTAR_MAP_TYPE_TRIANGLE_FLAT", 	3);
constant("ASTAR_MAP_TYPE_TRIANGLE_POINTED", 4);

--🅻🅾🅲🅰🅻🅸🆉🅰🆃🅸🅾🅽
local ASTAR_MAP_TYPE_HEX_FLAT 			= ASTAR_MAP_TYPE_HEX_FLAT;
local ASTAR_MAP_TYPE_HEX_POINTED 		= ASTAR_MAP_TYPE_HEX_POINTED;
local ASTAR_MAP_TYPE_SQUARE 			= ASTAR_MAP_TYPE_SQUARE;
local ASTAR_MAP_TYPE_TRIANGLE_FLAT 		= ASTAR_MAP_TYPE_TRIANGLE_FLAT;
local ASTAR_MAP_TYPE_TRIANGLE_POINTED	= ASTAR_MAP_TYPE_TRIANGLE_POINTED
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
local aStarMap;
local aStarLayer;
local aStarLayerConfig;
local aStarNode;
local aStarAspect;
local aStarPath;
local aStarRover;

--🅵🅸🅴🅻🅳🆂 🆁🅴🅿🅾🆂🅸🆃🅾🆁🆈
local tRepo = {
	aspects	= {},
	aStars 	= {},
	maps	= {},
	layers 	= {},
	nodes	= {},
	paths 	= {},
	rovers	= {},
	configs = {},
};

--[[██╗░░██╗███████╗██╗░░░░░██████╗░███████╗██████╗░
	██║░░██║██╔════╝██║░░░░░██╔══██╗██╔════╝██╔══██╗
	███████║█████╗░░██║░░░░░██████╔╝█████╗░░██████╔╝
	██╔══██║██╔══╝░░██║░░░░░██╔═══╝░██╔══╝░░██╔══██╗
	██║░░██║███████╗███████╗██║░░░░░███████╗██║░░██║
	╚═╝░░╚═╝╚══════╝╚══════╝╚═╝░░░░░╚══════╝╚═╝░░╚═╝

	███████╗██╗░░░██╗███╗░░██╗░█████╗░████████╗██╗░█████╗░███╗░░██╗░██████╗
	██╔════╝██║░░░██║████╗░██║██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║██╔════╝
	█████╗░░██║░░░██║██╔██╗██║██║░░╚═╝░░░██║░░░██║██║░░██║██╔██╗██║╚█████╗░
	██╔══╝░░██║░░░██║██║╚████║██║░░██╗░░░██║░░░██║██║░░██║██║╚████║░╚═══██╗
	██║░░░░░╚██████╔╝██║░╚███║╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║██████╔╝
	╚═╝░░░░░░╚═════╝░╚═╝░░╚══╝░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝╚═════╝░]]


local function mapDimmIsValid(nValue)
	return rawtype(nValue) 	== "number" and nValue	> 0 and nValue == math.floor(nValue);
end


local function mapTypeIsValid(nType)
	return 	rawtype(nType) == "number" and
			(	nType == ASTAR_MAP_TYPE_HEX_FLAT 		or
				nType == ASTAR_MAP_TYPE_HEX_POINTED 	or
				nType == ASTAR_MAP_TYPE_SQUARE		or
				nType == ASTAR_MAP_TYPE_HEX_TRIANGLE
			);
end


local function isNonBlankString(vVal)
	return rawtype(vVal) == "string" and vVal:gsub("%s", "") ~= "";
end


local function layersAreValid(tLayers)
	local bRet = false;

	if (rawtype(tLayers) == "table" and #tLayers > 0) then
		bRet = true;

		for k, v in pairs(tLayers) do

			if ( rawtype(k) ~= "number" or not (rawtype(v) == "string" and v:gsub("5s", "") ~= "") ) then
				bRet = false;
				break;
			end

		end

	end

	return bRet;
end


local function setupActualDecoy(tActual, tDecoy, sError)
	setmetatable(tDecoy, {
		__index = function(t, k)
			return tActual[k] or nil;
		end,
		__newindex = function(t, k, v)
			error(sError);
		end,
		__len = function()
			return #tActual;
		end,
		__pairs = function(t)
			return next, tActual, nil;
		end
	});
end


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
		assert(isNonBlankString(sName), 	"Argument 1: aStar map name must be a non-blank string.");
		assert(mapTypeIsValid(nMapType), 	"Argument 2: map type is invalid.");
		assert(mapDimmIsValid(nWidth),		"Argument 4: map width must be positive integer.");
		assert(mapDimmIsValid(nHeight),		"Argument 5: map height must be positive integer.");
		--TODO assert(#tLayerConfigs > 0)
		--TODO assert(type(oLayerConfigs) == "aStarLayerConfig", 	"Argument 3: must be an aStarLayerConfig object.\nGot type, '"..type(type(tLayerConfig)).."'");

		--create the map table
		tRepo.maps[this] = {
			layers 			= {},--(ORDERED BY ID)
			layersDecoy		= {},--a decoy table for returning layers to the client
			layersByName	= {},
			name 			= sName,
			owner 			= oAStar,
			type			= nMapType,
			width 			= nWidth,
			height			= nHeight,
		};

		local tFields 	= tRepo.maps[this];

		setupActualDecoy(	tFields.layers,
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
		for _, oLayer in pairs(tRepo.maps[this].layers) do
			oLayer:destroy();
		end

		tRepo.maps[this] = nil;
		this = nil;
	end,

	getHeight = function(this)
		return tRepo.maps[this].height;
	end,

	getLayer = function(this, sLayer)
		return tRepo.maps[this].layersByName[sLayer] or nil;
	end,

	getLayers = function(this)
		return tRepo.maps[this].layersDecoy;
	end,

	getName = function(this)
		return tRepo.maps[this].name;
	end,

	getNode = function(this, sLayer, nX, nY)
		local oLayer = tRepo.maps[this].layersByName[sLayer] or nil;

		if (oLayer) then
			return tRepo.maps[this].layersByName[sLayer]:getNode(nX, nY);
		end

	end,

	getOwner = function(this)
		return tRepo.maps[this].owner;
	end,

	getSize = function(this)
		local tFields = tRepo.maps[this];
		return {width = tFields.width, height = tFields.height};
	end,

	getType = function(this)
		return tRepo.maps[this].type;
	end,

	getWidth = function(this)
		return tRepo.maps[this].width;
	end,
};


--[[██╗░░░░░░█████╗░██╗░░░██╗███████╗██████╗░
	██║░░░░░██╔══██╗╚██╗░██╔╝██╔════╝██╔══██╗
	██║░░░░░███████║░╚████╔╝░█████╗░░██████╔╝
	██║░░░░░██╔══██║░░╚██╔╝░░██╔══╝░░██╔══██╗
	███████╗██║░░██║░░░██║░░░███████╗██║░░██║
	╚══════╝╚═╝░░╚═╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝]]
aStarLayer = class "aStarLayer" {
	__construct = function(this, prot, oAStarMap, nLayerID, oConfig, nWidth, nHeight)
		tRepo.layers[this] = {
			id 			= nLayerID,
			--config 		= oConfig,
			owner 		= oAStarMap,
			name		= oConfig:getName(),
			nodes 		= {},
			nodesDecoy	= {}, --a decoy table for returning to the client
		};

		local tFields = tRepo.layers[this];
		local tNodes = tFields.nodes;

		setupActualDecoy(	tFields.nodes,
							tFields.nodesDecoy,
							"Attempting to modifer read-only nodes table for layer, '"..tFields.name.."'.");

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

	destroy = function(this)

		--destroy each node
		for x, tNodes in pairs(tRepo.layers[this].nodes) do

			for y, oNode in pairs(tNodes) do
				oNode:destroy();
			end

		end

		tRepo.layers[this] = nil;
		this = nil;
	end,

	getName = function(this)
		return tRepo.layers[this].name;
	end,

	getNode = function(this, nX, nY)
		local tNodes = tRepo.layers[this].nodesDecoy[nX];

		if (tNodes) then
			return tNodes[nY] or nil;
		end

	end,

	getNodes = function(this)
		return tRepo.layers[this].nodesDecoy;
	end,

	getOwner = function(this)
		return tRepo.layers[this].owner;
	end,
};


--[[██╗░░░░░░█████╗░██╗░░░██╗███████╗██████╗░  ░█████╗░░█████╗░███╗░░██╗███████╗██╗░██████╗░
	██║░░░░░██╔══██╗╚██╗░██╔╝██╔════╝██╔══██╗  ██╔══██╗██╔══██╗████╗░██║██╔════╝██║██╔════╝░
	██║░░░░░███████║░╚████╔╝░█████╗░░██████╔╝  ██║░░╚═╝██║░░██║██╔██╗██║█████╗░░██║██║░░██╗░
	██║░░░░░██╔══██║░░╚██╔╝░░██╔══╝░░██╔══██╗  ██║░░██╗██║░░██║██║╚████║██╔══╝░░██║██║░░╚██╗
	███████╗██║░░██║░░░██║░░░███████╗██║░░██║  ╚█████╔╝╚█████╔╝██║░╚███║██║░░░░░██║╚██████╔╝
	╚══════╝╚═╝░░╚═╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝  ░╚════╝░░╚════╝░╚═╝░░╚══╝╚═╝░░░░░╚═╝░╚═════╝░]]
aStarLayerConfig = class "aStarLayerConfig" {

	__construct = function (this, prot, sName, ...)
		local tInputAspects = {...} or arg;

		--TODO assertions

		tRepo.configs[this] = {
			aspects = {}, --TODO make decoy table for this
			name 	= sName,
		};

		--add all user aspect
		local tAspects = tRepo.configs[this].aspects;
		for _, sAspect in pairs(tInputAspects) do
			tAspects[#tAspects + 1] = sAspect;
		end

	end,
	getName = function(this)
		return tRepo.configs[this].name;
	end,
	getAspect = function(this, sAspect)
		return tRepo.configs[this].aspects[sAspect] or nil;
	end,
	getAspects = function(this)
		return tRepo.configs[this].aspects; --TODO decoy this
	end,
	hasAspect = function(this, sAspect)
		return rawtype(tRepo.configs[this].aspects[sAspect] ~= nil);
	end
};


--[[███╗░░██╗░█████╗░██████╗░███████╗
	████╗░██║██╔══██╗██╔══██╗██╔════╝
	██╔██╗██║██║░░██║██║░░██║█████╗░░
	██║╚████║██║░░██║██║░░██║██╔══╝░░
	██║░╚███║╚█████╔╝██████╔╝███████╗
	╚═╝░░╚══╝░╚════╝░╚═════╝░╚══════╝]]
aStarNode = class "aStarNode" {
	__construct = function(this, prot, oAStarLayer, nX, nY, tAspects)
		tRepo.nodes[this] = {
			aspects 		= {},
			aspectsDecoy	= {},
			aspectsByName 	= {},
			isPassable		= true,
			owner			= oAStarLayer,
			rovers			= {},
			roversDecoy 	= {}, --decoy table to return to the client
			type			= oAStarLayer:getOwner():getType(),
			x 				= nX,
			y 				= nY,
		};

		local tFields = tRepo.nodes[this];

		for nIndex, sAspect in pairs(tAspects) do
			local oAspect 					= aStarAspect(this, sAspect);
			tFields.aspects[nIndex] 		= oAspect;
			tFields.aspectsByName[sAspect] 	= oAspect;
		end

		setupActualDecoy(tFields.rovers, tFields.roversDecoy, "Attempting to modifer read-only rovers table for node at x: "..tFields.x..", y: "..tFields.y..".");
		setupActualDecoy(tFields.aspects, tFields.aspectsByName, "Attempting to modifer read-only aspects table for node at x: "..tFields.x..", y: "..tFields.y..".");
	end,

	containsRover = function(this, oRover)
		local bRet = false;

		for _, oRoverInNode in pairs(tRepo.nodes[this].rovers) do

			if (oRover == oRoverInNode) then
				bRet = true;
			end

		end

		return bRet;
	end,

	createRover = function(this)
		local tFields 						= tRepo.nodes[this];
		local oRover 						= aStarRover(this);
		tFields.rovers[#tFields.rovers + 1] = oRover;

		return oRover;
	end,

	destroy = function(this)

		--destroy all aspects
		for _, oAspect in pairs(tRepo.nodes[this].aspects) do
			oAspect:destroy();
		end

		--destroy all rovers
		for _, oRover in pairs(tRepo.nodes[this].rovers) do
			oRover:destroy();
		end

		tRepo.nodes[this] = nil;
		this = nil;
	end,

	getAspect = function(this, sAspect)
		return tRepo.nodes[this].aspectsByName[sAspect] or nil;
	end,

	getAspects = function(this)
		return tRepo.nodes[this].aspectsDecoy;
	end,

	getAspectImpact = function(this, sAspect)
		local oAspect = tRepo.nodes[this].aspectsByName[sAspect] or nil;

		if (oAspect) then
			return oAspect:getImpactor():get();
		end

	end,

	getEntryCost = function(this, oRover)

	end,

	getNeighbors = function(this)
		local tFields = tRepo.nodes[this];

		if (tFields.type == ASTAR_MAP_TYPE_HEX_FLAT) then
		elseif (tFields.type == ASTAR_MAP_TYPE_HEX_POINTED) then
		elseif (tFields.type == ASTAR_MAP_TYPE_SQUARE) then
		elseif (tFields.type == ASTAR_MAP_TYPE_TRIANGLE_FLAT) then
		elseif (tFields.type == ASTAR_MAP_TYPE_TRIANGLE_POINTED) then
			constant("", 			0);
			constant("", 			1);
			constant("", 			2);
			constant("", 	3);
			constant("", 4);
		end

	end,

	getOwner = function(this)
		return tRepo.nodes[this].owner;
	end,

	getPassable = function(this)
		return tRepo.nodes[this].isPassable;
	end,

	getPos = function(this)
		local tFields = tRepo.nodes[this];
		return {x = tFields.x, y = tFields.y};
	end,

	getRovers = function(this)
		return tRepo.nodes[this].roversDecoy;
	end,

	getX = function(this)
		return tRepo.nodes[this].x;
	end,

	getY = function(this)
		return tRepo.nodes[this].y;
	end,

	hasAspect = function(this, sAspect)
		local tAspects = tRepo.nodes[this].aspectsByName;
		return rawtype(tAspects[sAspect]) ~= "nil";
	end,

	isPassable = function(this, oRover)
		local tFields 	= tRepo.nodes[this];
		local bRet 		= tFields.isPassable;

		if (bRet) then
--TODO finish this!!!!
		end

		return bRet;
	end,

	setPassable = function(this, bPassable)

		if (rawtype(bPassable) == "boolean") then
			tRepo.nodes[this].isPassable = bPassable;
		end

	end,

	togglePassable = function(this)
		tRepo.nodes[this].isPassable = not tRepo.nodes[this].isPassable;
	end,
};


--[[░█████╗░░██████╗██████╗░███████╗░█████╗░████████╗
	██╔══██╗██╔════╝██╔══██╗██╔════╝██╔══██╗╚══██╔══╝
	███████║╚█████╗░██████╔╝█████╗░░██║░░╚═╝░░░██║░░░
	██╔══██║░╚═══██╗██╔═══╝░██╔══╝░░██║░░██╗░░░██║░░░
	██║░░██║██████╔╝██║░░░░░███████╗╚█████╔╝░░░██║░░░
	╚═╝░░╚═╝╚═════╝░╚═╝░░░░░╚══════╝░╚════╝░░░░╚═╝░░░]]
aStarAspect = class "aStarAspect" {
	__construct = function(this, prot, oAStarNode, sName)
		tRepo.aspects[this] = {
			impactor	= protean(1, 0, 0, 0, 0, 0, 0, 0, nil, nil, true),
			name 		= sName,
			owner 		= oAStarNode,
		};
	end,

	destroy = function(this)
		tRepo.aspects[this].impactor:destroy();
		tRepo.aspects[this] = nil;
		this = nil;
	end,

	getImpactor = function(this)
		return tRepo.aspects[this].impactor;
	end,

	getName = function(this)
		return tRepo.aspects[this].name;
	end,

	getOwner = function(this)
		return tRepo.aspects[this].owner;
	end,

};


--[[██████╗░░█████╗░██╗░░░██╗███████╗██████╗░
	██╔══██╗██╔══██╗██║░░░██║██╔════╝██╔══██╗
	██████╔╝██║░░██║╚██╗░██╔╝█████╗░░██████╔╝
	██╔══██╗██║░░██║░╚████╔╝░██╔══╝░░██╔══██╗
	██║░░██║╚█████╔╝░░╚██╔╝░░███████╗██║░░██║
	╚═╝░░╚═╝░╚════╝░░░░╚═╝░░░╚══════╝╚═╝░░╚═╝]]
aStarRover = class "aStarRover" {
	__construct = function(this, prot, oAStarNode)

		tRepo.rovers[this] = {
			abhorations			= {}, --unlike most other tables, it's index by aspect name (string)
			abhorationsDecoy	= {},
			affinities 			= {},
			affinitiesByName	= {},
			affinitiesDecoy 	= {},
			aversions	 		= {},
			aversionsByName	 	= {},
			aversionsDecoy 		= {},
			onEnterNode			= nil,
			onExitNode			= nil,
			owner 				= oAStarNode,
		};

		local tFields 	= tRepo.rovers[this];
		local oLayer 	= oAStarNode:getOwner();
		local oMap 		= oLayer:getOwner();
		local oAStar	= oMap:getOwner();

		--create the proteans for affinities & aversions and booleans for abhorations
		for _, sAspect in pairs(oAStar.aspectNames) do
			--abhorations
			tFields.abhorations[sAspect] = false;

			--affinities
			local oAffinity = protean();
			tFields.affinities[#tFields.affinities + 1] 	= oAffinity;
			tFields.affinitiesByName[sAspect] 				= oAffinity;

			--aversions
			local oAversion = protean();
			tFields.aversions[#tFields.aversions + 1]	= oAversion;
			tFields.aversionsByName[sAspect]	 		= oAversion;
		end

		setupActualDecoy(tFields.abhorations, 	tFields.abhorationsDecoy, "SETUP ERROR");
		setupActualDecoy(tFields.affinities, 	tFields.affinitiesDecoy, 	"SETUP ERROR");
		setupActualDecoy(tFields.aversions, 	tFields.aversionsDecoy,	"SETUP ERROR");
	end,

	destroy = function(this)--TODO complete this
		tRepo.rovers[this] = nil;
		this = nil;
	end,

	abhors = function(this, sAspect)
		return tRepo.rovers[this].abhorations[sAspect] or false;
	end,

	getAbhorations = function(this)
		return tRepo.rovers[this].abhorationsDecoy;
	end,

	getAffinity = function(this, sAspect)
		return tRepo.rovers[this].affinitiesByName[sAspect] or nil;
	end,

	getAffinites = function(this)
		return tRepo.rovers[this].affinitiesDecoy;
	end,

	getAversion = function(this, sAspect)
		return tRepo.rovers[this].aversionsByName[sAspect] or nil;
	end,

	getAversions = function(this)
		return tRepo.rovers[this].aversionsDecoy;
	end,

	getOnMoveCallback = function(this)
		return tRepo.rovers[this].onMove;
	end,

	getOwner = function(this)
		return tRepo.rovers[this].owner;
	end,

	setAbhors = function(this, sAspect, bAbhors)
		local tFields 		= tRepo.rovers[this];
		local tAbhorations 	= tFields.abhorations;

		if (rawtype(tAbhorations[sAspect]) ~= "nil" and
			rawtype(bAbhors) == "boolean") then
			tAbhorations[sAspect] = bAbhors;
		end

		return this;
	end,

	setOnEnterNodeCallback = function(this, vFuncOrNil)
		local tFields 	= tRepo.rovers[this];
		local sType 	= rawtype(vFuncOrNil);

		if (sType == "function") then
			tFields.onEnterNode = vFuncOrNil;
		elseif (sType == "nil") then
			tFields.onEnterNode = nil;
		end

		return this;
	end,

	setOnExitNodeCallback = function(this, vFuncOrNil)
		local tFields 	= tRepo.rovers[this];
		local sType 	= rawtype(vFuncOrNil);

		if (sType == "function") then
			tFields.onExitNode = vFuncOrNil;
		elseif (sType == "nil") then
			tFields.onExitNode = nil;
		end

		return this;
	end,

	toggleAbhors = function(this, sAspect)
		local tFields 		= tRepo.rovers[this];
		local tAbhorations 	= tFields.abhorations;

		if (rawtype(tAbhorations[sAspect]) ~= "nil") then
			tAbhorations[sAspect] = -tAbhorations[sAspect];
		end

		return this;
	end,
};

--TODO account for caves/portals/etc. when doing pathfinding...add this functionality

--[[██████╗░░█████╗░████████╗██╗░░██╗
	██╔══██╗██╔══██╗╚══██╔══╝██║░░██║
	██████╔╝███████║░░░██║░░░███████║
	██╔═══╝░██╔══██║░░░██║░░░██╔══██║
	██║░░░░░██║░░██║░░░██║░░░██║░░██║
	╚═╝░░░░░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░╚═╝]]
aStarPath = class "aStarPath" {
	__construct= function(this, prot, oStartNode, oEndNode, ...)
		local tRovers = {...} or arg;

		--TODO check the rovers table
		--TODO make sure the listed rovers are at the starting node

		tRepo.paths[this] = {
			nodes 		= {},
			notesDecoy	= {},
			currentStep	= {}, --refers to the nodes table index
			rovers 		= {},
			roversDecoy	= {},
			totalSteps	= {},
		};

		--get the layer nodes
		local oLayer 	= oStartNode:getOwner();
		local tNodes	= oLayer:getNodes();

		--setup the pathfinding table
		local tData 	= {};

		for _, oNode in pairs(tNodes) do
			tData[oNode] = {
				f			= 0, -- g + h
				g			= 0, --distance from start
				h			= 0, --distance to destination
				previous	= nil,
			};
		end

		--create the lists
		local tOpen 	= {};
		local tClosed 	= {};

		local oCurrent	= oStartNode


	end,

	getNextNode = function(this)

	end,

	getNodes = function(this)

	end,

	getNodeCount = function(this)

	end,

	getRovers = function(this)

	end,
	step = function(this)

	end,
};


--[[░█████╗░░██████╗████████╗░█████╗░██████╗░
	██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██╔══██╗
	███████║╚█████╗░░░░██║░░░███████║██████╔╝
	██╔══██║░╚═══██╗░░░██║░░░██╔══██║██╔══██╗
	██║░░██║██████╔╝░░░██║░░░██║░░██║██║░░██║
	╚═╝░░╚═╝╚═════╝░░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚═╝]]
local aStar = class "aStar" {
	__construct = function(this, prot, ...)
		local tAspects = {...} or arg;
		--TODO assertions for aspects | must be variable-compliant
		tRepo.aStars[this] = {
			aspectNames			= {}, --a list of all aspects available to this aStar object
			aspectNamesRet		= {}, --decoy table foe use by client
			aspectNamesByName	= {},
			maps 				= {},
		};

		local tFields = tRepo.aStars[this];

		--upper all the aspects
		for nIndex, sAspectRAW in pairs(tAspects) do
			tAspects[nIndex] = sAspectRAW:upper();
		end

		--sort the aspects alphabetically
		table.sort(tAspects);

		--add all aspects for the aStar object
		for nIndex, sAspect in pairs(tAspects) do
			tFields.aspectNames[nIndex] 		= sAspect;
			tFields.aspectNamesByName[sAspect] 	= sAspect;
		end

		-- create the publicly-accesible aspects table
		this.aspectNames = {};

		--setup the aspectNames metatable
		setmetatable(this.aspectNames, {
			__index = function(t, k)
				local _, kUpper = pcall(string.upper, k);
				return tFields.aspectNamesByName[kUpper] or nil;
			end,
			__len = function(t)
				return #tFields.aspectNames;
			end,
			__newindex = function(t, k, v)
				error("Cannot manually ad aspects to aspects table nor alter existing ones."); --TODO allow string additions?
			end,
			__pairs = function(t)
				return next, tFields.aspectNames, nil;
			end
		});

	end,

	destroy = function(this)

		for _, oMap in pairs(tRepo.aStars[this].maps) do
			oMap:destroy();
		end

		tRepo.aStars[this] = nil;
		this = nil;
	end,

	getMap = function(this, sName)
		return tRepo.aStars[this].maps[sName] or nil;
	end,

	getNode = function(this, sMap, sLayer, nX, nY)
		local oMap = tRepo.aStars[this].maps[sMap] or nil;

		if (oMap) then
			return oMap:getNode(sLayer, nX, nY);
		end

	end,

	newMap = function(this, sName, nType, tLayers, nWidth, nHeight)
		local tFields = tRepo.aStars[this];

		--create the map (only if doesn't already exist)
		if (rawtype(tFields.maps[sName]) == "nil") then
			tFields.maps[sName] = aStarMap(this, sName, nType, tLayers, nWidth, nHeight);
			return tFields.maps[sName];
		end

	end,

};

--make the 'aStarLayerConfig' and 'aStarPath' classes publicly available
aStar.newLayerConfig = aStarLayerConfig;
aStar.newPath		 = aStarPath;

return aStar;
