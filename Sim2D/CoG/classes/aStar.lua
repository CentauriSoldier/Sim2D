--[[
Alter these to fit your game.
]]
enum("ASTAR", 			{"GRID", "NODE", "PATH", "ROVER"});
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

local class = class;
local math 	= math;
local type 	= type;

local aStar = {};

local tGrids 	= {};
local tNodes 	= {};
local tPaths 	= {};
local tRovers 	= {};


aStar = {
	Grid = class "aStar.Grid" {
		__construct = function(this, tProt, fShape, nWidth, nHeight)
			nWidth 	= (type(nWidth) 	== "number" and nWidth 	> 0) and math.floor(nWidth) 	or 1;
			nHeight = (type(nHeight) 	== "number" and nHeight > 0) and math.floor(nHeight) 	or 1;

			tGrids[this] = {
				nodes = {},
			};

			local tData = tGrids[this];

			--create the nodes
			for x = 1, nWidth do
				tData[x] = {};

				for y = 1, nHeight do
					tData[x][y] = aStar.Node(this, x, y);
				end

			end

		end,
	},
	Node = class "aStar.Node" {
		__construct = function(this, oGrid, nX, nY)
			tNodes[this] = {
				X = nX,
				Y = nY,
			};
		end,

		getCost = function(this, oRover)

		end,

		isPassable = function(this, oRover)

		end,
	},
	Path = class "aStar.Path" {
		__construct = function(this, oStartNode, oEndNode, oRover)
			tPaths[this] = {};
		end,

		getSteps = function(this)

		end,

		getStepCount = function(this)

		end,

	},
	Rover = class "aStar.Rover" {
		__construct = function(this)
			tRovers[this] = {
				affinities 	= {},
				aversions 	= {},
			};

		end,

		getAffinites = function(this)

		end,

		getAversions = function(this)

		end,

	},
};



return aStar;
