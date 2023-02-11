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
require("CoG.init");
--============= TEST CODE BELOW =============

--local r = rectangle(point(0, 0), 25, 20);
--local t = rectangle(point(0, 0), 25, 20);
--local g = polygon({point(0,0), point(-5,5), point(10,10)});

--enum("LETTER", {"A","B","C","D"})

--local l = line(point(0, 40), point(0, 200));
--p(l:getTheta());
--p(g:getInteriorAngle(3))

--wolfram alpha code = polygon (0,0) (10,10) (-5,5)
local tBullet = {

};


local bullet = struct("bullet", {
	id 			= 34,
	velocity 	= 0,
	hasImpacted = false,
	block 		= {code = 45},
});
i = set();
--local k = bullet();
local k = bullet({id = "34sdf"});
--local t = bullet();
--p(s == null)
--k.id = NULL
--k.id =
--k.id = 44
--k.id = null
--k.id = "asd3234asd"
--k.id = 4567
--p(type(k))
--p(struct.struct.bullet)
--p(type(bullet))
--p(type(struct))
--constant("ZERO", 0)
--local sub = enum("SUB", {"ONE", "TWO"}, true);
--[[enum("TEST", {"SUB1", "SUB2"}, {enum("SUB1", {"ONE", "TWO", "THREE", "FOUR", "FIVE"}, nil, true),
								enum("SUB2", {"SIX", "SEVEN", "EIGHT", "NINE", "TEN"}, nil, true)
							});

t = {
	k = TEST.SUB1.TWO,
	r = TEST.SUB2.SEVEN,
}

enum("COLOR", {"RED", "GREEN", "BLUE"})
--st = serialize.table(t)
--print(12)
--print(type(TEST.SUB1.ONE.FIV));
local tSub1Meta = getmetatable(TEST.SUB1.TWO.parent);
local nMetaCount = 0;

for sIndex, vValue in TEST() do
	print(vValue)
end

--print(nMetaCount, serialize.table(tSub1Meta));
--print(type(TEST.SUB1()))
--print(TEST.SUB.valueType)
--print(st)
--print(type(TEST))
--print(COLOR.RED.enum.__name)

--check if item is of type enum.
]]
local k = point(0, 0);
local tVertices 	= {k, point(3, 4), point(3, 0)};
local bSkipUpdate 	= false;

local tri = polygon(tVertices, bSkipUpdate)

--print(ERRER.BLOOP.value)
print(type(u.c.a), u.c.a.value)
--print(type(u.c.a), u.c.a)
--print(_VERSION)
--directive.enum("C:\\Users\\CS\\Sync\\Projects\\GitHub\\Supremecratic\\Supremecratic\\CD_Root\\Data\\Mods\\Shipped\\Population.enum");
