local tSim2D = Sim2D.__properties;

local tAnis = {};

local Drawing		= Drawing;
local DrawingImage 	= DrawingImage;
local pairs 		= pairs;
local point			= point;
local rectangle 	= rectangle;
local String 		= String;
local type 			= type;
local Sim2D 		= Sim2D;
local SIM2D 		= SIM2D;

local function nValidateSpeed(nSpeed)
	local bIsValid = type(nSpeed) == "number" and
		   (nSpeed == SIM2D.PULSE.ULTRA_SLOW.ID 	or
		    nSpeed == SIM2D.PULSE.SLOW.ID			or
			nSpeed == SIM2D.PULSE.MEDIUM.ID			or
			nSpeed == SIM2D.PULSE.FAST.ID			or
			nSpeed == SIM2D.PULSE.ULTRA_FAST.ID		or
			nSpeed == SIM2D.PULSE.SLOW.ID);
	return bIsValid and nSpeed or SIM2D.PULSE.MEDIUM.ID;

end

class "Ani" : extends(Sim2D) {

	__construct = function(this, sState, sName, oShape, hDC, nStratum, nLayer, pFolder, sFiletype, nDuration, nX, nY, nWidth, nHeight, bDoNotPoll, bDoNotAutoDraw)
		this:super(sState, sName, rectangle(point(nX, nY), nWidth, nHeight), hDC, nStratum, nLayer, bDoNotPoll, bDoNotAutoDraw);

		tAnis[this] = {
			CyclesPerSecond = -1,
			CurrentID		= -1,
			Duration 		= type(nDuration) == "number" and nDuration or 0,
			FileType		= type(sFiletype) == "string" and sFiletype or "",
			Images  		= {},
		};

		assert(Sim2D.ImageTypeIsValid(sFiletype), "Not a valid image type.");

		local tFiles = nil;

		if (Folder.DoesExist(pFolder)) then
			tFiles = File.Find(pFolder, "*"..sFiletype, false, false, nil, nil);

			if (tFiles) then

				for _, pFile in pairs(tFiles) do
					local sExt = String.SplitPath().Extension:lower();

					if (sExt == sFiletype) then
						tAnis[this].Images[#tAnis[this].Images + 1] = DrawingImage.Load(pImage, nil); --TODO move this responsibilty to uicom to prevent duplicate image loading
					end

				end

			end

		end

		assert(#tAnis[this].Images > 0, "Ani must be populated with images.");
	end,


	SetDuration = function(this, nValue)

	end,

	OnDraw = function(this)

		Drawing.SetFilteringMode(DRAW_BLEND_ALPHACLIP);

		--draw the state image
		Drawing.DrawImage(DrawingImage.GetID(tImage.Handle), tImage.X, tImage.Y);

		--draw the badge (if present)
		if (tBtns[this].Images.Badge.Handle) then
			Drawing.DrawImage(DrawingImage.GetID(tBtns[this].Images.Badge.Handle), tBtns[this].Images.Badge.X, tBtns[this].Images.Badge.Y);
		end

		Drawing.SetFilteringMode(DRAW_BLEND_DEFAULT);

	end,

	OnPulse = function(this)

	end,

	SetPulseRate = function(this) end --disabled since Ani uses it own measurements
};

return Ani;
