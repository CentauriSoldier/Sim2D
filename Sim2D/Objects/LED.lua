SIM2D.TYPE.LED					= "led";
SIM2D.LED						= const("SIM2D.LED", 		"", true);
SIM2D.LED.STATE					= const("SIM2D.LED.STATE", 	"", true);
SIM2D.LED.STATE.OFF				= 0;
SIM2D.LED.STATE.ON				= 1;
SIM2D.LED.STATE.PULSE			= 2;
--TODO add blink and flicker state

local tSim2D = Sim2D.__properties;
local tLEDs = {};

--localization
local class 	= class;
local Color 	= Color;
local Drawing 	= Drawing;
local math 		= math;
local circle 	= circle;
local point 	= point;
local pot 		= pot;
local SIM2D		= SIM2D;
local POT 		= POT;

local tLED = {
	BorderColor		= {Red = 0, Green = 0, Blue = 0}, --TODO use the math function to make a color here so we don't need to it in the constructor
	BorderWidth		= 3,
	MaxPulses 		= 20,
};

local function SetOnState(this, nRed, nGreen, nBlue)
	local oLED = tLEDs[this];

	--save the rgb color for later use
	oLED.OnColorRGB = {Red = nRed, Green = nGreen, Blue = nBlue};

	--save the decimal color
	oLED.OnColor = Color.RGB(nRed, nGreen, nBlue);
end


local function SetOffState(this, nRed, nGreen, nBlue)
	local oLED = tLEDs[this];

	--save the rgb color for later use
	oLED.OffColorRGB = {Red = nRed, Green = nGreen, Blue = nBlue};

	--save the decimal color
	oLED.OffColor = Color.RGB(nRed, nGreen, nBlue);
end


local function GetPulseDecay(nOnColor, nOffColor)
	--get the absolute difference between the colors
	local nRet = math.abs(nOnColor - nOffColor);
	--get the raw pulse value for the absolute average
	nRet = math.floor(nRet / tLED.MaxPulses);
	--return a clamped value
	return math.clamp(nRet, 0, 255);
end


local function GetPulseValue(nX, nOnColor, nOffColor, nPulseDecay)
	--get which direction the value should go
	local nAlt = (nOnColor > nOffColor) and -1 or 1;
	return math.clamp(nOnColor + (nX - 1) * nPulseDecay * nAlt,	0, 255);
end

local function ResetPulseColors(this)
	local oLED 		= tLEDs[this];
	local nOnRed 	= oLED.OnColorRGB.Red;
	local nOnGreen 	= oLED.OnColorRGB.Green;
	local nOnBlue 	= oLED.OnColorRGB.Blue;
	local nOffRed 	= oLED.OffColorRGB.Red;
	local nOffGreen = oLED.OffColorRGB.Green;
	local nOffBlue 	= oLED.OffColorRGB.Blue;

	--get the base pulse decay value for each color
	local nRedPulseDecay 	= GetPulseDecay(nOnRed, 	nOffRed);
	local nGreenPulseDecay 	= GetPulseDecay(nOnGreen,	nOffGreen);
	local nBluePulseDecay 	= GetPulseDecay(nOnBlue, 	nOffBlue);

	for x = tLED.MaxPulses, 1, -1 do

		local nColor = Color.RGB(
			GetPulseValue(x, nOnRed, 	nOffRed, 	nRedPulseDecay),
			GetPulseValue(x, nOnGreen, 	nOffGreen, 	nGreenPulseDecay),
			GetPulseValue(x, nOnBlue, 	nOffBlue, 	nBluePulseDecay)
		);

		--create the new pulse brush
		oLED.PulseColors[tLED.MaxPulses - x + 1] = nColor;
	end

end


class "LED" : extends(Sim2D) {


	__construct = function(this, sState, sName, nX, nY, nWidth, nHeight, nStratum, nLayer, hDC, bDoNotPoll, bDoNotAutoDraw)
		local nRadius 		= nHeight / 2;
		local nCenterX 		= nX + nWidth / 2;
		local nCenterY 		= nY + nHeight / 2;
		local oCirclePoint 	= point(nCenterX, nCenterY);
		local oCircle 		= circle(oCirclePoint, nRadius);

		tLEDs[this] = {
			ActiveColor 	= -1,
			DC 				= hDC,
			OnColor			= -1,
			OnColorRGB		= {Red = 255, Green = 0, Blue = 0},
			OffColor		= -1,
			OffColorRGB		= {Red = 0, Green = 0, Blue = 0},
			--LightBrush		= WinApi.CreateSolidBrush(255),
			--TODO allow differnt color and thickness of borders
			--BorderPen		= WinApi.CreatePen(PS_SOLID, 2, 0),
			PulseColors 	= {},
			PulsePot 		= pot(1, tLED.MaxPulses, 1, 1, POT.CONTINUITY.ALT),
			State 			= SIM2D.LED.STATE.OFF,
			Width 			= nWidth,
			Height 			= nHeight,
			X 				= nX,
			Y 				= nY,
			Shape 			= oCircle,
		};

		--TODO use a rectangle here or change all this to use a circle
		this:super(sState, sName, oCircle, hDC, nStratum, nLayer, bDoNotPoll, bDoNotAutoDraw);

		local oLED = tLEDs[this];
		SetOnState(this, oLED.OnColorRGB.Red, 	oLED.OnColorRGB.Green, 	oLED.OnColorRGB.Blue);
		SetOffState(this, oLED.OffColorRGB.Red, oLED.OffColorRGB.Green, oLED.OffColorRGB.Blue);
		ResetPulseColors(this);

		--setup the border color
		if (type(tLED.BorderColor) == "table") then
			tLED.BorderColor = Color.RGB(tLED.BorderColor.Red, tLED.BorderColor.Green, tLED.BorderColor.Blue);
		end

	end,


	Pulse = function(this)
		local oLED			= tLEDs[this];
		oLED.ActiveColor 	= oLED.OffColor;

		if (oLED.State == SIM2D.LED.STATE.ON) then
			oLED.ActiveColor = oLED.OnColor;

		elseif (oLED.State == SIM2D.LED.STATE.PULSE) then
			oLED.ActiveColor = oLED.PulseColors[oLED.PulsePot:increase()];

		end

	end,


	Destroy = function(this)
		--TODO destroy all the brushes

		table.remove(tLEDs, this);
		this = nil;
	end,


	OnDraw = function(this)
		local oLED 		= tLEDs[this];
		local nBrush 	= oLED.ActiveColor;

		Drawing.DrawCircle(oLED.Shape.center.x, oLED.Shape.center.y, tLEDs[this].Shape.radius, tLED.BorderColor);
		Drawing.DrawCircle(oLED.Shape.center.x, oLED.Shape.center.y, tLEDs[this].Shape.radius - tLED.BorderWidth, nBrush);
	end,

	SetOffColor = function(this, nRed, nGreen, nBlue, bDotNotResetPulseColors)
		SetOffState(this, nRed, nGreen, nBlue);

		if (not bDotNotResetPulseColors) then
			ResetPulseColors(this);
		end

	end,

	SetOnColor = function(this, nRed, nGreen, nBlue, bDotNotResetPulseColors)
		SetOnState(this, nRed, nGreen, nBlue);

		if (not bDotNotResetPulseColors) then
			ResetPulseColors(this);
		end

	end,

	SetLEDState = function(this, nState)
		tLEDs[this].State = nState;
	end,

};

return LED;
