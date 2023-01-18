--package.path = package.path..";LuaEx\\?.lua;..\\?.lua;?.lua";
package.path = package.path..";CoG\\?.lua";
require("init");
local function p(item)
	print(tostring(item).." ("..type(item)..")")
end

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
p(type(k))
--p(struct.struct.bullet)
--p(type(bullet))
--p(type(struct))
