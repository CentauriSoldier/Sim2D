function getsourcepath()
	--determine the call location
	local sPath = debug.getinfo(1, "S").source;
	--remove the calling filename
	local sFilenameRAW = sPath:match("^.+"..package.config:sub(1,1).."(.+)$");
	--make a pattern to account for case
	local sFilename = "";
	for x = 1, #sFilenameRAW do
		local sChar = sFilenameRAW:sub(x, x);

		if (sChar:find("[%a]")) then
			sFilename = sFilename.."["..sChar:upper()..sChar:lower().."]";
		else
			sFilename = sFilename..sChar;
		end

	end
	sPath = sPath:gsub("@", ""):gsub(sFilename, "");
	--remove the "/" at the end
	sPath = sPath:sub(1, sPath:len() - 1);

	return sPath;
end

--determine the call location
local sPath = getsourcepath();

--update the package.path (use the main directory to prevent namespace issues)
package.path = package.path..";"..sPath.."\\..\\?.lua;";

--load LuaEx
require("init");
--============= TEST CODE BELOW =============
local oAStar = aStar("TEMPERATURE", "AQuIFER", "COMPACTION", "DETRITUS", "FORAGEABILITY", "FORESTATION",
					"GRADE", "ICINESS", "PALUDALISM", "ROCKINESS", "ROAD", "SNOWINESS",
					"VERDURE", "TOXICITY");
local tA = oAStar.aspectNames;

local groundConfig = aStar.newLayerConfig("TERRAIN", {tA.AQUIFER, tA.COMPACTION, tA.DETRITUS});
--print(type(groundConfig))
local oWorldMap = oAStar:newMap("World Map", ASTAR_MAP_TYPE_HEX_POINTED, {groundConfig}, 50, 28);
local oTerrainLayer = oWorldMap:getLayer("TERRAIN");
local oNode = oTerrainLayer:getNode(3, 5);
local oRover1 = oNode:createRover();
local oRover2 = oNode:createRover();
--oRover:getAbhoration(tA.AQuIFER):set(PROTEAN_BASE_BONUS, 0.12);
--print(oRover:setAbhors(tA.AQuIFER, false):toggleAbhors(tA.AQuIFER):abhors(tA.AQuIFER))

oAStar.newPath(oTerrainLayer:getNode(1, 1), oTerrainLayer:getNode(10, 10), oRover1, oRover2)

--local oProt = oWorldMap:getLayer("TERRAIN"):getNode(3, 5):getAspect("AQUIFER"):getImpactor();
--oProt:set(PROTEAN_ADDATIVE_BONUS, 0.21)
--print(oWorldMap:getLayer("TERRAIN"):getNode(3, 5):getImpact("AQUIFER"))
--local tWorldMapLayers = oWorldMap:getLayers();

--print(oAStar:getNode("World Map", "Ground", 10, 24):getPassable());

--for nID, oLayer in pairs(tWorldMapLayers) do

	--local tNodes = oLayer:getNodes();

	--for x, tXNodes in pairs(tNodes) do

		--for y, oNode in pairs(tXNodes) do
			--local tPos = oNode:getPos();
			--print(tPos.x, tPos.y)
		--end

	--end

--end
