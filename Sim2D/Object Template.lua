local tMyObjects 	= {};

local class 		= class;
local tSim2D 		= Sim2D.__properties;
local UICOM 		= UICOM;
local Sim2D 		= Sim2D;



class "MyObject" : extends(Sim2D) {

	__construct = function(this)
		--object settings
		tMyObjects[this] = {

		};

	end,

	Destroy = function(this)
		local tChildren = this:GetChildren();

		--destory all my children
		for x = 1, #tChildren do
			tChildren[x]:Destroy();
		end

		tMyObjects[this] 	= nil;
		this 				= nil;
	end,

	OnDraw = function(this)

	end,

	OnLButtonDown = function(this)

	end,

	OnLButtonUp = function(this)

	end,

	OnRButtonDown = function(this)

	end,

	OnRButtonUp = function(this)

	end,
};

return MyObject;
