--[[*
@authors Centauri Soldier
@copyright Public Domain
@description
	<h2>triangle</h2>
	<p></p>
@license <p>The Unlicense<br>
<br>
@moduleid triangle
@version 1.1
@versionhistory
<ul>
	<li>
		<b>1.0</b>
		<br>
		<p>Created the module.</p>
	</li>
	<li>
		<b>1.1</b>
		<br>
		<p>Add serialize and deserialize methods.</p>
	</li>
</ul>
@website https://github.com/CentauriSoldier
*]]

--localization
local class 		= class;
local serialize		= serialize;
local deserialize	= deserialize;
local type 			= type;

local function recalculateVertices(this)
	this.vertices.top.x	 		= this.vertices.topLeft.x + this.width;
	this.vertices.top.y	 		= this.vertices.topLeft.y;
	this.vertices.bottomLeft.x 	= this.vertices.topLeft.x
	this.vertices.bottomLeft.y 	= this.vertices.topLeft.y + this.height;
	this.vertices.bottomRight.x	= this.vertices.topRight.x;
	this.vertices.bottomRight.y	= this.vertices.bottomLeft.y;
	this.vertices.center.x		= this.vertices.topLeft.x + this.width / 2;
	this.vertices.center.y		= this.vertices.topLeft.y + this.height / 2;
end


local triangle = class "triangle" : extends(shape) {

	--[[
	@desc The constructor for the triangle class.
	@func triangle
	@mod triangle
	@ret oTriangle triangle A triangle object. Public properties are vertices (a table containing points for each corner [topLeft, topRight, bottomRight, bottomLeft, center]), width and height.
	]]
	__construct = function(this, pTopLeft, nWidth, nHeight)
		this:super();
		this.vertices 	= {
			topLeft 	= point(),
			bottomLeft 	= point(),
			bottomRight = point(),
			center		= point();
		};
		this.width 		= type(nWidth) 	== "number" and nWidth 	or 0;
		this.height 	= type(nHeight) == "number" and nHeight or 0;

		--check the point input
		if (type(pTopLeft) == "point") then
			this.vertices.topLeft.x = pTopLeft.x;
			this.vertices.topLeft.y	= pTopLeft.y;
		end

		recalculateVertices(this);
	end,


	area = function()
		return this.width * this.height;
	end,


	containsPoint = function(this, nX, nY)
		return nX >= this.vertices.topLeft.x and nX <= this.vertices.topRight.x and
			   nY >= this.vertices.topLeft.y and nY <= this.vertices.bottomRight.y;
	end,

	deserialize = function(this, sData)
		local tData = deserialize.table(sData);

		this.vertices.top	 		= this.vertices.top:deserialize(tData.vertices.top);
		this.vertices.bottomLeft 	= this.vertices.bottomLeft:deserialize(tData.vertices.bottomLeft);
		this.vertices.bottomRight 	= this.vertices.bottomRight:deserialize(tData.vertices.bottomRight);
		this.vertices.center		= this.vertices.center:deserialize(tData.vertices.center);

		this.width 		= tData.width;
		this.height 	= tData.height;
	end,

	perimeter = function(this)
		return 2 * this.width + 2 * this.height;
	end,

--[[
	pointIsOnPerimeter = function(this, vPoint, vY)

	end
]]
	recalculateVertices = function(this)
		recalculateVertices(this);
	end,


	--[[!
		@desc Serializes the object's data.
		@func triangle.serialize
		@module triangle
		@param bDefer boolean Whether or not to return a table of data to be serialized instead of a serialize string (if deferring serializtion to another object).
		@ret sData StringOrTable The data, returned as a serialized table (string) or a table is the defer option is set to true.
	!]]
	serialize = function(this, bDefer)
		local tData = {
			vertices 	= {
				top	 		= this.vertices.top:seralize(),
				bottomLeft 	= this.vertices.bottomLeft:seralize(),
				bottomRight = this.vertices.bottomRight:seralize(),
				center		= this.vertices.center:seralize(),
			},
			width 		= this.width,
			height 		= this.height,
		};

		if (not bDefer) then
			tData = serialize.table(tData);
		end

		return tData;
	end,


};

return rectangle;
