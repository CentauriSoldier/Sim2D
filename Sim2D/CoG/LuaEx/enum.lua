local pairs = pairs;
local type 	= type;

local function getItemTable()
	return setmetatable(
		{
			id = -1,
			name = "",
			value = -1,
		},
		{
			--first,
			--last
		}
	);
end

local function namesAreValid(tNames)

end

local function valuesAreValid(tValues)

end

local function enum(tNames, tValues)
	local tRet = {};

	if (type(tNames) == "table") then

		if (type(tValues) == "table") then

		end

	end

	local tMeta = {};

	return tRet;
end
