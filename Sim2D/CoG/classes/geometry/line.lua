--[[*
@authors Centauri Soldier
@copyright Public Domain
@description
	<h2>triangle</h2>
	<p></p>
@license <p>The Unlicense<br>
<br>
@moduleid line
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

--[[
--TODO this does not works correctly...fix it
theta = function(this, oOther)
	local nRet = 0;

	if (type(this) == "point" and type(oOther) == "point") then
		nXDelta = this.x - oOther.x;
		nYDelta = this.y - oOther.y;

		if (nYDelta == 0) then
			nRet = MATH.UNDEF;
		else
			nRet = math.atan(nYDelta / nXDelta);
		end

	end

	return nRet;
end,
]]

--localization
local class 		= class;
local deserialize	= deserialize;
local math			= math;
local point 		= point;
local serialize		= serialize;
local type 			= type;

class "line" {

	__construct = function(this, oStartPoint, oEndPoint)
		this.start 	= point(0, 0);
		this.stop 	= point(0, 0);
		this.center = point(0, 0);

		if (type(oStartPoint) == "point") then
			this.start.x = oStartPoint.x;
			this.start.y = oStartPoint.y;
		end

		if (type(oEndPoint) == "point") then
			this.stop.x = oEndPoint.x;
			this.stop.y = oEndPoint.y;
		end

		this.center.x = (this.start.x + this.stop.x) / 2;
		this.center.y = (this.start.y + this.stop.y) / 2;

	end,


	__len = function(this)
		return math.math.sqrt( (this.start.x - this.stop.x) ^ 2 + (this.start.y - this.stop.y) ^ 2);
	end,


	deserialize = function(this, sData)
		local tData = deserialize.table(sData);

		this.start = this.start:deserialize(tData.start);
		this.stop	= this.stop:deserialize(tData.stop);

		return this;
	end,

	length = function(this)
		return math.math.sqrt( (this.start.x - this.stop.x) ^ 2 + (this.start.y - this.stop.y) ^ 2);
	end,


	intersects = function(this, oOther)

	end,


	intersectsAt = function(this, oOther)

	end,


	isParrallel = function(this, oOther)
		local bRet = false;

		if (type(this) == "line" and type(oOther) == "line") then
			local nMySlope 			= this:slope();
			local nOtherSlope 		= oOther:slope();
			local sMySlopeType		= type(nMySlope);
			local sOtherSlopeType	= type(nOtherSlope);


			if (sMySlopeType == "number" and sOtherSlopeType == "number") then
				bRet = nMySlope == nOtherSlope;

			elseif (sOtherSlopeType == "string" and sOtherSlopeType == "string") then
				bRet = true;

			end

		end


		return bRet;
	end,

	recalculateCenter = function(this)
		this.centerPoint.x = (this.start.x + this.stop.x) / 2;
		this.centerPoint.y = (this.start.y + this.stop.y) / 2;
	end,

	--[[!
		@desc Serializes the object's data.
		@func line.serialize
		@module line
		@param bDefer boolean Whether or not to return a table of data to be serialized instead of a serialize string (if deferring serializtion to another object).
		@ret sData StringOrTable The data, returned as a serialized table (string) or a table is the defer option is set to true.
	!]]
	serialize = function(this, bDefer)
		local tData = {
			start 	= this.start:seralize(),
			stop 	= this.stop:serialize(),
		};

		if (not bDefer) then
			tData = serialize.table(tData);
		end

		return tData;
	end,


	slope = function(this)
		local nRet = 0;
		local nYDelta = this.stop.y - this.start.y;

		if (nYDelta == 0) then
			nRet = MATH.UNDEF;
		else
			nRet = nYDelta / (this.stop.x - this.start.x);
		end

		return nRet;
	end,

}
