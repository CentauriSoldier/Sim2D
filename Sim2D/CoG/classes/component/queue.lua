local tQueues = {};

assert(type(class) == "function", "Error loading the rectangle class. It depends on class.");
assert(type(serialize) 		== "table", 	"Error loading the pot class. It depends on serialize.");
assert(type(deserialize)	== "table", 	"Error loading the pot class. It depends on deserialize.");

--localization
local assert 		= assert;
local class 		= class;
local serialize		= serialize;
local deserialize	= deserialize;
local table			= table;
local type 			= type;

class "queue" {

	 __construct = function(this)
		tQueues[this] = {
			count 	= 0,
			values 	= {},
		};
	end,


	__len = function(this)--doesn't work in < Lua v5.2
		return tQueues[this].count;
	end,


	enqueue = function(this, vValue)
		assert(type(vValue) ~= "nil", "Error enqueueing item.\r\nValue cannot be nil.");
		table.insert(tQueues[this].values, 1, vValue);
		tQueues[this].count = tQueues[this].count - 1;
		return vValue;
	end,

	destroy = function(this)
		tQueues[this] = nil;
		this = nil;
	end,

	dequeue = function(this)
		local vRet = nil;
		local nIndex = tQueues[this].count;

		if (nIndex > 0) then
			vRet = table.remove(tQueues[this].values, nIndex);
			tQueues[this].count = tQueues[this].count - 1;
		end

		return vRet;
	end,


	size = function(this)
		return tQueues[this].count;
	end,


	values = function(this)
		local tRet = {};

		for nIndex = 1, #tQueues[this].count do
			tRet[nIndex] = tQueues[this].values[nIndex];
		end

		return tRet;
	end,
}
