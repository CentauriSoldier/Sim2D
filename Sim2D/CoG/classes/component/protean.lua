--[[*
@authors Centauri Soldier
@copyright Public Domain
@description
	<h2>protean</h2>
	<p>An object designed to hold a base value (or use an external one) as well
	as adjuster values which operate on the base value to produce a final result.
	Designed to be a simple-to-use modifier system.</p>
	<br>
	<p>
	<b>Note:</b> <em>"bonus"</em> and <em>"penalty"</em> are logical concepts.
	How they are calculated is up to the client. They should be set, applied
	and processed as if they infer their respective, purported affects. That is,
	a <em>"bonus"</em> could be a positve value in one case or a negative value
	in another, so long as the target is gaining some net benefit. The sign of
	the value should not be assumed but, rather, tailored to apply a beneficial
	affect (for bonus) or detramental affect (for penalty).
	<br>
	<br>
	Also, any multiplicative value is treated as a percetage and should be a float value.
	<br>
	E.g.,
	<br>
	<ul>
		<li>1 	 = 100%</li>
		<li>0.2  = 20%</li>
		<li>1.65 = 165%</li>
	</ul>
	<br>
	In order of altering affect intensity (descending):
	Base, Multiplicative, Addative
	<br>
	<br>
	How the final value is calcualted:
	<br>
	Let V be some value, B be the base adjustment,
	M be the multiplicative adjustment, A be the
	addative adjustment and sub-b be the bonus and sub-p be the penalty.
	<br>
	<br>
	V = [(V + Bb - Bp) * (1 + Mb - Mp)] + Ab - Ap
	<br>
	<br>
	There may be some instances where a client may use several protean objects but wants the
	same base value for all of them. In this case, it would be cumbersome to have to set the
	base value for each protean object. So, a protean object may be told to use an external
	reference for the base value. In this case, a table is provided to the protean object with a key
	of PROTEAN.EXTERNAL_INDEX and a number value. This allows for multiple protean objects to reference
	the same base value without the need for resetting the base value of each object. Note: the table
	input will have a metamethod (__index) added to it which will update the final value of the Protean objects
	whenever the value is changed. If the table input already has a metamethod of __index, the Protean's __index
	metamethod will overwrite it.
	</p>
@license <p>The Unlicense<br>
<br>
@moduleid protean
@version 1.3
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
		<p>Added the ability to set a callback function on value change.</p>
		<p>Added the ability to enable or disable the callback function.</p>
		<p>Added the ability to disable auto-calculation of the final value.</p>
		<p>Added the ability to manually call for calculation of the final value.</p>
	</li>
	<li>
		<b>1.2</b>
		<br>
		<p>Forced safe and default input for constructor.</p>
	</li>
	<li>
		<b>1.3</b>
		<br>
		<p>Added a linker system allowing multiple protean objects to share the same base value. This makes for much faster processing of proteans which have a common base value.</p>
	</li>
</ul>
@website https://github.com/CentauriSoldier
*]]
assert(type(const) == "function", "const has not been loaded.");
PROTEAN							= const("PROTEAN");
PROTEAN.BASE					= const("PROTEAN.BASE", "", true);
PROTEAN.BASE.BONUS				= 1;--"Base Bonus";
PROTEAN.BASE.PENALTY 			= 2;--"Base Penalty";
PROTEAN.MULTIPLICATIVE			= const("PROTEAN.MULTIPLICATIVE", "", true);
PROTEAN.MULTIPLICATIVE.BONUS	= 3;--"Multiplicative Bonus";
PROTEAN.MULTIPLICATIVE.PENALTY	= 4;--"Multiplicative Penalty";
PROTEAN.ADDATIVE				= const("PROTEAN.ADDATIVE", "", true);
PROTEAN.ADDATIVE.BONUS			= 5;--"Addative Bonus";
PROTEAN.ADDATIVE.PENALTY 		= 6;--"Addative Penalty";
PROTEAN.VALUE					= const("PROTEAN.VALUE");
PROTEAN.VALUE.BASE				= 7;--"Base Value";
PROTEAN.VALUE.FINAL				= 8;--"Final Value";
PROTEAN.LIMIT					= const("PROTEAN.LIMIT");
PROTEAN.LIMIT.MIN				= 9;--"Minimum Limit";
PROTEAN.LIMIT.MAX				= 10;--"Maximum Limit";
--PROTEAN.EXTERNAL_INDEX			= "Protean External Index";

local PROTEAN = PROTEAN;

local tProteans = {};

--[[
 Stores linkers for protean objects with a shared base value.
 The table is structure is as follows:
 tHub[nLinkerID] = {
 		baseValue = x,
		index = {--for fast existential queries of a protean object within a linker
			proteanobject1 = true,
			proteanobject2 = true,
			etc...
		}
 		proteans = {
			[1] = proteanobject1,
			[2] = proteanobject2,
			etc...
		},
	};
]]
local tHub = {};

--[[!
	@desc
	@mod
	@param this
	@param nLinkerID
	@scope local
!]]
local function linkerIDIsValid(nLinkerID)
	return type(nLinkerID) == "number" and math.floor(nLinkerID) == nLinkerID and nLinkerID > 0 and tHub[nLinkerID];
end

--[[!
	@desc
	@mod
	@param this
	@param nLinkerID
	@scope local
!]]
local function unlink(this)
	local oProtean = tProteans[this];
	local nLinkerID = oProtean.linkerID;

	if (oProtean.isLinked and linkerIDIsValid(nLinkerID) and tHub[nLinkerID] and tHub[nLinkerID].index[this]) then
		--reset the object's base value to the linker's base value
		oProtean[PROTEAN.VALUE.BASE] = tHub[nLinkerID].baseValue;
		--update its linked status and linkerID
		oProtean.isLinked = false;
		oProtean.linkerID = nil;

		--remove the object from the linker
		tHub[nLinkerID].index:remove(this);
		tHub[nLinkerID].proteans:remove(nLinkerID);
	end

end

--[[!
	@desc Links a protean object to the specified (or new) linker. If the object is currently linked to another linker, it will be unlinked from that linker.
	@mod protean
	@param nLinkerID number The linker ID; that is, the ID of the linker to which the protean will be linked. If this is nil or otherwise invalid, a new linker will be created.
	@scope local
!]]
local function link(this, nLinkerID)
	local oProtean 	= tProteans[this];
	local nLinkers 	= #tHub;
	nLinkerID		= linkerIDIsValid(nLinkerID) and nLinkerID or nLinkers + 1;

	--create the linker if it doesn't exist
	if (not tHub[nLinkerID]) then
		tHub[nLinkerID] = {
			--the new linker will start with the creating object's base value
			baseValue = oProtean[PROTEAN.VALUE.BASE],
			index = {},
			proteans = {},
		};
	end

	--link it only if it's not already linked
	if (not tHub[nLinkerID].index[this]) then
		--set the object's base value to be the same as the linker's
		oProtean[PROTEAN.VALUE.BASE] = tHub[nLinkerID].baseValue;
		--link the protean and update its settings
		oProtean.isLinked = true;
		oProtean.linkerID = nLinkerID;
		--update the hub to reflect the new addition
		tHub[nLinkerID].index[this] = true;
		tHub[nLinkerID].proteans[#tHub[nLinkerID].proteans + 1] = this;
	end

	--now, make sure the protean isn't linked somewhere else

	--initially indicate that the linker should not be removed
	local nRemoveLinker = -1;

	--check if the object is linked anywhere else and, if so, unlink it
	for nHubLinkerID, tLinker in pairs(tHub) do

		--don't operate on the linker known to contain this protean object
		if (nLinkerID ~= nHubLinkerID) then

			if (tLinker.index[this]) then
				tLinker.index:remove(this);
				tLinker.proteans:remove(nHubLinkerID);

				--indicate that the linker needs to be removed
				if (#tLinker == 0) then
					nRemoveLinker = nHubLinkerID;
				end

				break;
			end

		end

	end

	--if the linker is empty, remove it
	if (nRemoveLinker ~= -1 and tHub[nRemoveLinker]) then
		tHub:remove(nRemoveLinker);
	end

end

--local function ExternalTableIsValid(tTable)
--	return type(tTable) == "table" and type(tTable[PROTEAN.EXTERNAL_INDEX]) == "number";
--end


--[[!
	@desc
	@mod
	@param this
	@param nLinkerID
	@scope local
!]]
local function calculateFinalValue(oProtean)
	local nBase = (not oProtean.isLinked) and oProtean[PROTEAN.VALUE.BASE] or tHub[oProtean.linkerID].baseValue;

	local nBaseBonus	= oProtean[PROTEAN.BASE.BONUS];
	local nBasePenalty	= oProtean[PROTEAN.BASE.PENALTY];
	local nMultBonus	= oProtean[PROTEAN.MULTIPLICATIVE.BONUS];
	local nMultPenalty	= oProtean[PROTEAN.MULTIPLICATIVE.PENALTY];
	local nAddBonus		= oProtean[PROTEAN.ADDATIVE.BONUS];
	local nAddPenalty	= oProtean[PROTEAN.ADDATIVE.PENALTY];

	oProtean[PROTEAN.VALUE.FINAL] = ((nBase + nBaseBonus - nBasePenalty) * (1 + nMultBonus - nMultPenalty)) + nAddBonus - nAddPenalty;
end

--[[!
	@desc
	@mod
	@param this
	@param nLinkerID
	@scope local
!]]
local function setValue(oProtean, sType, vValue)

	if (sType ~= PROTEAN.VALUE.FINAL) then

		--if a number was passed
		if (type(vValue) == "number") then
			--set the value
			oProtean[sType] = vValue;

			--check if this object is linked and, if so, update the linker and it's proteans
			if (oProtean.isLinked and sType == PROTEAN.VALUE.BASE) then
				tHub[oProtean.linkerID].baseValue = vValue;
			end

		end

		if (oProtean.autoCalculate) then
			--(re)calculate the final value
			calculateFinalValue(oProtean);
		end

	end

	if (oProtean.isCallbackActive and type(oProtean.onChange) == "function") then
		oProtean:onChange(oProtean);
	end

	return oProtean[sType];
end


class "protean" {
	--[[!
		@desc The constructor for the protean class.
		@func protean
		@module protean
		@param nBaseValue number This value is Vb where Vf = [(Vb + Bb - Bp) * (1 + Mb - Mp)] + Ab - Ap and where Vf is the calculated, final value. If set to nil, it will default to 0.
		@param nBaseBonus number/nil This value is Bb where Vf = [(Vb + Bb - Bp) * (1 + Mb - Mp)] + Ab - Ap and where Vf is the calculated, final value. If set to nil, it will default to 0.
		@param nBasePenalty number/nil This value is Bp where Vf = [(Vb + Bb - Bp) * (1 + Mb - Mp)] + Ab - Ap and where Vf is the calculated, final value. If set to nil, it will default to 0.
		@param nMultiplicativeBonus number/nil This value is Mb where Vf = [(Vb + Bb - Bp) * (1 + Mb - Mp)] + Ab - Ap and where Vf is the calculated, final value. If set to nil, it will default to 0.
		@param nMultiplicativePenalty number/nil This value is Mp where Vf = [(Vb + Bb - Bp) * (1 + Mb - Mp)] + Ab - Ap and where Vf is the calculated, final value. If set to nil, it will default to 0.
		@param nAddativeBonus number/nil This value is Ab where Vf = [(Vb + Bb - Bp) * (1 + Mb - Mp)] + Ab - Ap and where Vf is the calculated, final value. If set to nil, it will default to 0.
		@param nAddativePenalty number/nil This value is Ap where Vf = [(Vb + Bb - Bp) * (1 + Mb - Mp)] + Ab - Ap and where Vf is the calculated, final value. If set to nil, it will default to 0.
		@param nMinLimit number/nil This is the minimum value that the calculated, final value will return. If set to nil, it will be ignored and there will be no minimum value.
		@param nMaxLimit number/nil This is the maximum value that the calculated, final value will return. If set to nil, it will be ignored and there will be no maximum value.
		@param fonChange function/nil If the (optional) input is a function, this will be called whenever a change is made to this object (unless callback is inactive).
		@param bAutoCalculate Whether or not this object should auto-calculate the final value whenever a change is made. This is true by default. If set to nil, it will default to true.
		@return oProtean protean A protean object.
	!]]
	__construct = function(this, nBaseValue, nBaseBonus, nBasePenalty, nMultiplicativeBonus, nMultiplicativePenalty, nAddativeBonus, nAddativePenalty, nMinLimit, nMaxLimit, fonChange, bAutoCalculate)

		tProteans[this] = {
			[PROTEAN.VALUE.BASE]				= type(nBaseValue) 				== "number" 	and nBaseValue 				or 0,
			[PROTEAN.BASE.BONUS] 				= type(nBaseBonus) 				== "number"		and nBaseBonus  			or 0,
			[PROTEAN.BASE.PENALTY] 				= type(nBasePenalty) 			== "number"		and nBasePenalty 			or 0,
			[PROTEAN.MULTIPLICATIVE.BONUS] 		= type(nMultiplicativeBonus) 	== "number"		and nMultiplicativeBonus 	or 0,
			[PROTEAN.MULTIPLICATIVE.PENALTY] 	= type(nMultiplicativePenalty) 	== "number"		and nMultiplicativePenalty 	or 0,
			[PROTEAN.ADDATIVE.BONUS] 			= type(nAddativeBonus) 			== "number"		and nAddativeBonus 			or 0,
			[PROTEAN.ADDATIVE.PENALTY] 			= type(nAddativePenalty) 		== "number"		and nAddativePenalty 		or 0,
			[PROTEAN.VALUE.FINAL]				= 0, --this is (re)calcualted whenever another item is changed
			[PROTEAN.LIMIT.MIN] 				= type(nMinLimit) 				== "number"		and nMinLimit 				or nil,
			[PROTEAN.LIMIT.MAX] 				= type(nMaxLimit) 				== "number"		and nMaxLimit				or nil,
			linkerID							= nil,
			isLinked							= false, --for fast queries
			autoCalculate						= type(bAutoCalculate) 			== "boolean" 	and bAutoCalculate 			or true,
			onChange 							= type(fonChange) 				== "function" 	and fonChange 				or nil,
			isCallbackActive					= type(fonChange) 				== "function",
		};

		--calculate the final value for the first time
		calculateFinalValue(tProteans[this]);

		return this;
	end,

	--[[!
	@desc Adjusts the given value by the amount input. Note: if using an external table which contains the base value, and the type provided is PROTEAN.VALUE.BASE, nil will be returned. An external base value cannot be adjusted from inside the protean	object (although the base bonus and base penalty may be).
	@func protean.adjust
	@module protean
	@param sType PROTEAN The type of value to adjust.
	@param nValue number The value by which to adjust the given value.
	@return nValue number The adjusted value (or nil is PROTEAN.VALUE.BASE was input as the type).
	!]]
	adjust = function(this, sType, nValue)
		local oProtean = tProteans[this];
		if (oProtean[sType]) then

			if (type(nValue) == "number") then
				return setValue(oProtean, sType, oProtean[sType] + nValue);
			end

		end

	end,

	--[[!
		@desc Calculates the final value of the protean. This is done on-change by default so that the final value (when requested) is always up-to-date and accurate. There is no need to call this unless auto-calculate has been disabled. In that case, this serves an external utility function to perform the normally-internal operation of calculating and updating the final value.
		@func protean.calulateFinalValue
		@module protean
		@return nValue number The calculated final value.
	!]]
	calulateFinalValue = function(this)
		calculateFinalValue(oProtean);
		return tProteans[this][PROTEAN.VALUE.FINAL];
	end,

	--[[!
		@desc Deserializes data and sets the object's properties accordingly.
		@func protean.deserialize
		@module protean
	!]]
	deserialize = function(this, sTable)
		local oProtean 	= tCharacters[this];
		local tData 	= deserialize.table(sTable);

		oProtean[PROTEAN.VALUE.BASE] 				= tData[PROTEAN.VALUE.BASE];
		oProtean[PROTEAN.BASE.BONUS] 				= tData[PROTEAN.BASE.BONUS];
		oProtean[PROTEAN.BASE.PENALTY] 				= tData[PROTEAN.BASE.PENALTY];
		oProtean[PROTEAN.MULTIPLICATIVE.BONUS] 		= tData[PROTEAN.MULTIPLICATIVE.BONUS];
		oProtean[PROTEAN.MULTIPLICATIVE.PENALTY] 	= tData[PROTEAN.MULTIPLICATIVE.PENALTY];
		oProtean[PROTEAN.ADDATIVE.BONUS] 			= tData[PROTEAN.ADDATIVE.BONUS];
		oProtean[PROTEAN.ADDATIVE.PENALTY]			= tData[PROTEAN.ADDATIVE.PENALTY];
		oProtean[PROTEAN.VALUE.FINAL]				= tData[PROTEAN.VALUE.FINAL];
		oProtean[PROTEAN.LIMIT.MIN]					= tData[PROTEAN.LIMIT.MIN];
		oProtean[PROTEAN.LIMIT.MAX] 				= tData[PROTEAN.LIMIT.MAX];
		oProtean.isLinked							= tData.isLinked;
		oProtean.linkerID							= tData.linkerID;
		oProtean.autoCalculate						= tData.autoCalculate;
		oProtean.onChange						 	= tData.onChange;
		oProtean.isCallbackActive 					= tData.isCallbackActive;

		--relink this object if it was before
		if (bIsLinked) then
			link(this, tData.linkerID);
		end

	end,

	--[[!
	@desc Set this object to be deleted by the garbage collector.
	@func protean.destroy
	@module protean
	!]]
	destroy = function(this)
		tProteans[this] = nil;
		this = nil;
	end,

	--[[!
		@desc Gets the value of the given value type. Note: if the type provided is PROTEAN.VALUE.FINAL and MIN or MAX limits have been set, the returned value will fall within the confines of those paramter(s).
		@func protean.get
		@module protean
		@param sType PROTEAN The type of value to get.
		@return nValue number The value of the given type.
	!]]
	get = function(this, sType)
		local nRet = 0;
		local oProtean = tProteans[this];
		sType = type(oProtean[sType]) ~= nil and sType or PROTEAN.VALUE.FINAL;

		nRet = oProtean[sType];

		if (sType == PROTEAN.VALUE.FINAL) then

			--clamp the value if it has been limited
			if (oProtean[PROTEAN.LIMIT.MIN]) then

				if (nRet < oProtean[PROTEAN.LIMIT.MIN]) then
					nRet = oProtean[PROTEAN.LIMIT.MIN];
				end

			end

			if (oProtean[PROTEAN.LIMIT.MAX]) then

				if (nRet > oProtean[PROTEAN.LIMIT.MAX]) then
					nRet = oProtean[PROTEAN.LIMIT.MAX];
				end

			end

		elseif (sType == PROTEAN.VALUE.BASE) then

			if (oProtean.isLinked) then
				nRet = tHub[oProtean.linkerID].baseValue;
			end

		end

		return nRet;
	end,


	getLinkerID = function(this)
		return tProteans[this].linkerID;
	end,

	--[[!
		@desc Determines whether or not auto-calculate is active.
		@func protean.isAutoCalculated
		@module protean
		@return bActive boolean Whether or not auto-calculate occurs on value change.
	!]]
	isAutoCalculated = function(this)
		return tProteans[this].autoCalculate;
	end,

	--[[!
		@desc Determines whether or not the callback is called on change.
		@func protean.isCallbackActive
		@module protean
		@return bActive boolean Whether or not the callback is called on value change.
	!]]
	isCallbackActive = function(this)
		return tProteans[this].isCallbackActive;
	end,

	isLinked = function(this)
		return tProteans[this].isLinked;
	end,

	--[[!
		@desc Set the given value type to the value input. Note: if this object is linked, and the type provided is PROTEAN.VALUE.BASE, this linker's base value will also change, affecting every other linked object's base value.
		@func protean.set
		@module protean
		@param sType PROTEAN The type of value to adjust.
		@param nValue number The value which to set given value type.
		@return nValue number The new value.
	!]]
	set = function(this, sType, nValue)
		local oProtean = tProteans[this];

		if (oProtean[sType]) then
			return setValue(oProtean, sType, nValue);
		end

	end,

	--[[!
		@desc By default, the final value is calculated whenever a change is made to a value; however, this method gives the power of that choice to the client. If disabled, the client will need to call calculateFinalValue to update the final value.
		@func protean.setAutoCalculate
		@module protean
		@param bAutoCalculate boolean Whether or not the objects should auto-calculate the final value.
	!]]
	setAutoCalculate = function(this, bFlag)

		if (type(bFlag) == "boolean") then
			tProteans[this].autoCalculate		 = bFlag;
		else
			tProteans[this].autoCalculate		 = false;
		end

	end,

	--[[!
		@desc Set the given function as this objects's onChange callback which is called whenever a change occurs (if active).
		@func protean.setCallback
		@module protean
		@param fCallback function The callback function (which must accept the protean object as its first parameter)
	!]]
	setCallback = function(this, fCallback)

		if (type(fCallback) == "function") then
			tProteans[this].onChange = fCallback;
			isCallbackActive		 = true;
		else
			tProteans[this].onChange = nil;
			isCallbackActive		 = false;
		end

	end,

	--[[!
		@desc Serializes the object's data. Note: This does NOT serialize callback functions.
		@func protean.serialize
		@module protean
		@param bDefer boolean Whether or not to return a table of data to be serialized instead of a serialize string (if deferring serializtion to another object).
		@ret sData StringOrTable The data returned as a serialized table (string) or a table is the defer option is set to true.
	!]]
	serialize = function(this, bDefer)
		local oProtean = tProteans[this];


		local tData = {
			[PROTEAN.VALUE.BASE]				= oProtean.isLinked and tHub[oProtean.linkerID].baseValue or oProtean[PROTEAN.VALUE.BASE],
			[PROTEAN.BASE.BONUS] 				= oProtean[PROTEAN.BASE.BONUS],
			[PROTEAN.BASE.PENALTY] 				= oProtean[PROTEAN.BASE.PENALTY],
			[PROTEAN.MULTIPLICATIVE.BONUS] 		= oProtean[PROTEAN.MULTIPLICATIVE.BONUS],
			[PROTEAN.MULTIPLICATIVE.PENALTY] 	= oProtean[PROTEAN.MULTIPLICATIVE.PENALTY],
			[PROTEAN.ADDATIVE.BONUS] 			= oProtean[PROTEAN.ADDATIVE.BONUS],
			[PROTEAN.ADDATIVE.PENALTY] 			= oProtean[PROTEAN.ADDATIVE.PENALTY],
			[PROTEAN.VALUE.FINAL]				= oProtean[PROTEAN.VALUE.FINAL],
			[PROTEAN.LIMIT.MIN] 				= oProtean[PROTEAN.LIMIT.MIN],
			[PROTEAN.LIMIT.MAX] 				= oProtean[PROTEAN.LIMIT.MAX],
			isLinked							= oProtean.isLinked,
			linkerID							= oProtean.linkerID,
			autoCalculate						= oProtean.autoCalculate,
			onChange 							= oProtean.onChange,
			isCallbackActive					= oProtean.isCallbackActive,
		};

		if (not bDefer) then
			tData = serialize.table(tData);
		end

		return tData;
	end,


	--[[!
		@desc Set the object's callback function (if any) to active/inactive. If active, it will fire whenever a change is made while nothing will occur if it is inactive.
		@func protean.setCallbackActive
		@module protean
		@param bActive boolean A boolean value indicating whether or no the callback function should be called.
	!]]
	setCallbackActive = function(this, bFlag)

		if (type(bFlag) == "boolean") then
			tProteans[this].isCallbackActive		 = bFlag;
		else
			tProteans[this].isCallbackActive		 = false;
		end

		return this;
	end,


	--[[!
		@desc Links, relinks or unlinks this object based on the input.
		@func protean.setLinker
		@module protean
		@param vLinkerID number If this is a number, the object will be linked to the provided linerkID (if valid). If the input linkerID is invalid, a proper one will be created. If the linkerID is nil, the object will be unlinked (if already linked).
		@return oProtean protean This protean object.
	!]]
	setLinker = function(this, nLinkerID)
		local sLinkerIDType = type(nLinkerID);

		if (sLinkerIDType == "number") then
			link(this, nLinkerID);

		elseif (sLinkerIDType == nil) then
			unlink(this);
		end

		return this;
	end,

}

--[[!
	@desc returns a number that is one greater than the maximum number of linkers in the Hub. This is used for determining the next, empty, available linker ID.
	@func protean.getAvailableLinkerID
	@module protean
	@return nLinkerID number The next open index in the Hub.
!]]
function protean.getAvailableLinkerID()
	return #tHub + 1;
end

return protean;
