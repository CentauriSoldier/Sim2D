--[[*
@authors Centauri Soldier
@copyright Public Domain
@description
	<h2>rectangle</h2>
	<p>This is a basic point class. Unlike many classes, it has no private members or properties. x and y will grant access to the respective values.</p>
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

--localization
local class 		= class;
local serialize		= serialize;
local deserialize	= deserialize;
local type 			= type;
local math			= math;

local point = class "point" {

	--[[
	@desc This is the constructor for the point class.
	@func point The constructor for the point class.
	@mod point
	@param nX number The x value. If nil, it defaults to 0.
	@param nY number The y value. If nil, it defaults to 0.
	]]
	__construct = function(this, nX, nY)
		this.x = 0;
		this.y = 0;

		if (type(nX) == "number") then
			this.x = nX;
		end

		if (type(nY) == "number") then
			this.y = nY;
		end

	end,

	--[[
	@desc Adds two points together.
	@func __add
	@mod point
	@ret oPoint point A new point with the values of the two points added together. If an incorrect paramters is passed, a new point with the values of the correct paramter (the point) is returned.
	]]
	__add = function(this, vRight)

		if (type(this) == "point" and type(vRight) == "point") then
			return point(this.x + vRight.x,
						 this.y + vRight.y);
		end


	end,

	--[[__div = function(this, vRight)
		local sType = type(vRight);

		if (sType == "point") then
			this.x = this.x / vRight.x;
			this.y = this.y + vRight.y;
		--elseif (sType == "table") then

		end

		return this;
	end,
]]
	__eq = function(this, vRight)
		return type(vRight) == "point" and this.x == vRight.x and this.y == vRight.y;
	end,

	__le = function(this, vRight)
		return type(vRight) == "point" and this.x <= vRight.x and this.y <= vRight.y;
	end,


	__lt = function(this, vRight)
		return type(vRight) == "point" and this.x < vRight.x and this.y < vRight.y;
	end,


	--[[__mul = function(this, vRight)
		local sType = type(vRight);

		if (sType == "point") then
			this.x = this.x + vRight.x;
			this.y = this.y + vRight.y;
		--elseif (sType == "table") then

		end

		return this;
	end,]]


	__sub = function(this, vRight)
		local sType = type(vRight);

		if (sType == "point") then
			return point(this.x - vRight.x,
						 this.y - vRight.y);
		end

	end,

	__tostring = function(this)
		return "x: "..this.x.." y: "..this.y;
	end,

	deserialize = function(this, sData)
		local tData = deserialize.table(sData);

		this.x = tData.x;
		this.y = tData.y;

		return this;
	end,

	distance = function(this, oOther)
		local nRet = 0;

		if (type(this) == "point" and type(oOther) == "point") then
			nRet = math.sqrt( (this.x - oOther.x) ^ 2 + (this.y - oOther.y) ^ 2);
		end

		return nRet;
	end,

	--[[!
		@desc Serializes the object's data.
		@func point.serialize
		@module point
		@param bDefer boolean Whether or not to return a table of data to be serialized instead of a serialize string (if deferring serializtion to another object).
		@ret sData StringOrTable The data returned as a serialized table (string) or a table is the defer option is set to true.
	!]]
	serialize = function(this, bDefer)
		local tData = {
			x = this.x,
			y = this.y,
		};

		if (not bDefer) then
			tData = serialize.table(tData);
		end

		return tData;
	end,

	slope = function(this, oOther)
		local nRet = 0;

		if (type(this) == "point" and type(oOther) == "point") then
			nXDelta = this.x - oOther.x;
			nYDelta = this.y - oOther.y;

			if (nYDelta == 0) then
				nRet = MATH_UNDEF;
			else
				nRet = math.atan(nYDelta / nXDelta);
				--nRet = nYDelta / nXDelta;
			end

		end

		return nRet;
	end,
};

return point;
