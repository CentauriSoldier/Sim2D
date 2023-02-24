
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
constant("ASTAR_MAP_TYPE_HEX_FLAT", 		0);
constant("ASTAR_MAP_TYPE_HEX_POINTED", 		1);
constant("ASTAR_MAP_TYPE_SQUARE", 			2);
constant("ASTAR_MAP_TYPE_TRIANGLE_FLAT", 	3);
constant("ASTAR_MAP_TYPE_TRIANGLE_POINTED", 4);
constant("ASTAR_NODE_ENTRY_COST_BASE", 		10); --the central cost upon which all other costs & cost mechanics are predicated
constant("ASTAR_NODE_ENTRY_COST_MIN", 		1);
constant("ASTAR_NODE_ENTRY_COST_MAX_RATE",	12);
constant("ASTAR_NODE_ENTRY_COST_MAX", 		ASTAR_NODE_ENTRY_COST_BASE * ASTAR_NODE_ENTRY_COST_MAX_RATE);

--🅻🅾🅲🅰🅻🅸🆉🅰🆃🅸🅾🅽
local ASTAR_MAP_TYPE_HEX_FLAT 			= ASTAR_MAP_TYPE_HEX_FLAT;
local ASTAR_MAP_TYPE_HEX_POINTED 		= ASTAR_MAP_TYPE_HEX_POINTED;
local ASTAR_MAP_TYPE_SQUARE 			= ASTAR_MAP_TYPE_SQUARE;
local ASTAR_MAP_TYPE_TRIANGLE_FLAT 		= ASTAR_MAP_TYPE_TRIANGLE_FLAT;
local ASTAR_MAP_TYPE_TRIANGLE_POINTED	= ASTAR_MAP_TYPE_TRIANGLE_POINTED;
local ASTAR_NODE_ENTRY_COST_BASE		= ASTAR_NODE_ENTRY_COST_BASE;
local ASTAR_NODE_ENTRY_COST_MIN 		= ASTAR_NODE_ENTRY_COST_MIN;
local ASTAR_NODE_ENTRY_COST_MAX_RATE 	= ASTAR_NODE_ENTRY_COST_MAX_RATE;
local ASTAR_NODE_ENTRY_COST_MAX 		= ASTAR_NODE_ENTRY_COST_MAX;
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



--determine the call location
local sPath = debug.getinfo(1, "S").source;
--remove the calling filename
sPath = sPath:gsub("@", ""):gsub("[Aa][Ss][Tt][Aa][Rr].[Ll][Uu][Aa]", "");
--remove the "/" at the end
sPath = sPath:sub(1, sPath:len() - 1);
--update the package.path (use the main directory to prevent namespace issues)
package.path = package.path..";"..sPath.."\\?.lua";

--🅳🅴🅲🅻🅰🆁🅰🆃🅸🅾🅽🆂 & 🆁🅴🆀🆄🅸🆁🅴 🅼🅾🅳🆄🅻🅴🆂
local sInt 				= "internal";
local aStar;
local aStarMap 			= require(sInt..".aStarMap");
local aStarLayer		= require(sInt..".aStarLayer");
local aStarLayerConfig 	= require(sInt..".aStarLayerConfig");
local aStarNode			= require(sInt..".aStarNode");
local aStarAspect		= require(sInt..".aStarAspect");
local aStarPath			= require(sInt..".aStarPath");
local aStarRover		= require(sInt..".aStarRover");
local aStarUtil			= require(sInt..".aStarUtil");

--🅵🅸🅴🅻🅳🆂 🆁🅴🅿🅾🆂🅸🆃🅾🆁🆈
local tRepo = {};


--[[░█████╗░░██████╗████████╗░█████╗░██████╗░
	██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██╔══██╗
	███████║╚█████╗░░░░██║░░░███████║██████╔╝
	██╔══██║░╚═══██╗░░░██║░░░██╔══██║██╔══██╗
	██║░░██║██████╔╝░░░██║░░░██║░░██║██║░░██║
	╚═╝░░╚═╝╚═════╝░░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚═╝]]


aStar = class "aStar" {
	__construct = function(this, prot, ...)
		local tAspects = {...} or arg;
		--TODO assertions for aspects | must be variable-compliant
		tRepo[this] = {
			aspectNames			= {}, --a list of all aspects available to this aStar object
			aspectNamesRet		= {}, --decoy table for use by client
			aspectNamesByName	= {},
			maps 				= {}, --indexed by map name
			mapsDecoy			= {},
		};

		local tFields = tRepo[this];

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

		aStarUtil.setupActualDecoy(tFields.maps, tFields.mapsDecoy, "Attempt to modify read-only maps table.")
	end,

	destroy = function(this)

		for _, oMap in pairs(tRepo[this].maps) do
			oMap:destroy();
		end

		tRepo[this] = nil;
		this = nil;
	end,

	getMap = function(this, sName)
		return tRepo[this].maps[sName] or nil;
	end,

	getMaps = function(this)
		return tRepo[this].mapsDecoy;
	end,

	getNode = function(this, sMap, sLayer, nX, nY)
		local oMap = tRepo[this].maps[sMap] or nil;

		if (oMap) then
			return oMap:getNode(sLayer, nX, nY);
		end

	end,

	newMap = function(this, sName, nType, tLayers, nWidth, nHeight)
		local tFields = tRepo[this];

		--create the map (only if doesn't already exist)
		if (rawtype(tFields.maps[sName]) == "nil") then
			tFields.maps[sName] = aStarMap(this, sName, nType, tLayers, nWidth, nHeight);
			return tFields.maps[sName];
		end

	end,

};

--🅸🅽🅸🆃 🅼🅾🅳🆄🅻🅴🆂
aStarMap.init(aStar, aStarLayer, aStarLayerConfig, aStarNode, aStarAspect, aStarPath, aStarRover, aStarUtil);
aStarLayer.init(aStar, aStarMap, aStarLayerConfig, aStarNode, aStarAspect, aStarPath, aStarRover, aStarUtil);
aStarLayerConfig.init(aStar, aStarMap, aStarLayer, aStarNode, aStarAspect, aStarPath, aStarRover, aStarUtil);
aStarNode.init(aStar, aStarMap, aStarLayer, aStarLayerConfig, aStarAspect, aStarPath, aStarRover, aStarUtil);
aStarAspect.init(aStar, aStarMap, aStarLayer, aStarLayerConfig, aStarNode, aStarPath, aStarRover, aStarUtil);
aStarPath.init(aStar, aStarMap, aStarLayer, aStarLayerConfig, aStarNode, aStarAspect, aStarRover, aStarUtil);
aStarRover.init(aStar, aStarMap, aStarLayer, aStarLayerConfig, aStarNode, aStarAspect, aStarPath, aStarUtil);

--make the 'aStarLayerConfig' and 'aStarPath' classes publicly available
aStar.newLayerConfig = aStarLayerConfig;
aStar.newPath		 = aStarPath;

return aStar;
