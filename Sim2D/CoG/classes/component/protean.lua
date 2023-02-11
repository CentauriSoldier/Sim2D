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
		<b>1.3</b>
		<br>
		<p>Added a linker system allowing multiple protean objects to share the same base value. This makes for much faster processing of proteans which have a common base value.</p>
		<p>Bugfix: proteans were not linking properly.</p>
		<p>Bugfix: deserialize function was not relinking protean.</p>
		<p>Feature: added the ability, upon unlinking, to restore a proteans original value.</p>
	</li>
	<li>
		<b>1.2</b>
		<br>
		<p>Forced safe and default input for constructor.</p>
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
		<b>1.0</b>
		<br>
		<p>Created the module.</p>
	</li>
</ul>
@website https://github.com/CentauriSoldier
*]]
local tProteans = {};
local protean;

local class 	= class;
local constant 	= constant;
local math 		= math;
local pairs 	= pairs;
local table 	= table;
local type 		= type;
local rawtype 	= rawtype;
local PROTEAN 	= PROTEAN;




--placeholder so higher functions can access it
local calculateFinalValue;

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
		totalLinked = 0,
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
	return rawtype(nLinkerID) == "number" and math.floor(nLinkerID) == nLinkerID and nLinkerID > 0 and tHub[nLinkerID];
end

--[[!
	@desc
	@mod
	@param this
	@param nLinkerID
	@scope local
!]]
local function unlink(this, bRestoreOriginalValue)
	local oProtean = tProteans[this];
	local nLinkerID = oProtean.linkerID;

	if (oProtean.isLinked and linkerIDIsValid(nLinkerID) and tHub[nLinkerID] and tHub[nLinkerID].index[this]) then

		--set the object's base value to it's original value or the linker's base value
		oProtean[PROTEAN.VALUE.BASE] = bRestoreOriginalValue 		and
									   tHub[nLinkerID].index[this] 	or
									   tHub[nLinkerID].baseValue;

		--update its linked status and linkerID
		oProtean.isLinked = false;
		oProtean.linkerID = nil;

		--remove the object from the linker
		table.remove(tHub[nLinkerID].proteans, tHub[nLinkerID].index);
		table.remove(tHub[nLinkerID].index, this);

		--update the linked count
		tHub[nLinkerID].totalLinked = #tHub[nLinkerID].proteans;
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
			baseValue 	= oProtean[PROTEAN.VALUE.BASE],
			index 		= {},
			proteans	= {},
		};
	end

	--link it only if it's not already linked
	if (not tHub[nLinkerID].index[this]) then
		--store the object's original value
		local nOriginalValue = oProtean[PROTEAN.VALUE.BASE]
		--set the object's base value to be the same as the linker's
		oProtean[PROTEAN.VALUE.BASE] = tHub[nLinkerID].baseValue;
		--link the protean and update its settings
		oProtean.isLinked = true;
		oProtean.linkerID = nLinkerID;
		--update the hub to reflect the new addition
		tHub[nLinkerID].index[this] = nOriginalValue;
		tHub[nLinkerID].proteans[#tHub[nLinkerID].proteans + 1] = this;
	end

	--now, make sure the protean isn't linked somewhere else

	--DO NOT REMOVE LINKERS OR ELSE THE LINKER IDs WILL REFERENCE THE WRONG TABLE INDEX

	--initially, indicate that the linker should not be removed
	--local nRemoveLinker = -1;

	--check if the object is linked anywhere else and, if so, unlink it
	for nHubLinkerID, tLinker in pairs(tHub) do

		--don't operate on the linker known to contain this protean object
		if (nLinkerID ~= nHubLinkerID) then

			if (tLinker.index[this]) then
				table.remove(tLinker.index, this)
				table.remove(tLinker.proteans, nHubLinkerID);
				--tLinker.index:remove(this);
				--tLinker.proteans:remove(nHubLinkerID);

				--indicate that the linker needs to be removed
				--if (#tLinker == 0) then
					--nRemoveLinker = nHubLinkerID;
				--end

				break;
			end

		end

	end

	--if the linker is empty, remove it
	--if (nRemoveLinker ~= -1 and tHub[nRemoveLinker]) then
	--	tHub:remove(nRemoveLinker);
	--end

	--recalculate the final value
	if (oProtean.autoCalculate) then
		calculateFinalValue(oProtean);
	end

	--update the linked count
	tHub[nLinkerID].totalLinked = #tHub[nLinkerID].proteans;
end

--local function ExternalTableIsValid(tTable)
--	return rawtype(tTable) == "table" and rawtype(tTable[PROTEAN.EXTERNAL_INDEX]) == "number";
--end


--[[!
	@desc
	@mod
	@param this
	@param nLinkerID
	@scope local
!]]
calculateFinalValue = function(oProtean)
	local nBase = oProtean.isLinked and tHub[oProtean.linkerID].baseValue or oProtean[PROTEAN.VALUE.BASE];

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
local function setValue(this, sType, vValue)
	local oProtean = tProteans[this];

	if (sType ~= PROTEAN.VALUE.FINAL) then
		local bCalculated 		= false;
		local bCallbackCalled 	= false;

		--set the value
		oProtean[sType] = vValue;

		--check if this object is linked and, if so, update the linker and it's proteans
		if (oProtean.isLinked and sType == PROTEAN.VALUE.BASE) then
			tHub[oProtean.linkerID].baseValue = vValue;

			--update the linked proteans' final value
			for x = 1, tHub[oProtean.linkerID].totalLinked do
				local linkedThis 		= tHub[oProtean.linkerID].proteans[x];
				local oLinkedProtean 	= tProteans[linkedThis];
				--print(rawtype(tHub[oProtean.linkerID].proteans[x]))
				if (oLinkedProtean.autoCalculate) then
					--(re)calculate the final value
					calculateFinalValue(oLinkedProtean);
				end

				if (oLinkedProtean.isCallbackActive) then
					--process the callback function
					oLinkedProtean.onChange(linkedThis);
				end

			end

			--indicate that this protean has also been calulated
			bCalculated 	= true;
			--and the callback has been called
			bCallbackCalled = true;
		end

		if (oProtean.autoCalculate and not bCalculated) then
			--(re)calculate the final value
			calculateFinalValue(oProtean);
		end

		if (oProtean.isCallbackActive and not bCallbackCalled) then
			oProtean.onChange(this);
		end

	end

	return oProtean[sType];
end


protean = class "protean" {
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
	__construct = function(this, tProt, nBaseValue, nBaseBonus, nBasePenalty, nMultiplicativeBonus, nMultiplicativePenalty, nAddativeBonus, nAddativePenalty, nMinLimit, nMaxLimit, fonChange, bAutoCalculate)

		local bHasCallbackFunction = rawtype(fonChange) == "function";

		tProteans[this] = {
			[PROTEAN.VALUE.BASE]				= rawtype(nBaseValue) 				== "number" 	and nBaseValue 				or 0,
			[PROTEAN.BASE.BONUS] 				= rawtype(nBaseBonus) 				== "number"		and nBaseBonus  			or 0,
			[PROTEAN.BASE.PENALTY] 				= rawtype(nBasePenalty) 			== "number"		and nBasePenalty 			or 0,
			[PROTEAN.MULTIPLICATIVE.BONUS] 		= rawtype(nMultiplicativeBonus) 	== "number"		and nMultiplicativeBonus 	or 0,
			[PROTEAN.MULTIPLICATIVE.PENALTY] 	= rawtype(nMultiplicativePenalty) 	== "number"		and nMultiplicativePenalty 	or 0,
			[PROTEAN.ADDATIVE.BONUS] 			= rawtype(nAddativeBonus) 			== "number"		and nAddativeBonus 			or 0,
			[PROTEAN.ADDATIVE.PENALTY] 			= rawtype(nAddativePenalty) 		== "number"		and nAddativePenalty 		or 0,
			[PROTEAN.VALUE.FINAL]				= 0, --this is (re)calcualted whenever another item is changed
			[PROTEAN.LIMIT.MIN] 				= rawtype(nMinLimit) 				== "number"		and nMinLimit 				or nil,
			[PROTEAN.LIMIT.MAX] 				= rawtype(nMaxLimit) 				== "number"		and nMaxLimit				or nil,
			linkerID							= nil,
			isLinked							= false, --for fast queries
			autoCalculate						= rawtype(bAutoCalculate) 			== "boolean" 	and bAutoCalculate 			or true,
			onChange 							= bHasCallbackFunction						 	and fonChange 				or nil,
			isCallbackActive					= bHasCallbackFunction,
		};

		--calculate the final value for the first time
		calculateFinalValue(tProteans[this]);
	end,

	--[[!
	@desc Adjusts the given value by the amount input. Note: if using an external table which contains the base value, and the rawtype provided is PROTEAN.VALUE.BASE, nil will be returned. An external base value cannot be adjusted from inside the protean	object (although the base bonus and base penalty may be).
	@func protean.adjust
	@module protean
	@param sType PROTEAN The type of value to adjust.
	@param nValue number The value by which to adjust the given value.
	@return oProtean protean This protean object.
	!]]
	adjust = function(this, sType, nValue)
		local oProtean = tProteans[this];

		if (oProtean[sType]) then

			if (rawtype(nValue) == "number") then
				return setValue(this, sType, oProtean[sType] + nValue);
			end

		end

		return this;
	end,

	--[[!
		@desc Calculates the final value of the protean. This is done on-change by default so that the final value (when requested) is always up-to-date and accurate. There is no need to call this unless auto-calculate has been disabled. In that case, this serves an external utility function to perform the normally-internal operation of calculating and updating the final value.
		@func protean.calulateFinalValue
		@module protean
		@return nValue number The calculated final value.
	!]]
	calulateFinalValue = function(this)
		calculateFinalValue(oProtean);
		return this;
	end,

	--[[!
		@desc Deserializes data and sets the object's properties accordingly.
		@func protean.deserialize
		@module protean
	!]]
	deserialize = function(this, sTable)
		local oProtean 	= tCharacters[this];--TODO what is this table?
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
		if (oProtean.isLinked) then
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
		local oProtean	= tProteans[this];
		sType 			= rawtype(oProtean[sType]) ~= nil and sType or PROTEAN.VALUE.FINAL;
		local nRet 		= oProtean[sType];

		if (sType == PROTEAN.VALUE.FINAL) then

			--clamp the value if it has been limited
			if (oProtean[PROTEAN.LIMIT.MIN]) then
				nRet = nRet < oProtean[PROTEAN.LIMIT.MIN] and oProtean[PROTEAN.LIMIT.MIN] or nRet;
			end

			if (oProtean[PROTEAN.LIMIT.MAX]) then
				nRet = nRet > oProtean[PROTEAN.LIMIT.MAX] and oProtean[PROTEAN.LIMIT.MAX] or nRet;
			end

		elseif (sType == PROTEAN.VALUE.BASE) then

			if (oProtean.isLinked) then
				nRet = tHub[oProtean.linkerID].baseValue;
			end

		end

		return nRet;
	end,

	--[[!
		@desc Gets this protean's linkerID.
		@func protean.getLinkerID
		@module protean
		@return nID number The ID of the linker;
	!]]
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
		@desc Set the given value type to the value input. Note: if this object is linked, and the type provided is PROTEAN.VALUE.BASE, this linker's base value will also change, affecting every other linked object's base value.
		@func protean.set
		@module protean
		@param sType PROTEAN The type of value to adjust.
		@param nValue number The value which to set given value type.
		@return oProtean protean This protean object.
	!]]
	set = function(this, sType, nValue)

		if (rawtype(nValue) == "number") then

			if (tProteans[this][sType]) then
				setValue(this, sType, nValue);
			end

		end

		return this;
	end,

	--[[!
		@desc By default, the final value is calculated whenever a change is made to a value; however, this method gives the power of that choice to the client. If disabled, the client will need to call calculateFinalValue to update the final value.
		@func protean.setAutoCalculate
		@module protean
		@param bAutoCalculate boolean Whether or not the objects should auto-calculate the final value.
		@return oProtean protean This protean object.
	!]]
	setAutoCalculate = function(this, bFlag)
		tProteans[this].autoCalculate = rawtype(bFlag) == "boolean" and bFlag or false;
		return this;
	end,

	--[[!
		@desc Set the given function as this objects's onChange callback which is called whenever a change occurs (if active).
		@func protean.setCallback
		@module protean
		@param fCallback function The callback function (which must accept the protean object as its first parameter)
		@param bDoNotSetActive boolean If true, the function is not set to active, otherwise (even with nil value) the function is set to active.
		@return oProtean protean This protean object.
	!]]
	setCallback = function(this, fCallback, bDoNotSetActive)
		local oProtean = tProteans[this];

		if (rawtype(fCallback) == "function") then
			oProtean.onChange 			= fCallback;
			oProtean.isCallbackActive 	= not (rawtype(bDoNotSetActive) == "boolean" and bDoNotSetActive or false);

		else
			oProtean.onChange 			= nil;
			oProtean.isCallbackActive	= false;
		end

		return this;
	end,


	--[[!
		@desc Set the object's callback function (if any) to active/inactive. If active, it will fire whenever a change is made while nothing will occur if it is inactive.
		@func protean.setCallbackActive
		@module protean
		@param bActive boolean A boolean value indicating whether or no the callback function should be called.
		@return oProtean protean This protean object.
	!]]
	setCallbackActive = function(this, bFlag)
		local oProtean = tProteans[this];

		if (rawtype(bFlag) == "boolean") then
			oProtean.isCallbackActive		 = (rawtype(oProtean.onChange) == "function") and (rawtype(oProtean.onChange) == "function" and bFlag or false) or false;
		else
			oProtean.isCallbackActive		 = false;
		end

		return this;
	end,


	--[[!
		@desc Links or unlinks this object based on the input.
		@func protean.setLinker
		@module protean
		@param vLinkerID number If this is a number, the object will be linked to the provided linerkID (if valid). If the input linkerID is invalid, a proper one will be created. If the linkerID is nil, the object will be unlinked (if already linked).
		@param bRestoreOriginalValue boolean If this is true, the original value is restored, otherwise the object gets the linker's base value.
		@return oProtean protean This protean object.
	!]]
	setLinker = function(this, nLinkerID, bRestoreOriginalValue)
		local sLinkerIDType 	= rawtype(nLinkerID);
		bRestoreOriginalValue 	= rawtype(bRestoreOriginalValue) == "boolean" and bRestoreOriginalValue or false;

		if (sLinkerIDType == "number") then
			link(this, nLinkerID, bRestoreOriginalValue);

		elseif (sLinkerIDType == "nil") then
			unlink(this);
		end

		return this;
	end,
};

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
