local function importVertices(tVertices)

	if (rawtype(tVertices) == "table") then
		this.vertices = {};

		for x = 1, #tVertices do

			if (type(tVertices[x]) == "point")  then
				this.vertices[#this.vertices + 1] = point(tVertices[x].x, tVertices[x].y);
			end

		end

	end

end

local function updateDetector(this)
	this.detector = {};

	--calculate the poly
	local oLastPoint = this.vertices[#this.vertices];
	local nLastX = oLastPoint.x;
	local nLastY = oLastPoint.y;

	for x = 1, #this.vertices do
		local oPoint = this.vertices[x]
		local nX = oPoint.x;
		local nY = oPoint.y;
		-- Only store non-horizontal edges.
		if nY ~= nLastY then
			local index = #this.detector;
			this.detector[index+1] = nX;
			this.detector[index+2] = nY;
			this.detector[index+3] = (nLastX - nX) / (nLastY - nY);
		end
		nLastX = nX;
		nLastY = nY;
	end

end

local function updateCentroid(this)
	this.centroid 	= point();
	local nSumX 	= 0;
	local nSumY		= 0;
	local nVertices = #this.vertices;

	for x = 1, nVertices do
		local oPoint = this.vertices[x];
		nSumX = nSumX + oPoint.x;
		nSumY = nSumY + oPoint.y;
	end

	this.centroid.x = nSumX / nVertices;
	this.centroid.y = nSumY / nVertices;
end

local polygon = class "polygon" : extends(shape) {

	__construct = function(this)
		--check and import the vertices
		--importVertices(tVertices);

		--update the detector
		updateDetector(this);

		--calculate the centroid point
		updateCentroid(this);
	end,

	containsPoint 	= function(this, oPoint)
		local tDetector = this.detector;
		local nDetector = #tDetector;
		local nLastPX 	= tDetector[nDetector-2]
		local nLastPY 	= tDetector[nDetector-1]
		local bInside 	= false;

		for index = 1, #tDetector, 3 do
			local nPX = tDetector[index];
			local nPY = tDetector[index+1];
			local nDeltaX_Div_DeltaY = tDetector[index+2];

			if ((nPY > oPoint.y) ~= (nLastPY > oPoint.y)) and (oPoint.x < (oPoint.y - nPY) * nDeltaX_Div_DeltaY + nPX) then
				bInside = not bInside;
			end

			nLastPX = nPX;
			nLastPY = nPY;
		end

		return bInside;
	end,

	update = function(this)
		updateDetector(this);
		updateCentroid(this);
	end,
};

return polygon;
