SIM2D.TYPE.HEXBTN					= "hexbtn";
local tSim2D = Sim2D.__properties;

class "HexBtn" : extends(Btn) {

	__construct = function(this, sState, sName, nX, nY, nWidth, nHeight, nStratum, nLayer, bDoNotPoll, bDoNotAutoDraw)
		--create the hex size and center point based on the rectangle
		local nSize 	= nHeight / 2;
		local nCenterX 	= nX + nWidth / 2;
		local nCenterY 	= nY + nSize;
		local oHexPoint = point(nCenterX, nCenterY);
		local oHex 		= hex(oHexPoint, nSize);
		this:super(sState, sName, oHex, nStratum, nLayer, bDoNotPoll, bDoNotAutoDraw);
	end,
}

return HexBtn;
