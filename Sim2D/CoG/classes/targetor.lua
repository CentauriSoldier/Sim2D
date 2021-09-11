--[[*
@moduleid targetor
@authors Centauri Soldier
@copyright Copyright © 2020 Centauri Soldier
@description <h2>Targetor</h2><h3>Targetor objects for target matching and determination.</p>
<h3>Implentation must create the following constants:</h3>
<ul>
	<li>TARGET <em>(constant type)</em></li>
</ul>
<p>Any number of target types may be created for this constant type. The types may then be assigned to targetor objects and be used to check targetability</p>
@features
@usage <p>Once a <strong>Targetor</strong> object has been created, it can be operated upon using TARGET types
<em>(or numerically indexed tables containing multiple TARGET types)</em> or other <strong>Targetor</strong> objects.</p>
@todo <p>create <strong>__tostring</strong> metamethod.
@version 0.1
*]]
local tTargetors = {};

local function targetIsValid(...)
	local sTargetType = select(1, ...);
	local bRet = false;

	if (type(sTargetType) == "string") then

		for _, sValue in pairs(TARGET()) do

			if (sTargetType == sValue) then
				bRet = true;
				break;
			end

		end

	end

	return bRet;
end

local function setType(tTable, sType, vValue)

	if (targetIsValid(sType)) then
		tTable[sType] = vValue;
	end

end

local function clearType(tTable, sType)

	if (targetIsValid(sType)) then

		if (tTable[sType]) then
			tTable[sType] = nil;
		end

	end

end

local function setTypes(tTable, vTypes, vValue)
	local sType = type(vTypes);

	if (sType == "string") then
		setType(tTable, vTypes, vValue);

	elseif (sType == "table") then

		for _, sTargetType in pairs(vTypes) do
			setType(tTable, sTargetType, vValue);
		end

	end

end

class "targetor" {

	__construct = function(...)
		local this = select(1, ...);

		tTargetors[this] = {
			targetableTypes 	= {}, --types I can target (if the target is not immune)
			targetorTypes 		= {}, --what kind of targetor types I am
			targetorImmunities 	= {}, --targetor types that cannot target me (takes precedence over another's targetableTypes)
		};
	end,

	destroy = function(...)
		local this = select(1, ...);
		tTargetors[this] = nil;
	end,

	--[[!
	@module Targetor
	@func __add
	@scope local
	@desc <p></p>
	!]]
	__add = function(vLeft, vRight)
		local oRet = 0;
		local sLeftType = type(vLeft);
		local sRightType = type(vRight);

		if (leftOnlyObject(sLeftType, sRightType, "Targetor")) then
			oRet = vLeft;
			setTypes(tTargetors[vLeft].targetableTypes, vRight, true);

		elseif (rightOnlyObject(sLeftType, sRightType, "Targetor")) then
			oRet = vRight;
			setTypes(tTargetors[vRight].targetorTypes, vLeft, true);

		elseif (bothObjects(sLeftType, sRightType, "Targetor")) then
			--TODO copy all items from right to left
		end

		return oRet;
	end,

	--TODO update this to work for mixed types comparison
	--can be targeted by?
	__lt = function(oThis, oOther)
		local oMyTargetor = tTargetors[oThis];
		local oOtherTargetor = tTargetors[oOther];
		local bRet = false;
		local bImmune = false;

		--first, check for immunities
		for sTargetImmunity, _ in pairs(oMyTargetor.targetorImmunities) do

			for sTargetType, __ in pairs(oOtherTargetor.targetorTypes) do

				if (sTargetImmunity == sTargetType) then
					bImmune = true;
					break;
				end

			end

		end

		--second, check if there is the ability to target
		if not (bImmune) then
			--error(tostring(oMyTargetor.targetorTypes[TARGET.PERSON]));
			for sMyTargetorType, _ in pairs(oMyTargetor.targetorTypes) do
				--error(sMyTargetorType)
				for sOtherTargetable, __ in pairs(oOtherTargetor.targetableTypes) do
					--error(sMyTargetorType.." "..sOtherTargetable)
					if (sMyTargetorType == sOtherTargetable) then
						bRet = true;
						break;
					end

				end

			end

		end

		return bRet;
	end,


	--[[!
	@module Targetor
	@func __mul
	@scope local
	@desc <p>Used to check for targetability from one <strong>Targetor</strong> object to another or a TARGET type.</p>
	!]]
	__mul = function(vLeft, vRight)
		local oRet = 0;
		local sLeftType = type(vLeft);
		local sRightType = type(vRight);

		if (leftOnlyObject(sLeftType, sRightType, "Targetor")) then
			oRet = vLeft;
			setTypes(tTargetors[vLeft].targetorImmunities, vRight, true);

		elseif (rightOnlyObject(sLeftType, sRightType, "Targetor")) then
			oRet = vRight;
			setTypes(tTargetors[vRight].targetorImmunities, vLeft, nil);

		elseif (bothObjects(sLeftType, sRightType, "Targetor")) then
			--TODO copy all items from right to left
		end

		return oRet;
	end,


	--[[!
	@module Targetor
	@func __sub
	@scope local
	@desc <p>Used to check for targetability from one <strong>Targetor</strong> object to another or a TARGET type.</p>
	!]]
	__sub = function(vLeft, vRight)
		local oRet = 0;
		local sLeftType = type(vLeft);
		local sRightType = type(vRight);

		if (leftOnlyObject(sLeftType, sRightType, "Targetor")) then
			oRet = vLeft;
			setTypes(tTargetors[vLeft].targetableTypes, vRight, nil);

		elseif (rightOnlyObject(sLeftType, sRightType, "Targetor")) then
			oRet = vRight;
			setTypes(tTargetors[vRight].targetorTypes, vLeft, nil);

		elseif (bothObjects(sLeftType, sRightType, "Targetor")) then
			--TODO copy all items from right to left
		end

		return oRet;
	end,

};
