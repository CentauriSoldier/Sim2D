SIM2D.TYPE.CIRCLEBTN					= "circlebtn";
local tSim2D = Sim2D.__properties;
local tRoundBtn = {};

class "CircleBtn" : extends(Btn) {

	__construct = function(this, sState, sName, nX, nY, nWidth, nHeight, nStratum, nLayer, bDoNotPoll, bDoNotAutoDraw)
		local nRadius 		= nHeight / 2;
		local nCenterX 		= nX + nWidth / 2;
		local nCenterY 		= nY + nHeight / 2;
		local oCirclePoint 	= point(nCenterX, nCenterY);
		local oCircle 		= circle(oCirclePoint, nRadius);

		this:super(sState, sName, oCircle, nStratum, nLayer, bDoNotPoll, bDoNotAutoDraw);

		tRoundBtn[this] = this:__fields();--get the shared, quasi-protected fields
	end,

}

return CircleBtn;
