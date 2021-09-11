local tBank = {

};

--TODO add implementation section here where RESOURCE CONSTS can be defined

--TODO fix var arg calls
local function setValue(oBank, sResourceType, nValue)
	tBank[oBank][sResourceType] = nValue;
end

local function getValue(oBank, sResourceType)
	local nRet = 0;

	if tBank[oBank][sResourceType] then
		nRet = tBank[oBank][sResourceType];
	end

	return nRet;
end
--TODO should I use pool for each resource type?
class "bank" {

	__construct = function(this)
		tBank[this] = {};

		local nIndex = 1;
		--iterate through each resource type and set any value provided (or zero)
		for _, sResourceType in pairs(RESOURCE()) do
			nIndex = nIndex + 1;
			local nValue = select(nIndex, ...);
			--tBank[this][sResourceType] = pool();
			setValue(this, sResourceType, tern(type(nValue) == "number", nValue, 0));
		end

	end,

	__add = function(this)
		aaa.checkCount("bank", "__add", {...}, 1);
		local oBank = aaa.checkTypes("bank", "set", {...}, 1, {"bank"});

		setValue(this, sResourceType, nValue);
	end,

	__tostring = function(...)
		local this = select(1, ...);
		local sRet = "";
		local sSep = ' | ';
		local tResources = RESOURCE();
		local nLen = #RESOURCE;
		local nCounter = 0;

		for _, sResourceType in pairs(tResources) do
			nCounter = nCounter + 1;

			if (nCounter == nLen) then
				sSep = "";
			end

			sRet = sRet..sResourceType..': '..getValue(this, sResourceType)..sSep;
		end

		return sRet;
	end,


	copy = function(...)
		local this = select(1, ...);
		local oRet = Bank();

		local nIndex = 0;
		--iterate through each resource type and set any value provided (or zero)
		for _, sResourceType in pairs(RESOURCE()) do
			nIndex = nIndex + 1;
			setValue(oRet, sResourceType, getValue(this, sResourceType));
		end

		return 	oRet;

	end,



	getValue = function(...)
		local this = select(1, ...);
		aaa.checkCount("bank", "getValue", {...}, 1);
		local sResourceType = aaa.checkTypes("bank", "getValue", {...}, 1, {"string"});

		return getValue(this, sResourceType);
	end,


	set = function(...)
		local this = select(1, ...);
		aaa.checkCount("bank", "set", {...}, 1);
		local oBank = aaa.checkTypes("bank", "set", {...}, 1, {"bank"});

		local nIndex = 0;
		--iterate through each resource type and set any value provided (or zero)
		for _, sResourceType in pairs(RESOURCE()) do
			nIndex = nIndex + 1;
			setValue(this, sResourceType, getValue(oBank, sResourceType));
		end

		return this;
	end,


	setValue = function(...)
		local this = select(1, ...);
		aaa.checkCount("bank", "setValues", {...}, 2);
		local sResourceType = 	aaa.checkTypes("bank", "setValues", {...}, 1, {"string"});
		local nValue = 			aaa.checkTypes("bank", "setValues", {...}, 1, {"number"});

		setValue(this, sResourceType, nValue);

		return this;
	end,


	setValues = function(...)
		local this = select(1, ...);
		aaa.checkCount("bank", "setValues", {...}, 5);
		local nAmmo = 	aaa.checkTypes("bank", "setValues", {...}, 1, {"number"});
		local nCaP = 	aaa.checkTypes("bank", "setValues", {...}, 2, {"number"});
		local nFuel = 	aaa.checkTypes("bank", "setValues", {...}, 3, {"number"});
		local nParts =	aaa.checkTypes("bank", "setValues", {...}, 4, {"number"});
		local nViands = aaa.checkTypes("bank", "setValues", {...}, 5, {"number"});

		setValue(this, RESOURCE.AMMO, nAmmo);
		setValue(this, RESOURCE.CAP, nCaP);
		setValue(this, RESOURCE.FUEL, nFuel);
		setValue(this, RESOURCE.PARTS, nParts);
		setValue(this, RESOURCE.VIANDS, nViands);

		return this;
	end,

	--[[
	__call = function(...)
		local this = select(1, ...);
		aaa.checkCount("bank", "setValues", {...}, 2);
		local sResourceType = 	aaa.checkTypes("bank", "setValues", {...}, 1, {"string"});
		local nRet = 0;

		if (tBank[this][sResourceType]) then
			nRet = tBank[this][sResourceType];
		end

		return nRet;
	end]]

	--bank:Adjust
	--bank:AdjustValue

};

return bank;
