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
		<b>1.4</b>
		<br>
		<p>Bugfix: clamping values was not working correctly cause unpredictable results.</p>
	</li>
	<li>
		<b>1.3</b>
		<br>
		<p>Added serialization and deserialization methods.</p>
	</li>
	<li>
		<b>1.2</b>
		<br>
		<p>Fixed a bug in the revolution mechanism.</p>
		<p>Added the ability which allows the potentiometer to be continuous in a revolving or alternating manner.</p>
	</li>
	<li>
		<b>1.1</b>
		<br>
		<p>Added the option for the potentiometer to be continuous in a revolving manner.</p>
	</li>
	<li>
		<b>1.0</b>
		<br>
		<p>Created the module.</p>
	</li>
</ul>
@website https://github.com/CentauriSoldier
*]]
local tPots = {};
local pot;

--the default values in case constructor input is bad
local nMinDefault 	= 0;
local nMaxDefault 	= 99;
local nRateDefault 	= 1;

--make these publicy available
constant("POT_CONTINUITY_NONE", 	0);
constant("POT_CONTINUITY_REVOLVE", 	1);
constant("POT_CONTINUITY_ALT", 		2);

--now localize them
local POT_CONTINUITY_NONE 		= POT_CONTINUITY_NONE;
local POT_CONTINUITY_REVOLVE 	= POT_CONTINUITY_REVOLVE;
local POT_CONTINUITY_ALT 		= POT_CONTINUITY_ALT;



local class 					= class;
local serialize 				= serialize;
local deserialize 				= deserialize;
local math 						= math;


local function continuityIsValid(nVal)

	return rawtype(nVal) == "number" and
		   (nVal == POT_CONTINUITY_NONE 	or
		    nVal == POT_CONTINUITY_REVOLVE 	or
			nVal == POT_CONTINUITY_ALT);
end


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

		if (oPot.continuity == POT_CONTINUITY_REVOLVE) then
			oPot.pos = oPot.min + math.abs(oPot.max - math.abs(-oPot.pos + 1));
			clampPosMin(oPot);

		elseif (oPot.continuity == POT_CONTINUITY_ALT) then
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

		if (oPot.continuity == POT_CONTINUITY_REVOLVE) then
			oPot.pos = oPot.pos - math.abs(oPot.max - oPot.min + 1);
			clampPosMax(oPot);

		elseif (oPot.continuity == POT_CONTINUITY_ALT) then
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



pot = class "pot" {

	--[[!
		@desc
		@func
		module
		@param
		@ret
	!]]
	__construct = function(this, tProt, nMin, nMax, nPos, nRate, nContinuity)
		tPots[this] = {
			alternator			= 1,
			continuity			= continuityIsValid(nContinuity) and nContinuity or POT_CONTINUITY_NONE,
			min 				= rawtype(nMin) == "number" and nMin or nMinDefault,
			max 				= rawtype(nMax) == "number" and nMax or nMaxDefault,
			pos 				= rawtype(nPos) == "number" and nPos or nMinDefault,
			toggleAlternator 	= false,
			rate 				= rawtype(nRate) == "number" and nRate or nRateDefault,
		};

		local oPot = tPots[this];
		clampPosMin(oPot);
		clampPosMax(oPot);
		clampRate(oPot);
	end,


	--[[!
		@desc
		@func
		module
		@param
		@ret
	!]]
	adjust = function(this, nValue)
		local oPot = tPots[this];
		local nAmount = oPot.rate;

		--allow correct input
		if (rawtype(nValue) == "number") then
			nAmount = nValue;
		end

		--set the value
		oPot.pos = oPot.pos + nAmount;

		--clamp it
		clampPosMin(oPot);
		clampPosMax(oPot);

		return this;
	end,


	--[[!
		@desc
		@func
		module
		@param
		@ret
	!]]
	decrease = function(this, nTimes)
		local oPot = tPots[this];
		local nCount = 1;

		if (rawtype(nTimes) == "number") then
			nCount = nTimes;
		end

		--set the value
		oPot.pos = oPot.pos - oPot.rate * nCount * oPot.alternator;

		--clamp it
		if (oPot.continuity == POT_CONTINUITY_ALT) then
			clampPosMax(oPot);
		end

		clampPosMin(oPot);

		return this;
	end,

	--[[!
		@desc
		@func
		module
		@param
		@ret
	!]]
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

	--[[!
		@desc
		@func
		module
		@param
		@ret
	!]]
	destroy = function(this)
		table.remove(tPots, this);
		this = nil;
	end,

	--[[!
		@desc
		@func
		module
		@param
		@ret
	!]]
	getMax = function(this)
		return tPots[this].max;
	end,

	--[[!
		@desc
		@func
		module
		@param
		@ret
	!]]
	getMin = function(this)
		return tPots[this].min;
	end,

	--[[!
		@desc
		@func
		module
		@param
		@ret
	!]]
	getPos = function(this)
		return tPots[this].pos;
	end,

	--[[!
		@desc
		@func
		module
		@param
		@ret
	!]]
	getRate = function(this)
		return tPots[this].rate;
	end,

	--[[!
		@desc
		@func
		module
		@param
		@ret
	!]]
	getContinuity = function(this)
		return tPots[this].continuity;
	end,

	--[[!
		@desc
		@func
		module
		@param
		@ret
	!]]
	increase = function(this, nTimes)
		local oPot 		= tPots[this];
		local nCount 	= rawtype(nTimes) == "number" and nTimes or 1;

		--set the value
		oPot.pos = oPot.pos + (oPot.rate * nCount * oPot.alternator);

		--clamp it
		if (oPot.continuity == POT_CONTINUITY_ALT) then
			clampPosMin(oPot);
		end

		clampPosMax(oPot);

		return this;
	end,

	--[[!
		@desc
		@func
		module
		@param
		@ret
	!]]
	isAlternating = function(this)
		return tPots[this].continuity == POT_CONTINUITY_ALT;
	end,

	--[[!
		@desc
		@func
		module
		@param
		@ret
	!]]
	isAscending = function(this)
		return (
			(tPots[this].continuity == POT_CONTINUITY_REVOLVE or
		    tPots[this].continuity 	== POT_CONTINUITY_ALT) and
	        tPots[this].alternator 	== 1
		  );
	end,

	--[[!
		@desc
		@func
		module
		@param
		@ret
	!]]
	isDescending = function(this)
		return (
			(tPots[this].continuity == POT_CONTINUITY_REVOLVE or
		    tPots[this].continuity 	== POT_CONTINUITY_ALT) and
	        tPots[this].alternator 	== -1
		  );
	end,

	--[[!
		@desc
		@func
		module
		@param
		@ret
	!]]
	isRevolving = function(this)
		return tPots[this].revolving == POT_CONTINUITY_REVOLVE;
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

	--[[!
		@desc
		@func
		module
		@param
		@ret
	!]]
	setMax = function(this, nValue)
		local oPot = tPots[this];

		if (rawtype(nValue) == "number") then
			oPot.max = nValue;
			clampMax(oPot);
			clampPosMax(oPot)
		end

		return this;
	end,

	--[[!
		@desc
		@func
		module
		@param
		@ret
	!]]
	setMin = function(this, nValue)
		local oPot = tPots[this];

		if (rawtype(nValue) == "number") then
			oPot.min = nValue;
			clampMin(oPot);
			clampPosMin(oPot)
		end

		return this;
	end,

	--[[!
		@desc
		@func
		module
		@param
		@ret
	!]]
	setPos = function(this, nValue)
		local oPot = tPots[this];

		if (rawtype(nValue) == "number") then
			oPot.pos = nValue;
			clampPosMin(oPot);
			clampPosMax(oPot);
		end

		return this;
	end,

	--[[!
		@desc
		@func
		module
		@param
		@ret
	!]]
	setRate = function(this, nValue)
		local oPot = tPots[this];

		if (rawtype(nValue) == "number") then
			oPot.rate = math.abs(nValue);
			clampRate(oPot);
		end

		return this;
	end,

	--[[!
		@desc
		@func
		module
		@param
		@ret
	!]]
	setContinuity = function(this, nContinuity)
		local oPot = tPots[this];
		oPot.continuity = continuityIsValid(nContinuity) and nContinuity or oPot.continuity;
		print("Continuity Set to :"..oPot.continuity.." from input value of: "..nContinuity);
		return this;
	end,

};

return pot;
