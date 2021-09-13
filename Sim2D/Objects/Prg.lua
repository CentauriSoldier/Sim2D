SIM2D.TYPE.PRG					= "prg";

local SIM2D 	= SIM2D;
local Sim2D 	= Sim2D;
local tSim2D 	= Sim2D.__properties;

local tPrg 	= {
	LeftPadding = 5;
};
local tPrgs = {};

--localization
local class = class;
local Drawing = Drawing;
local rectangle = rectangle;
local point = point;
local Color = Color;
local DrawingFont = DrawingFont;

--TODO also make horizonal bars
class "Prg" : extends(Sim2D) {

	__construct = function(this, sState, sName, nX, nY, nWidth, nHeight, nStratum, nLayer, bDoNotPoll, bDoNotAutoDraw)
		local oRect = rectangle(point(nX, nY), nWidth, nHeight);
		this:super(sState, sName, oRect, nStratum, nLayer, bDoNotPoll, bDoNotAutoDraw);

		tPrgs[this] = this:__fields();--get the shared, quasi-protected fields
		local oPrg = tPrgs[this];

		oPrg.Bar 		= {X = 0, Y = 0, Width = 0, Height = 0};
		oPrg.BGColor 	= Color.RGB(0, 0, 0);
		oPrg.BarColor 	= Color.RGB(255, 0, 0);
		oPrg.CenterText = true;
		oPrg.CurrentPos	= 0;
		--tPrgs[this].--DC 			= hDC, --TODO allow this to be modified,
		oPrg.Font 		= nil;
		oPrg.Text 		= "";
		oPrg.TextColor 	= Color.RGB(255, 255, 255);



	end,

	Destroy = function(this)
		tPrgs[this] = nil;
		this = nil;
	end,

	SetCurrentPos = function(this, nPercent)
		local oObject = tPrgs[this]; --rect
		local oRect   = oObject.Shape;

		local nValue = math.floor((oRect.height) * nPercent) - 1;
		nValue = nValue >= 0 and nValue or 0;

		oObject.Bar = {
			X 		= oRect.vertices.topLeft.x + 1,
			Y 		= (oRect.vertices.topLeft.y + oRect.height) - nValue - 1,
			Width	= oRect.width - 1,
			Height 	= nValue,
		};
	end,

	SetCenterText = function(this, bFlag)
		tPrgs[this].CenterText = type(bFlag) == "boolean" and bFlag or false;
	end,

	OnDraw = function(this)
		local oObject = tPrgs[this];
		local oRect   = oObject.Shape;
		local tBar 	  = oObject.Bar

		Drawing.DrawRectangle(oRect.vertices.topLeft.x, oRect.vertices.topLeft.y, oRect.width,oRect.height, oObject.BGColor);
		Drawing.DrawRectangle(tBar.X, tBar.Y, tBar.Width, tBar.Height, oObject.BarColor);

		if (oObject.Font) then
			Drawing.SetDrawingFont(oObject.Font);

			local nTextHeight  	= Drawing.GetTextHeight(oObject.Text);
			local nX = oRect.vertices.topLeft.x + tPrg.LeftPadding;
			local nY = ( oRect.vertices.topLeft.y + oRect.height / 2 ) - (nTextHeight / 2);

			if (tPrgs[this].CenterText) then
				local nTextWidth   	= Drawing.GetTextWidth(oObject.Text);
				nX = ( oRect.vertices.topLeft.x + oRect.width / 2 ) - (nTextWidth / 2);
			end

			Drawing.DrawText(nX, nY, oObject.Text, oObject.TextColor);
		end

	end,

	SetBGColor = function(this, nRed, nBlue, nGreen)
		local oObject = tPrgs[this];
		oObject.BGColor = Color.RGB(nRed, nBlue, nGreen);
	end,

	SetBarColor = function(this, nRed, nBlue, nGreen)
		local oObject = tPrgs[this];
		oObject.BarColor = Color.RGB(nRed, nBlue, nGreen);
	end,

	SetText = function(this, sText)
		tPrgs[this].Text = type(sText) == "string" and sText or "";
	end,

	SetFont = function(this, sFontName, nSize, tOptions)
		tPrgs[this].Font = DrawingFont.Load(sFontName, nSize, tOptions);
	end,

	SetTextColor = function(this, nRed, nBlue, nGreen)
		local oObject = tPrgs[this];
		oObject.TextColor = Color.RGB(nRed, nBlue, nGreen);
	end,
};

return Prg;
