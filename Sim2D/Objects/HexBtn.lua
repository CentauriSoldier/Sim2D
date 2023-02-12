local tSim2D = Sim2D.__properties;

local HexBtn = class "HexBtn" : extends(Btn) {

	__construct = function(this, tProtected, sState, sName, nX, nY, nWidth, nHeight, nStratum, nLayer, bDoNotPoll, bDoNotAutoDraw)
		--create the hex size and center point based on the rectangle
		local nSize 	= nHeight / 2;
		local nCenterX 	= nX + nWidth / 2;
		local nCenterY 	= nY + nSize;
		local oHexPoint = point(nCenterX, nCenterY);
		local oHex 		= hex(oHexPoint, nSize, true);
		this:super(sState, sName, oHex, nStratum, nLayer, bDoNotPoll, bDoNotAutoDraw);
		--this:__fields();--get the shared, quasi-protected fields
	end,
}

return HexBtn;
