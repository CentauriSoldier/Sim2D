--[[*
@authors Centauri Soldier
@copyright Public Domain
@description
	<h2>rectangle</h2>
	<p></p>
@license <p>The Unlicense<br>
<br>
@moduleid rectangle
@version 1.1
@versionhistory
<ul>
	<li>
		<b>1.0</b>
		<br>
		<p>Created the module.</p>
	</li>
	<li>
		<b>1.1</b>
		<br>
		<p>Add serialize and deserialize methods.</p>
	</li>
</ul>
@website https://github.com/CentauriSoldier
*]]
assert(type(class) == "function", "Error loading the rectangle class. It depends on class.");
assert(type(shape) == "class", "Error loading the rectangle class. It depends on the shape class.");
assert(type(point) == "class", "Error loading the rectangle class. It depends on the point class.");
assert(type(serialize) 		== "table", 	"Error loading the rectangle class. It depends on serialize.");
assert(type(deserialize)	== "table", 	"Error loading the rectangle class. It depends on deserialize.");

--localization
local class 		= class;
local serialize		= serialize;
local deserialize	= deserialize;
local type 			= type;
local math			= math;
local point			= point;

--VERTEX_TOP_LEFT 	= "topLeft";
--VERTEX_TOP_RIGHT 	= "topRight";
--VERTEX_BOTOM_RIGHT 	= "bottomRight";
--VERTEX_BOTOM_LEFT 	= "bottomLeft";
--VERTEX_CENTER	 	= "center";

local function recalculateVertices(this)
	this.vertices.topRight.x 	= this.vertices.topLeft.x + this.width;
	this.vertices.topRight.y 	= this.vertices.topLeft.y;
	this.vertices.bottomLeft.x 	= this.vertices.topLeft.x;
	this.vertices.bottomLeft.y 	= this.vertices.topLeft.y + this.height;
	this.vertices.bottomRight.x	= this.vertices.topRight.x;
	this.vertices.bottomRight.y	= this.vertices.bottomLeft.y;
	this.vertices.center.x		= this.vertices.topLeft.x + this.width / 2;
	this.vertices.center.y		= this.vertices.topLeft.y + this.height / 2;
end


class "rectangle" : extends(shape) {

	--[[
	@desc The constructor for the rectangle class.
	@func rectangle
	@mod rectangle
	@ret oRectangle rectangle A rectangle object. Public properties are vertices (a table containing points for each corner [topLeft, topRight, bottomRight, bottomLeft, center]), width and height.
	]]
	__construct = function(this, pTopLeft, nWidth, nHeight)
		this.vertices 	= {
			topLeft 	= point(),
			topRight	= point(),
			bottomLeft	= point(),
			bottomRight	= point(),
			center 		= point(),
		};
		this.width 		= type(nWidth) == "number" 	and nWidth 	or 0;
		this.height 	= type(nHeight) == "number" and nHeight or 0;

		--check the point input
		if (type(pTopLeft) == "point") then
			this.vertices.topLeft.x = pTopLeft.x;
			this.vertices.topLeft.y = pTopLeft.y;
		end

		recalculateVertices(this);
	end,


	area = function()
		return this.width * this.height;
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

		return x >= this.vertices.topLeft.x and x <= this.vertices.topRight.x and
			   y >= this.vertices.topLeft.y and y <= this.vertices.bottomRight.y;
	end,

	deserialize = function(this, sData)
		local tData = deserialize.table(sData);

		this.vertices.topLeft	 	= this.vertices.topLeft:deserialize(tData.vertices.topLeft);
		this.vertices.topRight 		= this.vertices.topRight:deserialize(tData.vertices.topRight);
		this.vertices.bottomLeft 	= this.vertices.bottomLeft:deserialize(tData.vertices.bottomLeft);
		this.vertices.bottomRight 	= this.vertices.bottomRight:deserialize(tData.vertices.bottomRight);
		this.vertices.center		= this.vertices.center:deserialize(tData.vertices.center);

		this.width 		= tData.width;
		this.height 	= tData.height;
	end,

	perimeter = function(this)
		return 2 * this.width + 2 * this.height;
	end,

--[[
	pointIsOnPerimeter = function(this, vPoint, vY)

	end
]]
	recalculateVertices = function(this)
		recalculateVertices(this);
	end,


	--[[!
		@desc Serializes the object's data.
		@func rectangle.serialize
		@module rectangle
		@param bDefer boolean Whether or not to return a table of data to be serialized instead of a serialize string (if deferring serializtion to another object).
		@ret sData StringOrTable The data, returned as a serialized table (string) or a table is the defer option is set to true.
	!]]
	serialize = function(this, bDefer)
		local tData = {
			vertices 	= {
				topLeft		= this.vertices.topLeft:seralize(),
				topRight	= this.vertices.topRight:seralize(),
				bottomLeft 	= this.vertices.bottomLeft:seralize(),
				bottomRight = this.vertices.bottomRight:seralize(),
				center		= this.vertices.center:seralize(),
			},
			width 		= this.width,
			height 		= this.height,
		};

		if (not bDefer) then
			tData = serialize.table(tData);
		end

		return tData;
	end,

};

return rectangle;
