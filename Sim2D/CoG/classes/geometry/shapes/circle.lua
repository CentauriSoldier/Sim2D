--[[*
@authors Centauri Soldier
@copyright Public Domain
@description
	<h2>circle</h2>
	<p></p>
@license <p>The Unlicense<br>
<br>
@moduleid circle
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
assert(type(class) == "function", "Error loading the circle class. It depends on class.");
assert(type(shape) == "class", "Error loading the circle class. It depends on the shape class.");
assert(type(point) == "class", "Error loading the circle class. It depends on the point class.");
assert(type(serialize) 		== "table", 	"Error loading the circle class. It depends on serialize.");
assert(type(deserialize)	== "table", 	"Error loading the circle class. It depends on deserialize.");

--localization
local class 		= class;
local serialize		= serialize;
local deserialize	= deserialize;
local type 			= type;
local point			= point;

class "circle" : extends(shape) {

	--[[
	@desc The constructor for the circle class.
	@func circle
	@mod circle
	@ret oCircle circle A circle object. Public properties are center and radius.
	]]
	__construct = function(this, pCenter, nRadius)
		this.center = 0;
		this.radius = 1;

		--check the point input and set values
		this.center = type(pCenter) == "point" and point(pCenter.x, pCenter.y) or point();

		--check the radius input and set values
		this.radius = (type(nRadius) == "number" and nRadius >= 0) and nRadius or 1;

	end,


	area = function()
		return math.pi * this.radius ^ 2;
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

		return math.sqrt( (this.center.x - x) ^ 2 + (this.center.y - y) ^ 2 ) < this.radius;
	end,


	circumference = function(this)
		return 2 * math.pi * this.radius;
	end,


	deserialize = function(this, sData)
		local tData = deserialize.table(sData);

		this.center 	= tData.center;
		this.radius 	= this.radius:deserialize(tData.radius);

		return this;
	end,


	--[[!
		@desc Serializes the object's data.
		@func circle.serialize
		@module circle
		@param bDefer boolean Whether or not to return a table of data to be serialized instead of a serialize string (if deferring serializtion to another object).
		@ret sData StringOrTable The data returned as a serialized table (string) or a table is the defer option is set to true.
	!]]
	serialize = function(this, bDefer)
		local tData = {
			center = this.center:seralize(),
			radius = this.radius,
		};

		if (not bDefer) then
			tData = serialize.table(tData);
		end

		return tData;
	end,
};

return circle;
