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

--TODO move help to another module for readability (and pull the data in here)
--TODO on second thought, why not parse this file for dox (or dox-lie) text and create the help fro that?
--create the help for this module
local tAStarRoverInfo = {};
local tAStarRoverHelp = {
	addDeniedType = {
					title = "addDeniedType",
					desc = "Adds an item to the list of types that are denied entry to a node this rover occupies."..
						"\nAdding an asterisk ('*') will deny all types."..
						"\nNote: No matter what types a rover denies, it cannot deny entry to other rovers which share one of its own types."..
						"\nIn addition, a rover cannot add a denied type that matches one of its own types.",
					example = "",
				},
};
local fAStarRoverHelp = infusedhelp(tAStarRoverInfo, tAStarRoverHelp);

	--[[██████╗░░█████╗░██╗░░░██╗███████╗██████╗░
		██╔══██╗██╔══██╗██║░░░██║██╔════╝██╔══██╗
		██████╔╝██║░░██║╚██╗░██╔╝█████╗░░██████╔╝
		██╔══██╗██║░░██║░╚████╔╝░██╔══╝░░██╔══██╗
		██║░░██║╚█████╔╝░░╚██╔╝░░███████╗██║░░██║
		╚═╝░░╚═╝░╚════╝░░░░╚═╝░░░╚══════╝╚═╝░░╚═╝
		Note: unlike other classes, this one directly accesses/modifies node
		info without calling node class methods. This design style is allowed
		since rovers techincally and practically belong to node objects.
		]]
aStarRover = class "aStarRover" {
	__construct = function(this, prot, oAStarNode)

		tRepo[this] = {
			allowedLayers		= {}, --TODO finish this and allow rovers to move layers (and maps?)
			abhorations			= {}, --unlike most other tables, it's index by aspect name (string)
			abhorationsDecoy	= {},
			affinities 			= {},
			affinitiesByName	= {},
			affinitiesDecoy 	= {},
			aversions	 		= {},
			aversionsByName	 	= {},
			aversionsDecoy 		= {},
			deniedTypes			= {}, --used for preventing entry into occupied nodes which contain rovers of these types
			deniedTypesByName	= {},
			deniedTypesDecoy	= {},
			movePoints			= protean(),--TODO finsih this!!!!!!
			onEnterNode			= nil,
			onExitNode			= nil,
			owner 				= oAStarNode,
			types				= {}, --the types I am (for example, [FactionName])
			typesByName			= {},
			typesDecoy			= {},
		};

		local tFields 	= tRepo[this];
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

		aStarUtil.setupActualDecoy(tFields.abhorations, tFields.abhorationsDecoy, 	"SETUP ERROR");
		aStarUtil.setupActualDecoy(tFields.affinities, 	tFields.affinitiesDecoy, 	"SETUP ERROR");
		aStarUtil.setupActualDecoy(tFields.aversions, 	tFields.aversionsDecoy,		"SETUP ERROR");
		aStarUtil.setupActualDecoy(tFields.types, 		tFields.typesDecoy,			"SETUP ERROR");
	end,

	abhors = function(this, sAspect)--TODO CHECK TYPE AND UPPER THIS PARAMETER
		return tRepo[this].abhorations[sAspect] or false;
	end,

	addDeniedType = function(this, sType)
		local tFields = tRepo[this];

		if (rawtype(sType) == "string" and sType:gsub("%s", "") ~= "" 	and
			rawtype(tFields.deniedTypesByName[sType]) == "nil"			and
			rawtype(tFields.typesByName[sType]) == "nil") 				then

			tFields.deniedTypes[#tFields.deniedTypes + 1] 	= sType;
			tFields.deniedTypesByName[sType] 			= true;
		end

		return this;
	end,

	addType = function(this, sType)
		local tFields = tRepo[this];

		if (rawtype(sType) == "string" and sType:gsub("%s", "") ~= "" 	and
			rawtype(tFields.typesByName[sType]) == "nil"				and
			rawtype(tFields.deniedTypesByName[sType]) == "nil") 		then

			tFields.types[#tFields.types + 1] 	= sType;
			tFields.typesByName[sType] 			= true;
		end

		return this;
	end,

	--[[allows all types by default.
		same types are always allowed
	]]
	allowsEntryTo = function(this, other) --TODO finish
		assert(type(other) == "aStarRover", "Attempt to check entry allowance on non-aStarRover type. Value given was of type "..rawtype(other)..".");
		local bRet 			= true;
		local tFields 		= tRepo[this];
		local tMyTypes		= tFields.typesByName;
		local tDeniedTypes 	= tFields.deniedTypesByName;
		local tItsTypes		= tRepo[other].typesByName;

		local bSharesType = false;

		--look for a shared type
		for sMyType, _ in pairs(tMyTypes) do

			if (rawtype(tItsTypes[sMyType]) ~= "nil") then
				bSharesType = true;
				break;
			end

		end

		--only look for denied types if this and the other don't share a type
		if (not bSharesType and #tFields.deniedTypes > 0) then
			bRet = rawtype(tDeniedTypes["*"]) == "nil";

			--this gets skipped if all (unlike) types are denied
			if (bRet) then

				--look for a denied type
				for sItsType, _ in pairs(tItsTypes) do

					if (rawtype(tDeniedTypes[sItsType]) ~= "nil") then
						bRet = false;
						break;
					end

				end

			end

		end

		return bRet;
	end,

	destroy = function(this)
		local tFields = tRepo[this];
		--remove the rover from the containing node
		tRepo.nodes[tFields.owner][this] = nil;

		tRepo[this] = nil;
		this = nil;
	end,

	getAbhorations = function(this)
		return tRepo[this].abhorationsDecoy;
	end,

	getAffinity = function(this, sAspect)--TODO CHECK TYPE AND UPPER THIS PARAMETER
		return tRepo[this].affinitiesByName[sAspect] or nil;
	end,

	getAffinites = function(this)
		return tRepo[this].affinitiesDecoy;
	end,

	getAversion = function(this, sAspect)--TODO CHECK TYPE AND UPPER THIS PARAMETER
		return tRepo[this].aversionsByName[sAspect] or nil;
	end,

	getAversions = function(this)
		return tRepo[this].aversionsDecoy;
	end,

	getOnMoveCallback = function(this)
		return tRepo[this].onMove;
	end,

	getOwner = function(this)
		return tRepo[this].owner;
	end,

	hasDeniedType = function(this, sType)
		return 	rawtype(sType) == "string" 	and
				rawtype(tRepo[this].deniedTypesByName[sType]) ~= "nil";
	end,

	help = fAStarRoverHelp,

	isAllowedOnLayer = function(this, vLayer)--TODO finsih this
		local bRet = false;
		local sType = type(vLayer);

		if (sType == "string") then

		elseif (sType == "aStarLayer") then

		end

		return bRet;
	end,

	isOnLayer = function(this, vLayer)
		local bRet = false;
		local sType = type(vLayer);

		if (sType == "string") then
			bRet = tRepo[this].owner:getOwner():getName() == vLayer:upper();
		elseif (sType == "aStarLayer") then
			bRet = tRepo[this].owner:getOwner():getName() == vLayer:getName();
		end

		return bRet;
	end,

	isType = function(this, sType)
		return 	rawtype(sType) == "string" 	and
				rawtype(tRepo[this].typesByName[sType]) ~= "nil";
	end,

	move = function(this, oNode)

	end,

	moveToLayer = function(this, oLayer, oNode)

	end,

	moveToMap = function(this, oMap, oLayer, oNode)

	end,

	removeDeniedType = function(this, sType)--TODO check for type before adding
		local tFields = tRepo[this];

		if (rawtype(sType) == "string" and sType:gsub("%s", "") ~= "" and
			rawtype(tFields.deniedTypesByName[sType]) ~= "nil") then

			table.remove(tFields.deniedTypes, table.getindex(tFields.deniedTypes, sType));
			tFields.deniedTypesByName[sType] = nil;
		end

		return this;
	end,

	removeType = function(this, sType)--TODO check for denied type before adding
		local tFields = tRepo[this];

		if (rawtype(sType) == "string" and sType:gsub("%s", "") ~= "" and
			rawtype(tFields.typesByName[sType]) ~= "nil") then

				table.remove(tFields.types, table.getindex(tFields.types, sType));
				tFields.typesByName[sType] = nil;
		end

		return this;
	end,

	setAbhors = function(this, sAspect, bAbhors)--TODO CHECK TYPE AND UPPER THIS PARAMETER
		local tFields 		= tRepo[this];
		local tAbhorations 	= tFields.abhorations;

		if (rawtype(tAbhorations[sAspect]) ~= "nil" and
			rawtype(bAbhors) == "boolean") then
			tAbhorations[sAspect] = bAbhors;
		end

		return this;
	end,

	setOnEnterNodeCallback = function(this, vFunc)
		local tFields 	= tRepo[this];
		local sType 	= rawtype(vFunc);

		if (sType == "function") then
			tFields.onEnterNode = vFunc;
		else
			tFields.onEnterNode = nil;
		end

		return this;
	end,

	setOnExitNodeCallback = function(this, vFunc)
		local tFields 	= tRepo[this];
		local sType 	= rawtype(vFunc);

		if (sType == "function") then
			tFields.onExitNode = vFunc;
		else
			tFields.onExitNode = nil;
		end

		return this;
	end,

	toggleAbhors = function(this, sAspect)--TODO CHECK TYPE AND UPPER THIS PARAMETER
		local tFields 		= tRepo[this];
		local tAbhorations 	= tFields.abhorations;

		if (rawtype(tAbhorations[sAspect]) ~= "nil") then
			tAbhorations[sAspect] = -tAbhorations[sAspect];
		end

		return this;
	end,
};

local bHasInit = false;
function aStarRover.init(cStar, cStarMap, cStarLayer, cStarLayerConfig, cStarNode, cStarAspect, cStarPath, cStarUtil)

	if not (bHasInit) then
		aStar 				= cStar;
		aStarMap 			= cStarMap;
		aStarLayer 			= cStarLayer;
		aStarLayerConfig 	= cStarLayerConfig;
		aStarNode 			= cStarNode;
		aStarAspect 		= cStarAspect;
		aStarPath 			= cStarPath;
		aStarUtil			= cStarUtil;
		bHasInit 			= true;
	end

end

return aStarRover;
