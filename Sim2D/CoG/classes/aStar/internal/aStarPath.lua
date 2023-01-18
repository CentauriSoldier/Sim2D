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

--TODO account for caves/portals/etc. when doing pathfinding...add this functionality
--[[
Abhoration:
If a rover is abhorant to one or more of a node's
	aspects, it cannot move onto that node. It is,
	for that rover, immpassible even if it is an
	otherwise-passable node.

How entry cost is calculated:
* A rover desires to enter a node
* Assuming the rover is not abhorant to any of the
	node's aspects, the following equation is run
	for each of a node's aspects (if the aspect is > 0):
	Let F 	= Final Entry Cost
	Let M	= total value of all affinity/aversion values
	Let B	= Node base cost
	Let Naf	= node affinity value
	Let Raf = rover affinity value
	Let Rav	= rover aversion value
	M = M + B * (Rav - Raf);

	F = math.clamp(B + Naf * M, ASTAR_NODE_ENTRY_COST_MIN, ASTAR_NODE_ENTRY_COST_MAX);


	Note: since aspects, affinities and aversion are
	proteans, the client can affect the final values
	very granularly using penalties and bonuses if
	desired.

Regarding Groups:
* If one rover in a group is abhorant to a node
	or restricted from entry onto a layer,the
	entire group is restricted from entry.
* The farthest a group may go in a path is limited
	by the rover which can move the least distance.
]]
--[[██████╗░░█████╗░████████╗██╗░░██╗
	██╔══██╗██╔══██╗╚══██╔══╝██║░░██║
	██████╔╝███████║░░░██║░░░███████║
	██╔═══╝░██╔══██║░░░██║░░░██╔══██║
	██║░░░░░██║░░██║░░░██║░░░██║░░██║
	╚═╝░░░░░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░╚═╝]]
aStarPath = class "aStarPath" {
	__construct= function(this, prot, oStartNode, oEndNode, ...)
		local tRovers = {...} or arg;
		tRovers = (type(tRovers[1]) == "table") and tRovers[1] or tRovers;

		--TODO check the rovers table
		--TODO make sure the listed rovers are at the starting node

		tRepo[this] = {
			cost 		= {}, --indexed by rover object | values are cost for each rover
			currentStep	= 1, --refers to the nodes table index
			lastStep	= -1,
			nodes 		= {},
			notesDecoy	= {},
			onStep		= nil, --client-defined function or nil
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

	getCost = function(this, oRover)

	end,

	getCostTotal = function(this)

	end,

	getNextNode = function(this)

	end,

	getNodes = function(this)

	end,

	getNodeCount = function(this)

	end,

	getRovers = function(this)

	end,

	setOnStepCallback = function(this, fFunc)

		if (type(fFunc) == "function") then
			tRepo[this].onStep = fFunc;
		else
			tRepo[this].onStep = nil;
		end

		return this;
	end,

	step = function(this) --TODO finish this
		local tFields = tRepo[this];

		if (tFields.onStep) then
			local oCurrentStep 	= tFields.nodes[tFields.currentStep] 	or nil;
			local oLastStep 	= tFields.nodes[tFields.lastStep] 		or nil;

			onStep(	this, 					tFields.roversDecoy,
					tFields.currentStep,	tFields.totalSteps,
					oCurrentStep, 			oLastStep);
		end


	end,
};

local bHasInit = false;
function aStarPath.init(cStar, cStarMap, cStarLayer, cStarLayerConfig, cStarNode, cStarAspect, cStarRover, cStarUtil)

	if not (bHasInit) then
		aStar 				= cStar;
		aStarMap 			= cStarMap;
		aStarLayer 			= cStarLayer;
		aStarLayerConfig 	= cStarLayerConfig;
		aStarNode 			= cStarNode;
		aStarAspect 		= cStarAspect;
		aStarRover 			= cStarRover;
		aStarUtil			= cStarUtil;
		bHasInit 			= true;
	end

end

return aStarPath;
