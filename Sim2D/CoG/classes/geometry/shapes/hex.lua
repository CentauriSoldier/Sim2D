--credits https://www.redblobgames.com/grids/hexagons/
--TODO create flat hex and pionty hex subclasses
assert(type(class) == "function", "Error loading the hex class. It depends on class.");
assert(type(shape) == "class", "Error loading the hex class. It depends on the shape class.");
assert(type(point) == "class", "Error loading the hex class. It depends on the point class.");
assert(type(serialize) 		== "table", 	"Error loading the hex class. It depends on serialize.");
assert(type(deserialize)	== "table", 	"Error loading the hex class. It depends on deserialize.");

--localization
local assert 		= assert;
local class 		= class;
local serialize		= serialize;
local deserialize	= deserialize;
local type 			= type;
local math			= math;
local point			= point;

local function recalculateVerticesAndPoly(this)
	this.vertices = {};

	--calculate the vertices
	for x = 1, 6 do
	    local angle_deg = 60 * (x - 1) - 30;
	    local angle_rad = math.pi / 180 * angle_deg

		this.vertices[x] = {
			x = this.center.x + this.size * math.cos(angle_rad),
	    	y = this.center.y + this.size * math.sin(angle_rad)
		};

	end

	--calculate the width and height
	this.width 	= math.sqrt(3) * this.size;
	this.height = this.size * 2;

	this.poly = {};

	--recalculate the poly
	local oLastPoint = this.vertices[#this.vertices];
	local nLastX = oLastPoint.x;
	local nLastY = oLastPoint.y;

	for x = 1, #this.vertices do
		local oPoint = this.vertices[x]
		local nX = oPoint.x;
		local nY = oPoint.y;
		-- Only store non-horizontal edges.
		if nY ~= nLastY then
			local index = #this.poly;
			this.poly[index+1] = nX;
			this.poly[index+2] = nY;
			this.poly[index+3] = (nLastX - nX) / (nLastY - nY);
		end
		nLastX = nX;
		nLastY = nY;
	end


end

class "hex" : extends(shape) {

	__construct = function(this, pCenter, nSize)
		this.center = point();
		this.size 	= type(nSize) == "number" and nSize or 1;
		
		if (type(pCenter) == "point") then
			this.center.x = pCenter.x;
			this.center.y = pCenter.y;
		end

		recalculateVerticesAndPoly(this);
	end,



	containsPoint = function(this, vPoint, vY)
		local sPointType 	= type(vPoint);
		local x 			= 0;
		local y 			= 0;

		if (sPointType == "point") then
			x = vPoint.x;
			y = vPoint.y;

		elseif (sPointType == "number" and type(vY) == "number") then
			x = vPoint;
			y = vY;
		end

		local lastPX = this.poly[#this.poly-2]
		local lastPY = this.poly[#this.poly-1]
		local bInside = false;

		for index = 1, #this.poly, 3 do
			local px = this.poly[index];
			local py = this.poly[index+1];
			local deltaX_div_deltaY = this.poly[index+2];

			if ((py > y) ~= (lastPY > y)) and (x < (y - py) * deltaX_div_deltaY + px) then
				bInside = not bInside;
			end

			lastPX = px;
			lastPY = py;
		end

		return bInside;
	end

};

return hex;
