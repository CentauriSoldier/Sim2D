--TODO update all destroy methods to use table remove as well

--localization
local SIM2D 		= SIM2D;
local type			= type;
local tSim2D;
local Util;

local bHasInit = false;

--TODO add physics, drag and collision

class "Sim2D" {

	__construct = function(this, sState, sName, oShape, hDC, nStratum, nLayer, bDoNotPoll, bDoNotAutoDraw)
		sState = sState:lower();--TODO check this input!!!
		--get the object's stratum
		nStratum = Util.StratumIsValid(nStratum) and nStratum or SIM2D.STRATUM.DEFAULT;
		--get the object's layer
		local nLayer = Util.LayerIsValid(nLayer) and nLayer or SIM2D.LAYER.DEFAULT;
		--get the state ID
		local nStateID = tSim2D.StateIDs[sState];

		--store it in the query table so other modules can get objects
		tSim2D.ObjectsByName[nStateID][sName] = this;

		tSim2D.ObjectSettings[this] = {
			AutoDraw 		= not (type(bDoNotAutoDraw) == "boolean" and bDoNotAutoDraw or false), --defaults to true --TODO should this have mutator/accessor or should it be permanant?
			AutoPoll 		= not (type(bDoNotPoll) 	== "boolean" and bDoNotPoll 	or false),			--defaults to true --TODO should this have mutaror/accessor or should it be permanant?
			Children		= {},
			DrawIndex 		= 0,
			DC				= hDC, --TODO allow this to be modified
			ClickableLeft	= true, --allows/disallows event firing
			ClickableRight	= true, --allows/disallows event firing
			Clicked			= false,
			ClickedLeft		= false,
			ClickedRight	= false,
			Hoverable		= true, --allows/disallows event firing
			Hovered			= false,
			Layer			= nLayer,
			Name 			= sName,
			OnEnterReady	= true,
			OnLeaveReady	= false,
			PulseIndex 		= 0,
			PulseRate		= SIM2D.PULSE.OFF,
			Shape 			= oShape,
			State 			= sState,
			StateID			= nStateID, --no accessor for this since it's internal
			Stratum			= nStratum,
			Visible 		= true,
		};
		--TODO redo state id to be a character count of the state string (lowered)
		--TODO NEXT, COUNT ALL TABLES AS ITEMS ARE ADDED AND REMOVED TO PREVENT THE NEED FOR CONSTANT RECOUNTING IN FOR LOOPS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--LEFT OFF - event system doesn't work..events not firing

		--set up the first (potential) onenter event for this object
		tSim2D.EventUtil.OnEnterQueue[this] = true;

		--TODO separate polling from drawing so objects can interally choose to poll or draw their own objects more granularlly
		--store state objects here for fast processing

		if (tSim2D.ObjectSettings[this].AutoPoll)	then
			local nNextIndex = #tSim2D.PollObjects[nStateID][nStratum] + 1;
			tSim2D.PollObjects[nStateID][nStratum][nNextIndex] = this;
		end

		if (tSim2D.ObjectSettings[this].AutoDraw) then
			local nNextIndex = #tSim2D.DrawObjects[nStateID][nStratum][nLayer] + 1
			tSim2D.DrawObjects[nStateID][nStratum][nLayer][nNextIndex] = this;
		end

	end,

	--TODO redo this function so it works and is updated and is optimized, also, does it work with inheritence?
	Destroy = function(this)
		local sName 	= this:GetName();
		local sState 	= this:GetName();

		this:Destroy();
		tSim2D.ObjectSettings[this] 			= nil;
		tSim2D.PollObjects[sState][sName] 	= nil;
		tSim2D.ObjectsByName[sState][sName]	= nil;
		this = nil;
	end,

	GetChildren = function(this)
		local tRet = {};

		for x = 1, #tSim2D.ObjectSettings.Children do
			tRet[#tRet + 1] = tSim2D.ObjectSettings.Children[x];
		end

		return tRet;
	end,

	GetClickableLeft = function(this)
		return tSim2D.ObjectSettings[this].ClickableLeft;
	end,

	GetClickableRight = function(this)
		return tSim2D.ObjectSettings[this].ClickableRight;
	end,

	GetEnabled = function(this)
		local tSettings = tSim2D.ObjectSettings[this];
		return tSettings.ClickableLeft and tSettings.ClickableRight and tSettings.Hoverable;
	end,

	GetHoverable = function(this)
		return tSim2D.ObjectSettings[this].Hoverable;
	end,

	GetName = function(this)
		return tSim2D.ObjectSettings[this].Name;
	end,

	GetShape = function(this)
		return tSim2D.ObjectSettings[this].Shape;
	end,

	GetState = function(this)
		return tSim2D.ObjectSettings[this].State;
	end,

	GetStratum = function(this)
		return tSim2D.ObjectSettings[this].Stratum;
	end,

	IsHovered = function(this)
		return tSim2D.ObjectSettings[this].Hovered;
	end,

	IsClicked = function(this)
		return tSim2D.ObjectSettings[this].ClickedLeft or tSim2D.ObjectSettings[this].ClickedRight;
	end,

	IsClickedLeft = function(this)
		return tSim2D.ObjectSettings[this].ClickedLeft;
	end,

	IsClickedRight = function(this)
		return tSim2D.ObjectSettings[this].ClickedRight;
	end,

	OnEnter = function(this)

	end,

	OnLeave = function(this)
	end,

	SetClickable = function(this, bFlag)
		local bClickable = type(bFlag) == "boolean" and bFlag or false;
		tSim2D.ObjectSettings[this].ClickableLeft 	= bClickable;
		tSim2D.ObjectSettings[this].ClickableRight 	= bClickable;
		return this;
	end,

	SetClickableLeft = function(this, bFlag)
		tSim2D.ObjectSettings[this].ClickableLeft = type(bFlag) == "boolean" and bFlag or false;
		return this;
	end,

	SetClickableRight = function(this, bFlag)
		tSim2D.ObjectSettings[this].ClickableRight = type(bFlag) == "boolean" and bFlag or false;
		return this;
	end,
--TODO set stratum method and get layer method
	SetDrawLayer = function(this, nLayer)
		local oObject 		= tSim2D.ObjectSettings[this];
		local nOldLayer		= oObject.Layer;
		local nOldDrawIndex	= oObject.DrawIndex;
		local nStateID 		= oObject.StateID;

		local bAdd = (nLayer ~= nOldLayer) and
					 (
						 (nLayer == SIM2D.LAYER.BACKGROUND_BACK) 	or
				 		 (nLayer == SIM2D.LAYER.BACKGROUND_MID)  	or
				 	 	 (nLayer == SIM2D.LAYER.BACKGROUND_FRONT) 	or
				 	 	 (nLayer == SIM2D.LAYER.MIDGROUND_BACK) 	or
				 	  	 (nLayer == SIM2D.LAYER.MIDGROUND_MID) 		or
						 (nLayer == SIM2D.LAYER.MIDGROUND_FRONT) 	or
				 	 	 (nLayer == SIM2D.LAYER.FOREGROUND) 		or
				 	 	 (nLayer == SIM2D.LAYER.FOREGROUND_BACK) 	or
				 	 	 (nLayer == SIM2D.LAYER.FOREGROUND_MID) 	or
				 	 	 (nLayer == SIM2D.LAYER.FOREGROUND_FRONT)
				 	);

			--tSim2D.ObjectSettings[this].Layer = SIM2D.LAYER.FOREGROUND_FRONT;
			--tSim2D.DrawObjects[nStateID][nLayer][sName] = this;


			if (bAdd) then
				local tLayer = tSim2D.DrawObjects[nStateID][nLayer];
				--set the object's new draw layer
				oObject.Layer = nLayer;
				--get the object's new draw table index
				local nIndex = #tLayer + 1;
				--set the object's new draw index
				oObject.DrawIndex = nIndex;
				--store the object in the draw layer table
				tLayer[nIndex] = this;

				--remove the object from it's previous draw layer (if present)
				if (tSim2D.DrawObjects[nStateID][nOldLayer] and
					tSim2D.DrawObjects[nStateID][nOldLayer][nOldDrawIndex]) then --do i need to check if this is the same object or is the manner in which objects are added and removed proof enough?
					table.remove(tSim2D.DrawObjects[nStateID][nOldLayer], nOldDrawIndex);
				end

			end

	end,

	SetEnabled = function(this, bFlag)
		local tSettings = tSim2D.ObjectSettings[this];
		local bEnable 	= type(bFlag) == "boolean" and bFlag or false;

		tSettings.ClickableLeft 	= bEnable;
		tSettings.ClickableRight  	= bEnable;
		tSettings.Hoverable 		= bEnable;

		return this;
	end,

	SetHoverable = function(this, bFlag)
		tSim2D.ObjectSettings[this].Hoverable = type(bFlag) == "boolean" and bFlag or false;
		return this;
	end,

	SetPulseRate = function(this, nRate)
		local oObject			= tSim2D.ObjectSettings[this];
		local nOldRate 			= oObject.PulseRate;
		local nOldPulseIndex	= oObject.PulseIndex;
		local nStateID 			= oObject.StateID;
		local bPulseOff 		= nRate == SIM2D.PULSE.OFF;

		--change the pulse value and add to the appropriate pulse table (if indicated)
		local bChange = (nRate ~= nOldRate) and
						(
							bPulseOff							or
							(nRate == SIM2D.PULSE.ULTRA_SLOW) 	or
							(nRate == SIM2D.PULSE.SLOW) 		or
							(nRate == SIM2D.PULSE.MEDIUM) 		or
							(nRate == SIM2D.PULSE.FAST) 		or
							(nRate == SIM2D.PULSE.ULTRA_FAST)
						);

		if (bChange) then
			local tPulsars = tSim2D.PulseObjects[nStateID][nRate];

			if (bPulseOff) then
				oObject.PulseRate = PULSE.OFF;

			else
				--set the new rate
				oObject.PulseRate = nRate;
				--get the new pulse index
				local nIndex = #tPulsars + 1;
				--set the object's new pulse index
				oObject.PulseIndex = nIndex;
				--add the object to its new pulse table
				tPulsars[nIndex] = this;
			end

			--remove the object from the old pulse table
			local tOldPulsars = tSim2D.PulseObjects[nStateID][nOldRate];

			if (nOldRate ~= SIM2D.PULSE.OFF and tOldPulsars and tOldPulsars[nOldPulseIndex]) then
				table.remove(tOldPulsars, nOldPulseIndex);
			end

		end

		return this;
	end,

	SetVisible = function(this, bFlag)
		tSim2D.ObjectSettings[this].Visible	= type(bFlag) == "boolean" and bFlag or false;
		return this;
	end,

	ToggleEnabled = function(this)
		tSim2D.ObjectSettings[this].Enabled = not tSim2D.ObjectSettings[this].Enabled;
		return this;
	end,
	--TODO make sure all functions like this apply to the childrebn objects as well by implementing and checking for a __children table in the object
	ToggleVisible = function(this)
		tSim2D.ObjectSettings[this].Visible = not tSim2D.ObjectSettings[this].Visible;
		return this;
	end,

};

Sim2D.Init = function()

	if (not bHasInit) then
		tSim2D 				= Sim2D.__properties;
		Util 				= Sim2D.Util;
		bHasInit 			= true;
	end

end

return Sim2D;
