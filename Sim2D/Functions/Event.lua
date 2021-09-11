--localization
local tSim2D 			= Sim2D.__properties;
local SIM2D 			= SIM2D;
local Application		= Application;
local Canvas 			= Canvas;
local const 			= const;
local DialogEx			= DialogEx;
local Drawing 			= Drawing;
local DrawingImage 		= DrawingImage;
local File				= File;
local Folder			= Folder;
local Game 				= Game;
local Page 				= Page;
local point 			= point;
local type				= type;
local Util 				= Sim2D.Util;
local InternalCallback 	= Sim2D.InternalCallback;
local OnDraw			= InternalCallback.OnDraw;
local OnEvent			= InternalCallback.OnEvent;

--TODO optimize

--TODO make this a more gneralized function
--TODO optimize


function Sim2D.OnPreLoad(sState)
	--set the active state
	Util.SetState(sState);

	--start the event timer
	Page.StartTimer(SIM2D.TIMER.EVENT.INTERVAL, 		SIM2D.TIMER.EVENT.ID);

	--start the pulse timers
	Page.StartTimer(SIM2D.PULSE.ULTRA_SLOW.INTERVAL, 	SIM2D.PULSE.ULTRA_SLOW.ID);
	Page.StartTimer(SIM2D.PULSE.SLOW.INTERVAL, 			SIM2D.PULSE.SLOW.ID);
	Page.StartTimer(SIM2D.PULSE.MEDIUM.INTERVAL, 		SIM2D.PULSE.MEDIUM.ID);
	Page.StartTimer(SIM2D.PULSE.FAST.INTERVAL, 			SIM2D.PULSE.FAST.ID);
	Page.StartTimer(SIM2D.PULSE.ULTRA_FAST.INTERVAL, 	SIM2D.PULSE.ULTRA_FAST.ID);

	--start the draw timer
	Page.StartTimer(SIM2D.TIMER.DRAW.INTERVAL, 			SIM2D.TIMER.DRAW.ID);

	--resize the state background TODO do this only once for each state
	local tAppRect = tSim2D.Ports[SIM2D.PORT.APP].Rect;
	DrawingImage.Resize(tSim2D.Canvas.Backgrounds[tSim2D.ActiveStateID], tAppRect.width, tAppRect.height, DRAW_RESIZE_INTERPOLATE);
end


--TODO the redraws are wrong
function Sim2D.OnShow(sState)
	local tAppRect = tSim2D.Ports[SIM2D.PORT.APP].Rect;

	--TODO only do this once!

	--setup the Sim2D canvas
	Application.SetRedraw(false);
	Input.SetSize(SIM2D.CANVAS, tAppRect.width, tAppRect.height);
	Input.SetPos(SIM2D.CANVAS, tAppRect.vertices.topLeft.x, tAppRect.vertices.topLeft.y);
	Application.SetRedraw(true);
	Canvas.Create(SIM2D.CANVAS, {Keyboard = true, ClipMouse = true});
	Application.SetRedraw(false);

	--add an event callback function
	Canvas.SetCallback(SIM2D.CANVAS, OnEvent);
end


Sim2D.OnStartup = function()
	--TODO cerate fonts path in the Sim2D Custom Folder

	--load the fonts
	for sFont, oFill in pairs(tSim2D.Fonts) do
		local pFont = _Fonts.."\\"..sFont..".ttf";

		if (File.DoesExist(pFont)) then
			oFill = DrawingFont.ImportPrivateFont(pFont);
		end

	end

	--get and store the app window handle and adjust the window accordingly
	local tApp 		= tSim2D.Ports[SIM2D.PORT.APP];
	local tSystem 	= tSim2D.Ports[SIM2D.PORT.SYSTEM];

	tApp.Wnd = Application.GetWndHandle();
	Window.SetSize(tApp.Wnd, tSystem.Rect.width, tSystem.Rect.height);
	Window.SetPos( tApp.Wnd, 0, 			 0);

	--get every state whether dialog or page
	local tStateTypes = {
		Pages 	= Application.GetPages();
		Dialogs = Application.GetDialogs();
	};

	--import the objects for each state
	for sIndex, tStates in pairs(tStateTypes) do

		for __, sState in pairs(tStates) do
			--create the state
			Util.AddState(sState:lower());

			--get the state ID
			local nStateID = tSim2D.StateIDs[sState:lower()];

			--determine if this is a page or dialog
			local bIsPage = sIndex == "Pages";

			--set the page/dialogex settings
			tSim2D.StateProperties[nStateID] = {
				Type			= bIsPage and "Page" or "DialogEx",
				FunctionTable 	= bIsPage and  Page 	or  DialogEx,
			};

			--local tSizes = Sim2D.Util.GetStatesSizes();

			--set the build size
			tSim2D.StateProperties[nStateID].BuildSize 		= {

			};

			--load the state background image
			tSim2D.Canvas.Backgrounds[nStateID] = DrawingImage.Load(Util.GetStateBackgroundPath(sState), nil);

			--create a place to store the pollable and pulsable objects
			tSim2D.ObjectsByName[nStateID]	= {};
			tSim2D.PollObjects[nStateID]	= {
				[SIM2D.STRATUM.GO]	 		= {},
				[SIM2D.STRATUM.EFFECT] 		= {},
				[SIM2D.STRATUM.UI]			= {},
			};
			tSim2D.PulseObjects[nStateID]	= {
				[SIM2D.PULSE.ULTRA_SLOW] 	= {},
				[SIM2D.PULSE.SLOW] 			= {},
				[SIM2D.PULSE.MEDIUM] 		= {},
				[SIM2D.PULSE.FAST] 			= {},
				[SIM2D.PULSE.ULTRA_FAST] 	= {},
			};
			tSim2D.DrawObjects[nStateID] 	= {
				[SIM2D.STRATUM.GO] 	= {
					[SIM2D.LAYER.BACKGROUND_BACK] 	= {},
					[SIM2D.LAYER.BACKGROUND_MID] 	= {},
					[SIM2D.LAYER.BACKGROUND_FRONT] 	= {},
					[SIM2D.LAYER.MIDGROUND_BACK] 	= {},
					[SIM2D.LAYER.MIDGROUND_MID] 	= {},
					[SIM2D.LAYER.MIDGROUND_FRONT] 	= {},
					[SIM2D.LAYER.FOREGROUND_BACK]	= {},
					[SIM2D.LAYER.FOREGROUND_MID] 	= {},
					[SIM2D.LAYER.FOREGROUND_FRONT] 	= {},
				},
				[SIM2D.STRATUM.EFFECT] = {
					[SIM2D.LAYER.BACKGROUND_BACK] 	= {},
					[SIM2D.LAYER.BACKGROUND_MID] 	= {},
					[SIM2D.LAYER.BACKGROUND_FRONT] 	= {},
					[SIM2D.LAYER.MIDGROUND_BACK] 	= {},
					[SIM2D.LAYER.MIDGROUND_MID] 	= {},
					[SIM2D.LAYER.MIDGROUND_FRONT] 	= {},
					[SIM2D.LAYER.FOREGROUND_BACK]	= {},
					[SIM2D.LAYER.FOREGROUND_MID] 	= {},
					[SIM2D.LAYER.FOREGROUND_FRONT] 	= {},
				},
				[SIM2D.STRATUM.UI] = {
					[SIM2D.LAYER.BACKGROUND_BACK] 	= {},
					[SIM2D.LAYER.BACKGROUND_MID] 	= {},
					[SIM2D.LAYER.BACKGROUND_FRONT] 	= {},
					[SIM2D.LAYER.MIDGROUND_BACK] 	= {},
					[SIM2D.LAYER.MIDGROUND_MID] 	= {},
					[SIM2D.LAYER.MIDGROUND_FRONT] 	= {},
					[SIM2D.LAYER.FOREGROUND_BACK]	= {},
					[SIM2D.LAYER.FOREGROUND_MID] 	= {},
					[SIM2D.LAYER.FOREGROUND_FRONT] 	= {},
				},
			};

			--import the objects from the factory files
			local bSuccess, tObjects = pcall(require, SIM2D.VAR.USER_FACTORY_PATH:gsub("\\", "%.").."."..sState..".Objects");

			if (bSuccess) then

				for sObject, tData in pairs(tObjects) do
					local oRect 	= UI.GetCoVAdjustedRect(tData.X, tData.Y, tData.Width, tData.Height);
					local nX 		= oRect.vertices.topLeft.x;
					local nY 		= oRect.vertices.topLeft.y;
					local nWidth 	= oRect.width;
					local nHeight 	= oRect.height;

					--TODO make this use a pairs function to call all obejct using their TYPEs (designated at the end ofeach class file)
					if (tData.Type == SIM2D.TYPE.PRG) then
						Prg(sState, sObject, nX, nY, nWidth, nHeight);

					--hex statebutton
					elseif (tData.Type == SIM2D.TYPE.STATEBTN) then
						StateBtn(sState, sObject, nX, nY, nWidth, nHeight);

					elseif (tData.Type == SIM2D.TYPE.COUNTYROW) then
						CountyRow(sState, sObject, nX, nY, nWidth, nHeight);

					end

				end

			end

		end

	end

end

function Sim2D.OnTimer(nID)

	if (nID == SIM2D.TIMER.EVENT.ID) then
		--[[____   ___      ___ _______   ________   _________  ________
		|\  ___ \ |\  \    /  /|\  ___ \ |\   ___  \|\___   ___\\   ____\
		\ \   __/|\ \  \  /  / | \   __/|\ \  \\ \  \|___ \  \_\ \  \___|_
		\ \  \_|/_\ \  \/  / / \ \  \_|/_\ \  \\ \  \   \ \  \ \ \_____  \
		 \ \  \_|\ \ \    / /   \ \  \_|\ \ \  \\ \  \   \ \  \ \|____|\  \
		  \ \_______\ \__/ /     \ \_______\ \__\\ \__\   \ \__\  ____\_\  \
		   \|_______|\|__|/       \|_______|\|__| \|__|    \|__| |\_________\
																 \|_________|]]


		tSim2D.EventUtil.ObjectHovered = nil;

		--iterate through the active state's objects and poll each one (which is pollable)
		for nStratum = 1, #tSim2D.PollObjects[tSim2D.ActiveStateID] do

			for x = 1, #tSim2D.PollObjects[tSim2D.ActiveStateID][nStratum] do
				local this 		= tSim2D.PollObjects[tSim2D.ActiveStateID][nStratum][x];
				local tSettings	= tSim2D.ObjectSettings[this];
	--TODO should i put all these hoverable objects in an actual queue to have their events fired?
				if (tSettings.AutoPoll) then

					if (tSettings.Shape:containsPoint(tSim2D.Canvas.Mouse.X, tSim2D.Canvas.Mouse.Y)) then
						tSim2D.EventUtil.ObjectHovered = this;

						if (tSettings.Hoverable) then
							--indicate that the mouse is over
							tSettings.Hovered = true;

							if (tSettings.OnEnterReady and type(this.OnEnter) == "function") then
							--turn off the onenter event
							tSettings.OnEnterReady = false;
							--fire the onenter event
							this:OnEnter(tSim2D.Canvas.Mouse.X, tSim2D.Canvas.Mouse.Y);
							--turn on the onleave event
							tSettings.OnLeaveReady = true;
							end

						end

					elseif (tSettings.OnLeaveReady and type(this.OnLeave) == "function") then

						--TODO check for toggle status before doing this part
						--set unclicked
						tSettings.ClickedLeft 	= false;
						tSettings.ClickedReft 	= false;
						tSettings.Clicked		= false;

						--indicate that the mouse is no longer over
						tSettings.Hovered = false;
						--turn off the onleave event
						tSettings.OnLeaveReady = false;
						--fire the onleave event
						this:OnLeave(tSim2D.Canvas.Mouse.X, tSim2D.Canvas.Mouse.Y);
						--turn on the onenter event
						tSettings.OnEnterReady = true;
					end

				end

			end

		end
	--[[ ________  ___  ___  ___       ________  _______
		|\   __  \|\  \|\  \|\  \     |\   ____\|\  ___ \
		\ \  \|\  \ \  \\\  \ \  \    \ \  \___|\ \   __/|
		 \ \   ____\ \  \\\  \ \  \    \ \_____  \ \  \_|/__
		  \ \  \___|\ \  \\\  \ \  \____\|____|\  \ \  \_|\ \
		   \ \__\    \ \_______\ \_______\____\_\  \ \_______\
		    \|__|     \|_______|\|_______|\_________\|_______|
		                                 \|_________|]]
	elseif (nID == SIM2D.PULSE.ULTRA_SLOW.ID) then

		for x = 1, #tSim2D.PulseObjects[tSim2D.ActiveStateID][SIM2D.PULSE.ULTRA_SLOW] do
			tSim2D.PulseObjects[tSim2D.ActiveStateID][SIM2D.PULSE.ULTRA_SLOW][x]:Pulse();
		end

	elseif (nID == SIM2D.PULSE.SLOW.ID) then

		for x = 1, #tSim2D.PulseObjects[tSim2D.ActiveStateID][SIM2D.PULSE.SLOW] do
			tSim2D.PulseObjects[tSim2D.ActiveStateID][SIM2D.PULSE.SLOW][x]:Pulse();
		end

	elseif (nID == SIM2D.PULSE.MEDIUM.ID) then

		for x = 1, #tSim2D.PulseObjects[tSim2D.ActiveStateID][SIM2D.PULSE.MEDIUM] do
			tSim2D.PulseObjects[tSim2D.ActiveStateID][SIM2D.PULSE.MEDIUM][x]:Pulse();
		end

	elseif (nID == SIM2D.PULSE.FAST.ID) then

		for x = 1, #tSim2D.PulseObjects[tSim2D.ActiveStateID][SIM2D.PULSE.FAST] do
			tSim2D.PulseObjects[tSim2D.ActiveStateID][SIM2D.PULSE.FAST][x]:Pulse();
		end

	elseif (nID == SIM2D.PULSE.ULTRA_FAST.ID) then

		for x = 1, #tSim2D.PulseObjects[tSim2D.ActiveStateID][SIM2D.PULSE.ULTRA_FAST] do
			tSim2D.PulseObjects[tSim2D.ActiveStateID][SIM2D.PULSE.ULTRA_FAST][x]:Pulse();
		end

	--[[ ________  ________  ________  ___       __
		|\   ___ \|\   __  \|\   __  \|\  \     |\  \
		\ \  \_|\ \ \  \|\  \ \  \|\  \ \  \    \ \  \
		 \ \  \ \\ \ \   _  _\ \   __  \ \  \  __\ \  \
		  \ \  \_\\ \ \  \\  \\ \  \ \  \ \  \|\__\_\  \
		   \ \_______\ \__\\ _\\ \__\ \__\ \____________\
		    \|_______|\|__|\|__|\|__|\|__|\|____________|]]
	elseif (nID == SIM2D.TIMER.DRAW.ID) then
		Canvas.Draw(SIM2D.CANVAS, OnDraw);

	end

end
