--[[*
@authors Centauri Soldier
@copyright Public Domain
@description
	<h2>iota</h2>
	<p></p>
@license <p>The Unlicense<br>
<br>
@moduleid shape
@version 1.0
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
		<p>Addded callback functions.</p>
	</li>
	<li>
		<b>1.2</b>
		<br>
		<p>Removed dependence on AAA.</p>
	</li>
</ul>
@website https://github.com/CentauriSoldier
*]]
local iota;
local sIota = 'iota';


--set the constants for this class
--[[IOTA 						= const("IOTA");
IOTA.YEARS					= "years";
IOTA.DAYS 					= "days";
IOTA.HOURS 					= "hours";
IOTA.MINUTES 				= "minutes";
IOTA.SECONDS 				= "seconds";
IOTA.MAX					= const("IOTA.MAX", 'Max numbers for iota values.', true);
IOTA.MAX.YEARS				= 999999; --if you make this value larger, be sure to reduce the precache years max
IOTA.MAX.DAYS 				= 365;
IOTA.MAX.HOURS 				= 24;
IOTA.MAX.MINUTES 			= 60;
IOTA.MAX.SECONDS			= 60;
IOTA.CALLBACK				= const('IOTA.CALLBACK', 'Call back functions for when values change.', true);
IOTA.CALLBACK.ON_SECOND		= 'onSecond';
IOTA.CALLBACK.ON_MINUTE		= 'onMinute';
IOTA.CALLBACK.ON_HOUR		= 'onHour';
IOTA.CALLBACK.ON_DAY		= 'onDay';
IOTA.CALLBACK.ON_YEAR		= 'onYear';
]]

IOTA 						= {
	YEARS					= "years",
	DAYS 					= "days",
	HOURS 					= "hours",
	MINUTES 				= "minutes",
	SECONDS 				= "seconds",
	--if you make the year value larger, be sure to reduce the precache years max
	MAX					= enum("IOTA.MAX", {"YEARS", "DAYS", "HOURS", "MINUTES", "SECONDS"}, {99999, 365, 24, 60, 60}, true);
	CALLBACK			= enum("IOTA.CALLBACK", {"ON_SECOND", "ON_MINUTE", "ON_HOUR", "ON_DAY", "ON_YEAR"}, {"onMinute", "onSecond", "onHour", "onDay", "onYear"}, true);
};

table.settype(IOTA, 			"IOTA");
table.setsubtype(IOTA.MAX, 		"IOTA.MAX");
table.setsubtype(IOTA.CALLBACK, "IOTA.CALLBACK");
table.lock(IOTA);

local tIota = {};
local tIotas = {};

--localization
local IOTA 		= IOTA;
local math 		= math;
local unpack 	= unpack;
local type 		= type;
local class 	= class;
local pairs 	= pairs;
local string 	= string;

--=====================================================>
-- 					String Precache
--=====================================================>
--this is the place that strings are stored for use by the __tostring method

--used by the __tostring method
local sBlank 	= "";
local sYears 	= "";
local sDays 	= "";
local sHours 	= "";
local sMinutes 	= "";
local sSeconds 	= "";

--CHANGE THESE TO YOUR LIKING
local sYearPrefix 	= "Year: ";
local sDayPrefix 	= " Day: ";
local sHourPrefix 	= " Hour: ";
local sMinutePrefix = " Minute: ";
local sSecondPrefix = " Second: ";

--DO NOT CHANGE THESE VALUES
local PRECACHE_YEARS 	= 1;
local PRECACHE_DAYS 	= 2;
local PRECACHE_HOURS 	= 3;
local PRECACHE_MINUTES 	= 4;
local PRECACHE_SECONDS 	= 5;

local tStringPreCache = {
	[PRECACHE_YEARS] 	= {max = IOTA.MAX.YEARS.value, 		func = function(nValue) return sYearPrefix	..tostring(nValue) 				end},
	[PRECACHE_DAYS] 	= {max = IOTA.MAX.DAYS.value, 		func = function(nValue) return sDayPrefix	..string.format("%03d", nValue) end},
	[PRECACHE_HOURS] 	= {max = IOTA.MAX.HOURS.value, 		func = function(nValue) return sHourPrefix	..string.format("%02d", nValue) end},
	[PRECACHE_MINUTES] 	= {max = IOTA.MAX.MINUTES.value, 	func = function(nValue) return sMinutePrefix..string.format("%02d", nValue) end},
	[PRECACHE_SECONDS] 	= {max = IOTA.MAX.SECONDS.value, 	func = function(nValue) return sSecondPrefix..string.format("%02d", nValue) end},
};

--[[
"Year: "..oIota[IOTA.YEARS]..' '..
	  string.format(" Day: %03d Hour: %02d", oIota[IOTA.DAYS], oIota[IOTA.HOURS]);
]]

for nType = 1, #tStringPreCache do
	--store the max value and function
	local nMax = tStringPreCache[nType].max;
	local func = tStringPreCache[nType].func;

	--now, set the value to be a table
	tStringPreCache[nType] = {};

	--store the strings in the table
	for x = 0, nMax do
		tStringPreCache[nType][x] = func(x);
	end

end
--=====================================================<



--sets the marker before a change is made to the iota
--[[local function setMarker(oIota)

	for _, sName in pairs(IOTA()) do
		oIota.marker[sName] = oIota[sName];
	end

	return oIota;
end
]]


--TODO add onSecond callback method
local function levelValues(this, tProt)
	local oIota			= tIotas[this];
	local nMax 			= IOTA.MAX.SECONDS;
	local nPreValue 	= 0;
	local nPostValue	= 0;

	if (oIota[IOTA.SECONDS] >= nMax) then
		nPreValue = oIota[IOTA.MINUTES];
		oIota[IOTA.MINUTES]  = oIota[IOTA.MINUTES] + math.floor(oIota[IOTA.SECONDS] / nMax);
		oIota[IOTA.SECONDS]  = oIota[IOTA.SECONDS] % nMax;
		nPostValue = oIota[IOTA.MINUTES] - nPreValue;

		if (type(oIota.callbacks[IOTA.CALLBACK.ON_MINUTE]) == 'function') then
			oIota.callbacks[IOTA.CALLBACK.ON_MINUTE](this, nPostValue, unpack(oIota.callbackArgs[IOTA.CALLBACK.ON_MINUTE]));
		end

	end

	nMax = IOTA.MAX.MINUTES;
	if (oIota[IOTA.MINUTES] >= nMax) then
		nPreValue = oIota[IOTA.HOURS];
		oIota[IOTA.HOURS] 	 = oIota[IOTA.HOURS] + math.floor(oIota[IOTA.MINUTES] / nMax);
		oIota[IOTA.MINUTES]  = oIota[IOTA.MINUTES] % nMax;
		nPostValue = oIota[IOTA.HOURS] - nPreValue;

		if (type(oIota.callbacks[IOTA.CALLBACK.ON_HOUR]) == 'function') then
			oIota.callbacks[IOTA.CALLBACK.ON_HOUR](this, nPostValue, unpack(oIota.callbackArgs[IOTA.CALLBACK.ON_HOUR]));
		end

	end

	nMax = IOTA.MAX.HOURS;
	if (oIota[IOTA.HOURS] >= nMax) then
		nPreValue = oIota[IOTA.DAYS];
		oIota[IOTA.DAYS]   = oIota[IOTA.DAYS] + math.floor(oIota[IOTA.HOURS] / nMax);
		oIota[IOTA.HOURS]  = oIota[IOTA.HOURS] % nMax;
		nPostValue = oIota[IOTA.DAYS] - nPreValue;

		if (type(oIota.callbacks[IOTA.CALLBACK.ON_DAY]) == 'function') then
			oIota.callbacks[IOTA.CALLBACK.ON_DAY](this, nPostValue, unpack(oIota.callbackArgs[IOTA.CALLBACK.ON_DAY]));
		end

	end

	nMax = IOTA.MAX.DAYS;
	if (oIota[IOTA.DAYS] >= nMax) then
		nPreValue = oIota[IOTA.YEARS];
		oIota[IOTA.YEARS] = oIota[IOTA.YEARS] + math.floor(oIota[IOTA.DAYS] / nMax);
		oIota[IOTA.DAYS]  = oIota[IOTA.DAYS] % nMax
		nPostValue = oIota[IOTA.YEARS] - nPreValue;

		if (type(oIota.callbacks[IOTA.CALLBACK.ON_YEAR]) == 'function') then
			oIota.callbacks[IOTA.CALLBACK.ON_YEAR](this, nPostValue, unpack(oIota.callbackArgs[IOTA.CALLBACK.ON_YEAR]));
		end

	end

	--[[adjust the pre-set marker now that the changes are complete
	for _, sName in pairs(IOTA()) do
		oIota.marker[sName]	 = oIota[sName] - oIota.marker[sName];
	end	]]

	return this;
end


--[[local function getValueP(oIota, sName)
	return oIota[sName];
end
]]

iota = class "iota" {

	__construct = function(this)
		tIotas[this] = {
			callbacks 	 	= {},
			callbackArgs 	= {},
			ShowYears 		= true,
			ShowDays		= true,
			ShowHours 		= true,
			ShowMinutes		= true,
			ShowSeconds 	= true,
			[IOTA.YEARS]	= 0,
			[IOTA.DAYS]		= 0,
			[IOTA.HOURS]	= 0,
			[IOTA.MINUTES]	= 0,
			[IOTA.SECONDS]	= 0,
			--marker = {}, --used for tracking how much time has passed from one point to the next
		};
		local oIota = tIotas[this];

		--setup values
		--for sIndex, _ in pairs(IOTA) do
			--oIota[sIndex] 			= 0;
			--oIota.marker[sName] 	= 0;
		--end

		--setup callbacks
		for _, eItem in IOTA.CALLBACK() do
			oIota.callbacks[eItem.value]	= 0;
			oIota.callbackArgs[eItem.value]	= {};
		end

	end,

	--todo left/right checks
	__add = function(this, oIota)
		local oMe			= tIotas[this];
		local oRet 			= iota();
		local nAddMinutes 	= 0;
		local nAddHours 	= 0;
		local nAddDays 		= 0;
		local nAddYears 	= 0;

		oRet[IOTA.SECONDS] 	= oMe[IOTA.SECONDS] 	+ oIota[IOTA.SECONDS];
		oRet[IOTA.MINUTES] 	= oMe[IOTA.MINUTES] 	+ oIota[IOTA.MINUTES];
		oRet[IOTA.HOURS] 	= oMe[IOTA.HOURS] 		+ oIota[IOTA.HOURS];
		oRet[IOTA.DAYS] 	= oMe[IOTA.DAYS] 		+ oIota[IOTA.DAYS];
		oRet[IOTA.YEARS] 	= oMe[IOTA.YEARS] 		+ oIota[IOTA.YEARS];

		return levelValues(this);

	end,

	__tostring = function(this)
		local oIota	= tIotas[this];
		local tCache = tStringPreCache;

		--TODO for some reason, hours and minutes are missing a space...find out why
		--TODO create contingent for non-existent year strings
		sYears 		= oIota.ShowYears 	and tCache[PRECACHE_YEARS][oIota[IOTA.YEARS]] 			or sBlank;
		sDays 		= oIota.ShowDays 	and tCache[PRECACHE_DAYS][oIota[IOTA.DAYS]] 			or sBlank;
		sHours 		= oIota.ShowHours 	and tCache[PRECACHE_HOURS][oIota[IOTA.HOURS]] 			or sBlank;
		sMinutes 	= oIota.ShowMinutes and tCache[PRECACHE_MINUTES][oIota[IOTA.MINUTES]] 		or sBlank;
		sSeconds 	= oIota.ShowSeconds and tCache[PRECACHE_SECONDS][oIota[IOTA.SECONDS]] 		or sBlank;

		return sYears..sDays..sHours..sMinutes..sSeconds;
		--return "Year: "..oIota[IOTA.YEARS]..' '..
		--	   string.format(" Day: %03d Hour: %02d", oIota[IOTA.DAYS], oIota[IOTA.HOURS]);
	end,


	--__tostring = function(...)
		--local oIota	= tIotas[arg[1]];

		--return oIota[IOTA.YEARS]..':'..
			--   string.format("%03d:%02d:%02d:%02d",
			  -- oIota[IOTA.DAYS], 		oIota[IOTA.HOURS],
			  -- oIota[IOTA.MINUTES], 	oIota[IOTA.SECONDS]);
	--end,]]

	--todo break this out into more functions
	addValue = function(this, sValueItem, nValue)
		local oIota 		= tIotas[this];

		if oIota[sValueItem] then
			--setMarker(oIota);
			oIota[sValueItem] = oIota[sValueItem] + nValue;
			levelValues(this);
		end

		return this;
	end,

	--[[addSeconds = function(...)
		local oIota 		= tIotas[];
		local sValueItem 	= arg[2];
		local nValue 		= arg[3];


	end,finish this!]]

	deserialize = function(this, sData)
		local oIota = tIotas[this];
		local tData = deserialize(sData);

			oIota[IOTA.SECONDS]	= tData[IOTA.SECONDS];
			oIota[IOTA.MINUTES]	= tData[IOTA.MINUTES];
			oIota[IOTA.HOURS]	= tData[IOTA.HOURS];
			oIota[IOTA.DAYS]	= tData[IOTA.DAYS];
			oIota[IOTA.YEARS]	= tData[IOTA.YEARS];

		return this;
	end,

	destroy = function(this)
		tIotas[this] = nil;
		this = nil;
	end,

	--[[
		returns the change since the last adjustment
	]]
	--[[delta = function(...)
		local oIota = tIota[;
		local tRet = {};

		for _, sName in pairs(IOTA()) do
			tRet[sName] = oIota.marker[sName];
		end

		return tRet;
	end,]]


	getSeconds = function(this)
		return tIotas[this][IOTA.SECONDS];
	end,

	getMinutes = function(this)
		return tIotas[this][IOTA.MINUTES];
	end,

	getHours = function(this)
		return tIotas[this][IOTA.HOURS];
	end,

	getDays = function(this)
		return tIotas[this][IOTA.DAYS];
	end,

	getYears = function(this)
		return tIotas[this][IOTA.YEARS];
	end,

	getValue = function(this, sValueItem)
		local oIota 		= tIotas[this];
		local nRet 			= 0;

		if oIota[sValueItem] then
			nRet = oIota[sValueItem];
		end

		return nRet;
	end,

	--TODO convert this function to work with the new aaa
	multValue = function(this, sValueItem, nValue)
		local oIota 		= tIotas[this];

		if (oIota[sValueItem]) then
			oIota[sValueItem] = oIota[sValueItem] * nValue;
			levelValues(this);
		end

		return this;
	end,

	--[[!
		@desc Serializes the object's data.
		@func iota.serialize
		@module iota
		@param bDefer boolean Whether or not to return a table of data to be serialized instead of a serialize string (if deferring serializtion to another object).
		@ret sData StringOrTable The data, returned as a serialized table (string) or a table is the defer option is set to true.
	!]]
	serialize = function(this)
		local oIota = tIotas[this];

		local tData = {
			[IOTA.SECONDS]	= oIota[IOTA.SECONDS],
			[IOTA.MINUTES]	= oIota[IOTA.MINUTES],
			[IOTA.HOURS]	= oIota[IOTA.HOURS],
			[IOTA.DAYS]		= oIota[IOTA.DAYS],
			[IOTA.YEARS]	= oIota[IOTA.YEARS],
		};

		return serialize.table(tData);
	end,

	--todo fix this, it should use levelValues
	set = function(this, nYears, nDays, nHours, nMinutes, nSeconds)
		local oIota 		= tIotas[this];
		local nMaxYears 	= IOTA.MAX.YEARS.value;
		local nMaxDays 		= IOTA.MAX.DAYS.value;
		local nMaxHours 	= IOTA.HOURS.MAX.value;
		local nMaxMinutes 	= IOTA.MAX.MINUTES.value;
		local nMaxSeconds 	= IOTA.MAX.SECONDS.value;

		oIota[IOTA.YEARS] 	= nYears 	>= 0 and (nYears 	<= 	nMaxYears	and nYears 		or nMaxYears) 	or 0;
		oIota[IOTA.DAYS] 	= nDays		>= 0 and (nDays  	< 	nMaxDays 	and nDays 		or nMaxDays) 	or 0;
		oIota[IOTA.HOURS] 	= nHours 	>= 0 and (nHours 	< 	nMaxHours 	and nHours		or nMaxHours) 	or 0;
		oIota[IOTA.MINUTES]	= nMinutes	>= 0 and (nMinutes 	< 	nMaxMinutes	and nMinutes 	or nMaxMinutes)	or 0;
		oIota[IOTA.SECONDS] = nSeconds 	>= 0 and (nSeconds 	< 	nMaxSeconds	and nSeconds	or nMaxSeconds)	or 0;

		return this;
	end,

	setCallback = function(this, sFunction, fCallback, tArgs)
		local oIota 	= tIotas[this];

		--error(type(tIotas[arg[1]]), 4)
		if (oIota.callbacks[sFunction]) then
			--local sType = type(fCallback);

			--if (sType == 'function') then
				oIota.callbacks[sFunction] 		= fCallback or 0;
				oIota.callbackArgs[sFunction]	= tArgs or {};
			--elseif (sType == 'nil') then
				--oIota.callbacks[sFunction] = 0;
			--end

		end

		return this;
	end,


	setDays = function(this, nDays)
		local oIota = tIotas[this];
		local nMax 	= IOTA.MAX.DAYS.value;

		oIota[IOTA.DAYS] = nDays >= 0 and (nDays < nMax and nDays or nMax) or 0;
		return this;
	end,


	setHours = function(this, nHours)
		local oIota = tIotas[this];
		local nMax 	= IOTA.MAX.HOURS.value;

		oIota[IOTA.HOURS] = nHours >= 0 and (nHours < nMax and nHours or nMax) or 0;
		return this;
	end,


	setMinutes = function(this, nMinutes)
		local oIota = tIotas[this];
		local nMax 	= IOTA.MAX.MINUTES.value;

		oIota[IOTA.MINUTES] = nMinutes >= 0 and (nMinutes < nMax and nMinutes or nMax) or 0;
		return this;
	end,


	setSeconds = function(this, nSeconds)
		local oIota = tIotas[this];
		local nMax 	= IOTA.MAX.SECONDS.value;

		oIota[IOTA.SECONDS] = nSeconds >= 0 and (nSeconds < nMax and nSeconds or nMax) or 0;
		return this;
	end,

	setYears = function(this, nYears)
		local oIota = tIotas[this];
		local nMax 	= IOTA.MAX.YEARS.value;

		oIota[IOTA.YEARS] = nYears >= 0 and (nYears < nMax and nYears or nMax) or 0;
		return this;
	end,

	setValue = function(this, sValueItem, nValue)
		local oIota 		= tIotas[this];

		if (oIota[sValueItem]) then

			if (sValueItem == IOTA.SECONDS) then
				oIota:setSeconds(nValue);

			elseif (sValueItem == IOTA.MINUTES) then
				oIota:setMinutes(nValue);

			elseif (sValueItem == IOTA.HOURS) then
				oIota:setHours(nValue);

			elseif (sValueItem == IOTA.DAYS) then
				oIota:setDays(nValue);

			elseif (sValueItem == IOTA.YEARS) then
				oIota:setYears(nValue);
			end

		end

		return this;
	end,

	showYears = function(this, bFlag)
		tIotas[this].ShowYears = type(bFlag) == "boolean" and bFlag or false;
		return this;
	end,

	showDays = function(this, bFlag)
		tIotas[this].ShowDays = type(bFlag) == "boolean" and bFlag or false;
		return this;
	end,

	showHours = function(this, bFlag)
		tIotas[this].ShowHours = type(bFlag) == "boolean" and bFlag or false;
		return this;
	end,

	showMinutes = function(this, bFlag)
		tIotas[this].ShowMinutes = type(bFlag) == "boolean" and bFlag or false;
		return this;
	end,

	showSeconds = function(this, bFlag)
		tIotas[this].ShowSeconds = type(bFlag) == "boolean" and bFlag or false;
		return this;
	end,

};

return iota;
