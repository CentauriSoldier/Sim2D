local tSim2D = Sim2D.__properties;
local Util = Sim2D.Util;

--stores image paths and handles to forestall multiple loadings of the same image file
local tImages = {};

--all the buttons
local tBtns = {};

--localization
local SIM2D 		= SIM2D;
local class 		= class;
local Drawing 		= Drawing;
local DrawingImage 	= DrawingImage;
local File 			= File;
local String 		= String;
local Sim2D 		= Sim2D;

local function LoadImage(oButton, pImage, sIndex, nWidth, nHeight, pCenter)
	local bRet = false;

	if (type(pImage) 	== "string" and
		File.DoesExist(pImage) 		and
		type(nWidth) 	== "number" and
		type(nHeight)	== "number" and
		type(pCenter)	== "point"	and
		Util.ImageTypeIsValid(String.SplitPath(pImage).Extension:lower())) then
			--load the image into the images table (if not present)
			tImages[pImage] = tImages[pImage] and tImages[pImage] or DrawingImage.Load(pImage, nil); --TODO allow for setting this second arg (whatever it is);

		if (oButton.Images[sIndex].Path ~= pImage) then
			oButton.Images[sIndex].Path 	= pImage;
			oButton.Images[sIndex].Handle 	= tImages[pImage];
			oButton.Images[sIndex].X 		= pCenter.x - nWidth 	/ 2;
			oButton.Images[sIndex].Y 		= pCenter.y - nHeight 	/ 2;

			DrawingImage.Resize(oButton.Images[sIndex].Handle, nWidth, nHeight, DRAW_RESIZE_INTERPOLATE);
			bRet = true;
		else
			oButton.Images[sIndex].Path 	= nil;
			oButton.Images[sIndex].Handle 	= nil;
			oButton.Images[sIndex].X 		= 0;
			oButton.Images[sIndex].Y 		= 0;

		end

	end

	return bRet;
end

local Btn = class "Btn" : extends(Sim2D) {

	__construct = function(this, sState, sName, oShape, nStratum, nLayer, bDoNotPoll, bDoNotAutoDraw)
		this:super(sState, sName, oShape, nStratum, nLayer, bDoNotPoll, bDoNotAutoDraw);

		tBtns[this] = this:__fields();--get the shared, quasi-protected fields
		local oBtn = tBtns[this];

		oBtn.Images = {
			Badge = {--draws no matter what, is topmost, and does not change
				Path 	= "",
				Handle 	= nil,
				X 		= 0,
				Y 		= 0,
			},
			Clicked = {
				Path 	= "",
				Handle 	= nil,
				X 		= 0,
				Y 		= 0,
			},
			Hovered = {
				Path 	= "",
				Handle 	= nil,
				X 		= 0,
				Y 		= 0,
			},
			Disabled = {
				Path 	= "",
				Handle 	= nil,
				X 		= 0,
				Y 		= 0,
			},
			Normal = {
				Path 	= "",
				Handle 	= nil,
				X 		= 0,
				Y 		= 0,
			},
		};
		oBtn.IsToggle = false;
		oBtn.Sounds = {
			Enter 		= {
				Path 	= "",
				Volume	= "",
			},
			Leave 		= {
				Path 	= "",
				Volume	= "",
			},
			LeftClick 	= {
				Path 	= "",
				Volume	= "",
			},
			RightClick 	= {
				Path 	= "",
				Volume	= "",
			},
		};

	end,

	SetBadgeImage = function(this, pImage, nWidth, nHeight, pCenter)
		return LoadImage(tBtns[this], pImage, "Badge", nWidth, nHeight, pCenter);
	end,

	SetClickedImage = function(this, pImage, nWidth, nHeight, pCenter)
		return LoadImage(tBtns[this], pImage, "Clicked", nWidth, nHeight, pCenter);
	end,

	SetHoveredImage = function(this, pImage, nWidth, nHeight, pCenter)
		return LoadImage(tBtns[this], pImage, "Hovered", nWidth, nHeight, pCenter);
	end,

	SetDisabledImage = function(this, pImage, nWidth, nHeight, pCenter)
		return LoadImage(tBtns[this], pImage, "Disabled", nWidth, nHeight, pCenter);
	end,

	SetNormalImage = function(this, pImage, nWidth, nHeight, pCenter)
		return LoadImage(tBtns[this], pImage, "Normal", nWidth, nHeight, pCenter);
	end,

	IsToggle = function(this)
		return tBtns[this].IsToggle;
	end,

	SetToggle = function(this, bFlag)
		tBtns[this].IsToggle = type(bFlag) == "boolean" and bFlag or false;
	end,

	SetImage = function()

	end,

	DrawImage = function(this)
		local tImage 	= nil;
		local oBtn 		= tBtns[this];

		if (this:GetEnabled()) then

			if (this:IsHovered()) then

				if (this:IsClicked()) then
					tImage = tBtns[this].Images.Clicked;
				else
					tImage = tBtns[this].Images.Hovered;
				end

			else
				tImage = tBtns[this].Images.Normal;
			end

		else
			tImage = tBtns[this].Images.Disabled;
		end

		if (tImage) then

			if (tImage.Handle) then
				Drawing.SetFilteringMode(DRAW_BLEND_ALPHACLIP);

				--draw the image
				Drawing.DrawImage(DrawingImage.GetID(tImage.Handle), tImage.X, tImage.Y);

				--draw the badge (if present)
				if (tBtns[this].Images.Badge.Handle) then
					Drawing.DrawImage(DrawingImage.GetID(tBtns[this].Images.Badge.Handle), tBtns[this].Images.Badge.X, tBtns[this].Images.Badge.Y);
				end

				Drawing.SetFilteringMode(DRAW_BLEND_DEFAULT);
			end


		end

	end,
};

return Btn;
