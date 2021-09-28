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

--localization
local class 		= class;
local deserialize	= deserialize;
local math 			= math;
local point			= point;
local serialize		= serialize;
local type 			= type;
local shape 		= shape;

local circle = class "circle" : extends(shape) {

	--[[
	@desc The constructor for the circle class.
	@func circle
	@mod circle
	@ret oCircle circle A circle object. Public properties are center and radius.
	]]
	__construct = function(this, pCenter, nRadius)
		this.center = type(pCenter) == "point" and pCenter or point();
		this.radius = (type(nRadius) == "number" and nRadius >= 0) and nRadius or 1;
	end,

	area = function(this)
		return math.pi * this.radius ^ 2;
	end,


	containsPoint = function(this, oPoint)
		return math.sqrt( (this.center.x - oPoint.x) ^ 2 + (this.center.y - oPoint.y) ^ 2 ) < this.radius;
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
