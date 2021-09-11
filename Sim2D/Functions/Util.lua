Sim2D.Util = {};

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


function Sim2D.Util.IsCompiled()--TODO remove this now that uicom requires project
	local sParent = String.Mid(_ExeFolder, String.ReverseFind(_ExeFolder, "\\") + 1, -1);
	local bRet = true;

	if String.Lower(sParent) == "cd_root" then
		bRet = false;
	end

	return bRet;
end


function Sim2D.Util.GetStateBackgroundPath(sState)
	--set the default path (in case the state has no image)
	local pImage = SIM2D.VAR.USER_FACTORY_PATH.."\\Default Background.png";
	--get teh state folder path
	local pFolder = SIM2D.VAR.USER_FACTORY_PATH.."\\"..sState;

	if (Folder.DoesExist(pFolder)) then

		--look for each allowed mime type
		for _, sAllowedType in pairs(tSim2D.AllowedImagesTypes) do
			local pTestPath = pFolder.."\\Background"..sAllowedType;

			--if the image is valid, send the path back to the client
			if (File.DoesExist(pTestPath)) then
				pImage = pTestPath;
				break;
			end

		end



	end
	return pImage;
end


function Sim2D.Util.SetState(sState)

	if (type(sState) == "string" and type(tSim2D.StatesExist[sState:lower()]) == "boolean" and tSim2D.StatesExist[sState:lower()]) then
		sState = sState:lower();
		tSim2D.ActiveState 		= sState;
		tSim2D.ActiveStateID 	= tSim2D.StateIDs[sState];

		if (Application.GetCurrentPage() == "") then
			tSim2D.PageOrDialog = DialogEx;
		else
			tSim2D.PageOrDialog = Page;
		end

	end

end


function Sim2D.Util.AddState(sState)

	if (type(sState) == "string" and type(tSim2D.StatesExist[sState:lower()]) ~= "boolean") then
		sState = sState:lower();
		tSim2D.StatesExist[sState] = true;

		local nNextIndex = 1;
		for _, __ in pairs(tSim2D.StateIDs) do
			nNextIndex = nNextIndex + 1;
		end

		tSim2D.StateIDs[sState] = nNextIndex;
	end

end


function Sim2D.Util.LayerIsValid(vLayer)
	return (type(vLayer) == "number" and vLayer > 0 and vLayer <= SIM2D.LAYER.COUNT and math.floor(vLayer) == vLayer);
end

function Sim2D.Util.StratumIsValid(nStratum)
	return (type(nStratum) == "number" and nStratum > 0 and nStratum <= SIM2D.STRATUM.COUNT and math.floor(nStratum) == nStratum);
end


function Sim2D.Util.ImageTypeIsValid(sType)
	local bRet = false;

	if (type(sType) == "string") then

		for _, sAllowedType in pairs(tSim2D.AllowedImagesTypes) do

			if (sType:lower() == sAllowedType) then
				bRet = true;
				break;
			end
		end

	end

	return bRet;
end


function Sim2D.Util.GetPrivateFont(sFontName)
	ftRet = nil;

	if (type(sFontName) == "string" and type(tSim2D.Fonts[sFontName]) ~= "nil") then
		ftRet = tSim2D.Fonts[sFontName];
	end

	return ftRet;
end


function Sim2D.Util.GetObject(sState, sObject)
	local oRet = nil;

	if (type(tSim2D.StateIDs[sState:lower()]) == "number") then
		local nIndex = tSim2D.StateIDs[sState:lower()];

		if (type(tSim2D.ObjectsByName[nIndex]) ~= "nil" and
			type(tSim2D.ObjectsByName[nIndex][sObject]) ~= "nil") then
				oRet = tSim2D.ObjectsByName[nIndex][sObject];
		end

	end

	return oRet;
end
