--[[*
@authors Centauri Soldier
@copyright Public Domain
@description
	<h2>pot</h2>
	<p>A logical potentiometer object. The client can set minimum and maximum values for the object, as well as rate of increase/decrease.
	Note: 'increase' and 'decrease' are logical terms referring to motion along a line based on the current direction. E.g., If a pot is
	alternating and descening, 'increase' would cause the positional value to be absolutely reduced, while 'decrease' would have the opposite
	affect.
	By default, values are clamped at min and max; however, if the object is set to be revolving (or alternating), any values which exceed the minimum or maximum
	boundaries, are carried over. For example, imagine a pot is set to have a min value of 0 and a max of 100. Then, imagine its position is set to 120.
	If revolving, it would have a final positional value of 19; if alternating it would have a final positional value of 80 and, if neither, its final positional
	value would be 100.</p>
@license <p>The Unlicense<br>
<br>
@moduleid pot
@version 1.2
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
		<p>Added the option for the potentiometer to be continuous in a revolving manner.</p>
	</li>
	<li>
		<b>1.2</b>
		<br>
		<p>Fixed a bug in the revolution mechanism.</p>
		<p>Added the ability which allows the potentiometer to be continuous in a revolving or alternating manner.</p>
	</li>
	<li>
		<b>1.3</b>
		<br>
		<p>Added serialization and deserialization methods.</p>
	</li>
</ul>
@website https://github.com/CentauriSoldier
*]]
local tPots = {};

assert(type(const) 			== "function", 	"Error loading the pot class. It depends on const.");
assert(type(serialize) 		== "table", 	"Error loading the pot class. It depends on serialize.");
assert(type(deserialize)	== "table", 	"Error loading the pot class. It depends on deserialize.");

POT						= const("POT", "", true);
POT.CONTINUITY			= const("POT.CONTINUITY", "", true);
POT.CONTINUITY.NONE		= 0;
POT.CONTINUITY.REVOLVE	= 1
POT.CONTINUITY.ALT		= 2;

--localization
local class 		= class;
local serialize 	= serialize;
local deserialize 	= deserialize;
local math 			= math;
local POT 			= POT;

local function clampMin(oPot)

	if (oPot.min >= oPot.max) then
		oPot.min = oPot.max - 1;
	end

end

local function clampMax(oPot)

	if (oPot.max <= oPot.min) then
		oPot.max = oPot.min + 1;
	end

end

--this is a placeholder so clampPosMin can call clampPosMax
local function clampPosMax()end

local function clampPosMin(oPot)

	if (oPot.pos < oPot.min) then

		if (oPot.continuity == POT.CONTINUITY.REVOLVE) then
			oPot.pos = oPot.min + math.abs(oPot.max - math.abs(-oPot.pos + 1));
			clampPosMin(oPot);

		elseif (oPot.continuity == POT.CONTINUITY.ALT) then
			oPot.pos = oPot.min + (oPot.min - oPot.pos);
			oPot.toggleAlternator = true;
			clampPosMax(oPot);

		else
			oPot.pos = oPot.min;

		end

	else

		--check if the alternator needs toggled
		if (oPot.toggleAlternator) then
			oPot.alternator = oPot.alternator * -1;
			oPot.toggleAlternator = false;
		end

	end


end

local function clampPosMax(oPot)

	if (oPot.pos > oPot.max) then

		if (oPot.continuity == POT.CONTINUITY.REVOLVE) then
			oPot.pos = oPot.pos - math.abs(oPot.max - oPot.min + 1);
			clampPosMax(oPot);

		elseif (oPot.continuity == POT.CONTINUITY.ALT) then
			oPot.pos = oPot.max - (oPot.pos - oPot.max);
			oPot.toggleAlternator = true;
			clampPosMin(oPot);

		else
			oPot.pos = oPot.max;

		end

	else

		--check if the alternator needs toggled
		if (oPot.toggleAlternator) then
			oPot.alternator = oPot.alternator * -1;
			oPot.toggleAlternator = false;
		end

	end

end

local function clampRate(oPot)
	local nVariance = oPot.max - oPot.min;

	if (math.abs(oPot.rate) > math.abs(nVariance)) then
		oPot.rate = nVariance;
	end

end



class "pot" {

	__construct = function(this, nMin, nMax, nPos, nRate, nContinuity)
		tPots[this] = {
			alternator			= 1,
			continuity			= POT.CONTINUITY.NONE,
			min 				= 0,
			max 				= 100,
			pos 				= 0,
			toggleAlternator 	= false,
			rate 				= 1,
		};

		local oPot = tPots[this];

		--set the min
		if (type(nMin) == "number") then
			oPot.min = nMin;
		end

		--set the max
		if (type(nMax) == "number") then
			oPot.max = nMax;
			clampMax(oPot);
		end

		--set the position
		if (type(nPos) == "number") then
			oPot.pos = nPos;
			clampPosMin(oPot);
			clampPosMax(oPot);
		end

		--set the rate
		if (type(nRate) == "number") then
			oPot.rate = nRate;
			clampRate(oPot);
		end

		--set continuity type
			oPot.continuity = (nContinuity and POT.CONTINUITY.isMyConst(nContinuity)) and nContinuity or POT.CONTINUITY.NONE;
	end,


	adjust = function(this, nValue)
		local oPot = tPots[this];
		local nAmount = oPot.rate;

		--allow correct input
		if (type(nValue) == "number") then
			nAmount = nValue;
		end

		--set the value
		oPot.pos = oPot.pos + nAmount;

		--clamp it
		clampPosMin(oPot);
		clampPosMax(oPot);

		return tPots[this].pos;
	end,


	decrease = function(this, nTimes)
		local oPot = tPots[this];
		local nCount = 1;

		if (type(nTimes) == "number") then
			nCount = nTimes;
		end

		--set the value
		oPot.pos = oPot.pos - oPot.rate * nCount * oPot.alternator;

		--clamp it
		if (oPot.continuity == POT.CONTINUITY.ALT) then
			clampPosMax(oPot);
		end

		clampPosMin(oPot);

		return oPot.pos;
	end,

	deserialize = function(this, sData)
		local oPot = tPots[this];
		local tData = deserialize.table(sData);

		oPot.alternator 		= tData.alternator;
		oPot.continuity 		= tData.continuity;
		oPot.min 				= tData.min;
		oPot.max 				= tData.max;
		oPot.pos 				= tData.pos;
		oPot.toggleAlternator 	= tData.toggleAlternator;
		oPot.rate 				= tData.rate;

		return this;
	end,

	destroy = function(this)
		table.remove(tPots, this);
		this = nil;
	end,

	getMax = function(this)
		return tPots[this].max;
	end,

	getMin = function(this)
		return tPots[this].min;
	end,

	getPos = function(this)
		return tPots[this].pos;
	end,

	getRate = function(this)
		return tPots[this].rate;
	end,

	getContinuity = function(this)
		return tPots[this].continuity;
	end,

	increase = function(this, nTimes)
		local oPot = tPots[this];
		local nCount = 1;

		if (type(nTimes) == "number") then
			nCount = nTimes;
		end

		--set the value
		oPot.pos = oPot.pos + oPot.rate * nCount * oPot.alternator;

		--clamp it
		if (oPot.continuity == POT.CONTINUITY.ALT) then
			clampPosMin(oPot);
		end

		clampPosMax(oPot);

		return oPot.pos;
	end,

	isAlternating = function(this)
		return tPots[this].continuity == POT.CONTINUITY.ALT;
	end,

	isAscending = function(this)
		return (
			(tPots[this].continuity == POT.CONTINUITY.REVOLVE or
		    tPots[this].continuity 	== POT.CONTINUITY.ALT) and
	        tPots[this].alternator 	== 1
		  );
	end,

	isDescending = function(this)
		return (
			(tPots[this].continuity == POT.CONTINUITY.REVOLVE or
		    tPots[this].continuity 	== POT.CONTINUITY.ALT) and
	        tPots[this].alternator 	== -1
		  );
	end,

	isRevolving = function(this)
		return tPots[this].revolving == POT.CONTINUITY.REVOLVE;
	end,

	--[[!
		@desc Serializes the object's data.
		@func pot.serialize
		@module pot
		@param bDefer boolean Whether or not to return a table of data to be serialized instead of a serialize string (if deferring serializtion to another object).
		@ret sData StringOrTable The data returned as a serialized table (string) or a table is the defer option is set to true.
	!]]
	serialize = function(this, bDefer)
		local oPot = tPots[this];
		local tData = {
			alternator			= oPot.alternator,
			continuity			= oPot.continuity,
			min 				= oPot.min,
			max 				= oPot.max,
			pos 				= oPot.pos,
			toggleAlternator 	= oPot.toggleAlternator,
			rate 				= oPot.rate,
		};

		if (not bDefer) then
			tData = serialize.table(tData);
		end

		return tData;
	end,

	setMax = function(this, nValue)
		local oPot = tPots[this];

		if (type(nValue) == "number") then
			oPot.max = nValue;
			clampMax(oPot);
			clampPosMax(oPot)
		end

	end,

	setMin = function(this, nValue)
		local oPot = tPots[this];

		if (type(nValue) == "number") then
			oPot.min = nValue;
			clampMin(oPot);
			clampPosMin(oPot)
		end

	end,

	setPos = function(this, nValue)
		local oPot = tPots[this];

		if (type(nValue) == "number") then
			oPot.pos = nValue;
			clampPosMin(oPot);
			clampPosMax(oPot);
		end

		return oPot.pos;
	end,

	setRate = function(this, nValue)
		local oPot = tPots[this];

		if (type(nValue) == "number") then
			oPot.rate = math.abs(nValue);
			clampRate(oPot);
		end

		return oPot.pos;
	end,

	setRevolving = function(this, bRevolving)
		local oPot 	= tPots[this];
		local sType = type(bRevolving);

		if (sType == "boolean") then
			oPot.revolving = bRevolving;

		elseif (sType == "nil") then
			oPot.revolving = false;

		elseif (sType == "number") then

			if (bRevolving == 0) then
				oPot.revolving = false;
			elseif (bRevolving == 1) then
				oPot.revolving = true;
			end

		end

		return oPot.pos;
	end,

};

return pot;
