--credits https://www.redblobgames.com/grids/hexagons/
--TODO create flat hex and pointy hex subclasses

--localization
local assert 		= assert;
local class 		= class;
local constant 		= constant;
local deserialize	= deserialize;
local math			= math;
local point			= point;
local serialize		= serialize;
local type 			= type;
local shape			= shape;

constant("HEX_POINT_TOP_DEGREE_MODIFIER", 30);
local HEX_POINT_TOP_DEGREE_MODIFIER = HEX_POINT_TOP_DEGREE_MODIFIER;

local hexagon = class "hexagon" : extends(polygon) {

	__construct = function(this, pCenter, nSize, bIsFlat)
		this.center = point();--TODO this should be the centroid
		this.size 	= type(nSize) 	== "number" 	and nSize 	or 1;
		this.isFlat	= type(bIsFlat) == "boolean" 	and bIsFlat or false;

		if (type(pCenter) == "point") then
			this.center.x = pCenter.x;
			this.center.y = pCenter.y;
		end

		--calculate the width and height
		this.width 	= math.sqrt(3) * this.size;
		this.height = this.size * 2;

		--calculate the vertices
		--calculateVertices(this);

		--have the parent class process the object
		this:update();
	end,

	recalculateVertices = function(this)
		this.vertices 		= {};
		local nDegreeMod 	= this.isFlat and HEX_POINT_TOP_DEGREE_MODIFIER or 0;

		--calculate the vertices
		for x = 1, 6 do
		    local angle_deg = 60 * (x - 1) - nDegreeMod;
		    local angle_rad = math.pi / 180 * angle_deg

			this.vertices[x] = point(this.center.x + this.size * math.cos(angle_rad),
		    						 this.center.y + this.size * math.sin(angle_rad));
		end
	end,
};

return hexagon;
