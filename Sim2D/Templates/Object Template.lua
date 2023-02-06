local tMyObjects 	= {};

local class 		= class;
local tSim2D 		= Sim2D.__properties; --very useful, global properties table
local SIM2D 		= SIM2D; --SIM2D enum
local Sim2D 		= Sim2D; --the Sim2D base object



local MyObject class "MyObject" : extends(Sim2D) {

	__construct = function(this, protected)--TODO update this to the new protected table
		--object settings
		tMyObjects[this] = {

		};

	end,

	Destroy = function(this)
		local tChildren = this:GetChildren();

		--destroy all my children
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
