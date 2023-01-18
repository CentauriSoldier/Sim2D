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

--[[███╗░░██╗░█████╗░██████╗░███████╗
	████╗░██║██╔══██╗██╔══██╗██╔════╝
	██╔██╗██║██║░░██║██║░░██║█████╗░░
	██║╚████║██║░░██║██║░░██║██╔══╝░░
	██║░╚███║╚█████╔╝██████╔╝███████╗
	╚═╝░░╚══╝░╚════╝░╚═════╝░╚══════╝]]
aStarNode = class "aStarNode" {
	__construct = function(this, prot, oAStarLayer, nX, nY, tAspects)
		tRepo[this] = {
			aspects 		= {},
			aspectsDecoy	= {},
			aspectsByName 	= {},
			baseCost 		= ASTAR_NODE_ENTRY_COST_BASE,
			isPassable		= true,
			owner			= oAStarLayer,
			ports			= {}, --nodes that are logically but not physically adjacent (indexed by object)
			portsDecoy		= {},
			rovers			= {}, --indexed by object, values are boolean
			roversDecoy 	= {}, --decoy table to return to the client
			type			= oAStarLayer:getOwner():getType(),
			x 				= nX,
			y 				= nY,
		};

		local tFields = tRepo[this];

		for nIndex, sAspect in pairs(tAspects) do
			local oAspect 					= aStarAspect(this, sAspect);
			tFields.aspects[nIndex] 		= oAspect;
			tFields.aspectsByName[sAspect] 	= oAspect;
		end

		aStarUtil.setupActualDecoy(tFields.rovers, 	tFields.roversDecoy, 	"Attempting to modifer read-only rovers table for node at x: "..tFields.x..", y: "..tFields.y..".");
		aStarUtil.setupActualDecoy(tFields.aspects, tFields.aspectsByName, 	"Attempting to modifer read-only aspects table for node at x: "..tFields.x..", y: "..tFields.y..".");
		aStarUtil.setupActualDecoy(tFields.ports, 	tFields.portsDecoy, 	"Attempting to modifer read-only ports table for node at x: "..tFields.x..", y: "..tFields.y..".");

	end,

	addPort = function(this, oNode)
		assert(type(oNode) == "aStarNode", "Port must be of type, aStarNode.");
		tRepo[this].ports[oNode] = true;
		tRepo[oNode].ports[this] = true;
		return this;
	end,

	containsRover = function(this, oRover)
		return rawtype(tRepo[this].rovers[oRover]) ~= "nil";
	end,

	createRover = function(this)
		local tFields 			= tRepo[this];
		local oRover 			= aStarRover(this);
		tFields.rovers[oRover] 	= true;

		return oRover;
	end,

	destroy = function(this)

		--destroy all aspects
		for _, oAspect in pairs(tRepo[this].aspects) do
			oAspect:destroy();
		end

		--destroy all rovers
		for oRover, _ in pairs(tRepo[this].rovers) do
			oRover:destroy();
		end

		--TODO disconnect all ports!!!

		tRepo[this] = nil;
		this = nil;
	end,

	getAspect = function(this, sAspect)--TODO CHECK TYPE AND UPPER THIS PARAMETER
		return tRepo[this].aspectsByName[sAspect] or nil;
	end,

	getAspects = function(this)
		return tRepo[this].aspectsDecoy;
	end,

	getAspectImpact = function(this, sAspect)--TODO CHECK TYPE AND UPPER THIS PARAMETER
		local oAspect = tRepo[this].aspectsByName[sAspect] or nil;

		if (oAspect) then
			return oAspect:getImpactor():get();
		end

	end,

	getEntryCost = function(this, oRover)--TODO set this up for multiple rovers
		assert(type(oRover) == "aStarRover", "Rover must be of type, aStarRover.");
		local tFields	= tRepo[this];
		local nBaseCost = tRepo.nodes.baseCost;
		local nRet 	= nBaseCost;

		--iterate over all of this node's aspects
		for sApect, oAspect in pairs(tFields.aspectsByName) do
			local nImpact = oAspect:getImpactor():get();

			--operate on this aspect only if it has an impact on the node
			if (nImpact > 0) then
				local tRoverAffinities 	= oRover:getAffinites();
				local tRoverAversions 	= oRover:getAversions();
--[[Let F 	= Final Entry Cost
Let M	= total value of all affinity/aversion values
Let B	= Node base cost
Let Naf	= node affinity value
Let Raf = rover affinity value
Let Rav	= rover aversion value
M = M + B * (Rav - Raf);

F = math.clamp(B + Naf * M, ASTAR_NODE_ENTRY_COST_MIN, ASTAR_NODE_ENTRY_COST_MAX);]]
				--go through the rover's affinities
				--for

			end

		end

		return nRet;
	end,

	getNeighbors = function(this)
		local tFields = tRepo[this];

		if (tFields.type == ASTAR_MAP_TYPE_HEX_FLAT) then
		elseif (tFields.type == ASTAR_MAP_TYPE_HEX_POINTED) then
		elseif (tFields.type == ASTAR_MAP_TYPE_SQUARE) then
		elseif (tFields.type == ASTAR_MAP_TYPE_TRIANGLE_FLAT) then
		elseif (tFields.type == ASTAR_MAP_TYPE_TRIANGLE_POINTED) then
			--TODO finish this
		end

	end,

	getOwner = function(this)
		return tRepo[this].owner;
	end,

	getPassable = function(this)
		return tRepo[this].isPassable;
	end,

	getPorts = function(this)
		return tRepo[this].portsDecoy;
	end,

	getPos = function(this)
		local tFields = tRepo[this];
		return {x = tFields.x, y = tFields.y};
	end,

	getRovers = function(this)
		return tRepo[this].roversDecoy;
	end,

	getX = function(this)
		return tRepo[this].x;
	end,

	getY = function(this)
		return tRepo[this].y;
	end,

	hasAspect = function(this, sAspect)
		local tAspects = tRepo[this].aspectsByName;
		return rawtype(tAspects[sAspect]) ~= "nil";
	end,

	hasPort = function(this, oNode)
		assert(type(oNode) == "aStarNode", "Port must be of type, aStarNode.");
		return 	type(tRepo[this].ports[oNode] == "aStarPort") and
				type(tRepo[oNode].ports[this] == "aStarPort");
	end,

	hasPorts = function(this)
		return #tRepo[this].ports > 0;
	end,

	isPassable = function(this, ...)
		local tFields 		= tRepo[this];
		local tAspects		= tFields.aspectsByName;
		local tLocalRovers	= tFields.rovers;
		local bRet 			= tFields.isPassable;

		--TODO check rover var args!!!!

		if (bRet) then
		local tOutRovers = {...} or arg;
		--allow for individual rover args or a table of rovers
		tOutRovers = (type(tOutRovers[1]) == "table") and tOutRovers[1] or tOutRovers;

			for _, oOutRover in pairs(tOutRovers) do
				assert(type(oOutRover) == "aStarRover", "Attempt to check node passability for non-aStarRover. Value given was of type "..type(oOutRover).." at index "..tostring(_)..".")

				--check for abhorations
				for __, oAspect in pairs(tAspects) do

					if (oAspect:getImpactor():get() > 0) then

						if (oOutRover:abhors(oAspect:getName())) then
							bRet = false;
							break;
						end

					end

				end

				if (bRet) then

					--check for disallowed rover types
					for oLocalRover, ___ in pairs(tLocalRovers) do

						if not (oLocalRover:allowsEntryTo(oOutRover)) then
							bRet = false;
							break;
						end

					end

				end

			end

		end

		return bRet;
	end,

	removePort = function(this, oNode)
		assert(type(oNode) == "aStarNode", "Port must be of type, aStarNode.");

		if (tRepo[this].ports[oNode] and tRepo[oNode].ports[this]) then
			tRepo[this].ports[oNode] = nil;
			tRepo[oNode].ports[this] = nil;
		end

		return this;
	end,

	setPassable = function(this, bPassable)

		if (rawtype(bPassable) == "boolean") then
			tRepo[this].isPassable = bPassable;
		end

	end,

	togglePassable = function(this)
		tRepo[this].isPassable = not tRepo[this].isPassable;
	end,
};

local bHasInit = false;
function aStarNode.init(cStar, cStarMap, cStarLayer, cStarLayerConfig, cStarAspect, cStarPath, cStarRover, cStarUtil)

	if not (bHasInit) then
		aStar 				= cStar;
		aStarMap 			= cStarMap;
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

return aStarNode;
