Sim2D.InternalCallback = {};

--localization
local tSim2D 		= Sim2D.__properties;
local SIM2D 		= SIM2D;
local Application	= Application;
local Canvas 		= Canvas;
local const 		= const;
local DialogEx		= DialogEx;
local Drawing 		= Drawing;
local DrawingImage 	= DrawingImage;
local File			= File;
local Folder		= Folder;
local Game 			= Game;
local Page 			= Page;
local point 		= point;
local type			= type;
local Util 			= Sim2D.Util;

local hPanel = DrawingImage.Load(_Images.."\\TalentSlot_Special.png", nil);
local hImage = DrawingImage.New(300, 200, 32, DRAW_IMAGE_TRANSPARENT);


function Sim2D.InternalCallback.OnDraw(sObjectName, D, hDC)
	local tAppRect = tSim2D.Ports[SIM2D.PORT.APP].Rect;

	--clear the canvas
	Drawing.DrawRectangle(0, 0, tAppRect:getWidth(), tAppRect:getHeight(), SIM2D.CANVAS.COLOR.value);

	--draw the canvas background  --TODO do not do this here...this should be left to the user to do by creating an image object and setting its layer to 0
	--Drawing.DrawImage(DrawingImage.GetID(tSim2D.Canvas.Backgrounds[tSim2D.ActiveStateID]), 0, 0);


	--iterate through each each stratum in the active state
	for sStratum, sStratum in SIM2D.STRATUM() do

		--iterate through each each layer in this stratum
		for sLayer, nLayer in SIM2D.LAYER() do
		local tLayer = tSim2D.DrawObjects[tSim2D.ActiveStateID][nStratum][nLayer];

			--draw each object in this layer
			for nIndex = 1, #tLayer do
				local oObject = tLayer[nIndex];

				--TODO add a check to determine if the object is within the boundary of the canvas
				if (tSim2D.ObjectSettings[oObject].Visible and type(oObject.OnDraw) == "function") then
					oObject:OnDraw(tSim2D.Canvas.Mouse.X, tSim2D.Canvas.Mouse.Y, sObjectName, D, hDC);
				end

			end

		end

	end

	--TEST draw a panel (for fps testing)
	--Drawing.DrawImage(DrawingImage.GetID(hPanel), tSim2D.Canvas.Mouse.X, tSim2D.Canvas.Mouse.Y);
end

--[[
eventContext = {
  ObjectName      -- A string representing the AMS object from where the canvas area event is fired
  EventCode       -- A numeric event code, one of these values:
    - These events will only be fired when the ClipMouse option is set on creation.
    - CANVAS_MOUSE_ENTER                -- Fired when the mouse pointer enters the canvas area
    - CANVAS_MOUSE_LEAVE                -- Fired when the mouse pointer leaves the canvas area
    - CANVAS_MOUSE_MOVE                 -- Fired when the mouse moves inside the canvas area
    - CANVAS_MOUSE_WHEEL                -- Fired when the user uses the scroll wheel inside the canvas area
    - CANVAS_MOUSE_LEFT_DOWN            -- Fired when the left mouse button is pressed down.
    - CANVAS_MOUSE_LEFT_UP              -- Fired when the left mouse button is released.
    - CANVAS_MOUSE_LEFT_CLICK           -- Fired when the left mouse button is clicked.
    - CANVAS_MOUSE_LEFT_DOUBLECLICK     -- Fired when the left mouse button is double clicked.
    - CANVAS_MOUSE_RIGHT_DOWN           -- Fired when the right mouse button is pressed down.
    - CANVAS_MOUSE_RIGHT_UP             -- Fired when the right mouse button is released.
    - CANVAS_MOUSE_RIGHT_CLICK          -- Fired when the right mouse button is clicked.
    - CANVAS_MOUSE_RIGHT_DOUBLECLICK    -- Fired when the right mouse button is double clicked.
    - CANVAS_MOUSE_MIDDLE_DOWN          -- Fired when the scroll wheel button is pressed down.
    - CANVAS_MOUSE_MIDDLE_UP            -- Fired when the scroll wheel button is released.

    - These events will only be fired when the Keyboard option is set on creation.
    - CANVAS_KEYBOARD_FOCUS             -- Fired when the canvas area catches keyboard focus.
    - CANVAS_KEYBOARD_LOST_FOCUS        -- Fired when the canvas area loses keyboard focus.
    - CANVAS_KEYBOARD_KEY_DOWN          -- Fired when a keyboard button is pressed down.
    - CANVAS_KEYBOARD_KEY_UP            -- Fired when a keyboard button is released.
    - CANVAS_KEYBOARD_INPUT             -- Fired when input is received, one character precisely as how it is typed.

  Mouse = {
    x               -- A number representing the current X position of the mouse, relative to the canvas area.
    y               -- A number representing the current Y position of the mouse, relative to the canvas area.
    WheelDelta      -- A number representing the wheel data of the mouse scrollwheel, -1 is scrolling down, 1 is scrolling up.
    LeftButtonDown  -- A boolean indicating whether the left mouse button is down or not.
    RightButtonDown -- A boolean indicating whether the right mouse button is down or not.
    MiddleButtonDown-- A boolean indicating whether the middle mouse button is down or not.
  }

  Keyboard = {
    Key             -- A number representing a keycode for a pressed key.
    Input           -- An ASCII code for the input character that has been received. Use String.Char on this value to get a string.
    Modifiers = {
      Shift       -- A boolean indicating whether the Shift key is down or not.
      Alt         -- A boolean indicating whether the Alt key is down or not.
      Control     -- A boolean indicating whether the Control key is down or not.
    }
  }
};

This is the hierarchy of the event context table, to access e.g. the event code, use:
eventContext.EventCode

Or to access the Input and Control modifier:
eventContext.Keyboard.Input
eventContext.Keyboard.Modifiers.Control
]]

local nX = 0;
local nY = 0;
function Sim2D.InternalCallback.OnEvent(tEvent)
	local nEvent = tEvent.EventCode;
	--local sState 	= tSim2D.ActiveState;
	local oHovered 	= tSim2D.EventUtil.ObjectHovered;
	local tSettings = nil;

	if (oHovered) then
		tSettings = tSim2D.ObjectSettings[oHovered];
	end

	if (nEvent == CANVAS_MOUSE_MOVE) then
		nX = tEvent.Mouse.x;
		nY = tEvent.Mouse.y;

		--update the app/canvas mouse coordinates
		tSim2D.Canvas.Mouse.X = nX;
		tSim2D.Canvas.Mouse.Y = nY;
		tSim2D.Canvas.Mouse.Point.x = tSim2D.Canvas.Mouse.X;
		tSim2D.Canvas.Mouse.Point.y = tSim2D.Canvas.Mouse.Y;

	elseif (nEvent == CANVAS_MOUSE_LEFT_DOWN) then

		if (oHovered) then
			tSettings.ClickedLeft 	= tSettings.ClickableLeft;
			tSettings.Clicked		= tSettings.ClickableLeft;

			if (tSettings.ClickableLeft) then

				if (type(oHovered.OnLButtonDown) == "function") then
					oHovered:OnLButtonDown(tSim2D.Canvas.Mouse.X, tSim2D.Canvas.Mouse.Y);
				end

			end

		end

	elseif (nEvent == CANVAS_MOUSE_LEFT_UP) then

		if (oHovered) then
			tSettings.ClickedLeft 	= false;
			tSettings.Clicked		= false;

			if (tSettings.ClickableLeft) then

				if (type(oHovered.OnLButtonUp) == "function") then
					oHovered:OnLButtonUp(tSim2D.Canvas.Mouse.X, tSim2D.Canvas.Mouse.Y);
				end

			end

		end

	elseif (nEvent == CANVAS_MOUSE_RIGHT_DOWN) then

		if (oHovered) then
			tSettings.ClickedRight 	= tSettings.ClickableRight;
			tSettings.Clicked		= tSettings.ClickableRight;

			if (tSettings.ClickableRight) then

				if (type(oHovered.OnRButtonDown) == "function") then
					oHovered:OnRButtonDown(tSim2D.Canvas.Mouse.X, tSim2D.Canvas.Mouse.Y);
				end

			end

		end

	elseif (nEvent == CANVAS_MOUSE_RIGHT_UP) then

		if (oHovered) then
			tSettings.ClickedRight 	= false;
			tSettings.Clicked		= false;

			if (tSettings.ClickableRight) then

				if (type(oHovered.OnRButtonUp) == "function") then
					oHovered:OnRButtonUp(tSim2D.Canvas.Mouse.X, tSim2D.Canvas.Mouse.Y);
				end

			end

		end

	elseif (nEvent == CANVAS_KEYBOARD_KEY_DOWN) then
		local tModifiers = tEvent.Keyboard.Modifiers;
		local nKey = tEvent.Keyboard.Key;
		--TODO allow user-made event functions to fire
		--TODO setupa  system that tells this section when the keyboard is over an input box
		if (nKey == 27) then --ESC
			Application.Exit(0);

		elseif (nKey == 72) then --H
			DialogEx.Show("Help");

		elseif (nKey == 107) then --numpad +
			Game.SpeedUp();

		elseif (nKey == 109) then --numpad -
			Game.SlowDown();

		end

		--ALT
		if (tModifiers.Control) then

		end

		--CRTL
		if (tModifiers.Control) then

			if (nKey == 68) then --CRTL D
				tSim2D.DebugWindowVisible = not tSim2D.DebugWindowVisible;

				--TODO replace this with a Sim2D debug window object
				Debug.SetTraceMode(false);
				Debug.Clear();
				Debug.ShowWindow(tSim2D.DebugWindowVisible);
			end

		end

		--SHIFT
		if (tModifiers.Control) then

		end

	end



	--[[mousewheel
	for sObject, this in pairs(tSim2D.PollObjects[tSim2D.ActiveState]) do
		local tProps = tSim2D.ObjectSettings[this];

		if (tProps.Shape:containsPoint(tSim2D.Canvas.Mouse.X, tSim2D.Canvas.Mouse.Y) and
			type(this.OnMouseWheel) == "function") then
			this:OnMouseWheel(nFlags, nDelta, tSim2D.Canvas.Mouse.X, tSim2D.Canvas.Mouse.Y);
			break;
		end

	end
]]
end
