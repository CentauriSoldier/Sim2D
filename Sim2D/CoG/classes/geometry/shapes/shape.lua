--[[*
@authors Centauri Soldier
@copyright Public Domain
@description
	<h2>rectangle</h2>
	<p></p>
@license <p>The Unlicense<br>
<br>
@moduleid shape
@version 1.0
@versionhistory
<ul>
	<li>
		<b>1.0</b>
		<br>
		<p>Created the module.</p>
	</li>
</ul>
@website https://github.com/CentauriSoldier
*]]


--localization
local class	= class;



local shape = class "shape" {
	containsPoint  = function()
		error("The 'containsPoint' function has not been implemented in the child class.");
	end,
	update  = function()
		error("The 'update' function has not been implemented in the child class.");
	end,
};

--make public, static versions of these functions


--[[
For use with the shape.containsPoint
]]

--THIS IS CURRENTLY JUST REFERENCE FOR CREATING CHILD METHODS

--[[function shape.createPickablePolygon(tPoints)
	-- Takes in a table with a sequence of ints for the (x, y) of each point of the polygon.
	-- Example: {x1, y1, x2, y2, x3, y3, ...}
	-- Note: no need to repeat the first point at the end of the table, the testing function
	-- already handles that.
	local tPoly = {};
	local oLastPoint = tPoints[#tPoints];
	local nLastX = oLastPoint.x;
	local nLastY = oLastPoint.y;

	for _, oPoint in tPoints do
		local nX = oPoint.x;
		local nY = oPoint.y;
		-- Only store non-horizontal edges.
		if nY ~= pLast.y then
			local index = #tPoly;
			tPoly[index+1] = nX;
			tPoly[index+2] = nY;
			tPoly[index+3] = (nLastX - nX) / (nLastY - nY);
		end
		nLastX = nX;
		nLastY = nY;
	end
	return tPoly
end
]]
--for speed, this should be impletmented in each child class
--[[function shape.containsPoint(x, y, poly)
	-- Takes in the x and y of the point in question, and a 'poly' table created by
	-- createPickablePolygon(). Returns true if the point is within the polygon, otherwise false.
	-- Note: the coordinates of the test point and the polygon points are all assumed to be in
	-- the same space.

	-- Original algorithm by W. Randolph Franklin (WRF):
	-- https://wrf.ecse.rpi.edu//Research/Short_Notes/pnpoly.html

	local lastPX = poly[#poly-2]
	local lastPY = poly[#poly-1]
	local inside = false
	for index = 1, #poly, 3 do
		local px = poly[index]
		local py = poly[index+1]
		local deltaX_div_deltaY = poly[index+2]
		-- 'deltaX_div_deltaY' is a precomputed optimization. The original line is:
		-- if ((py > y) ~= (lastPY > y)) and (x < (y - py) * (lastX - px) / (lastY - py) + px) then
		if ((py > y) ~= (lastPY > y)) and (x < (y - py) * deltaX_div_deltaY + px) then
			inside = not inside
		end
		lastPX = px
		lastPY = py
	end
	return inside
end]]

return shape;
