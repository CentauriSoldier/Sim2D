--[[*
@authors Centauri Soldier
@copyright Public Domain
@description
	<h2>CoG</h2>
	<h3>Code of Gaming: A collection of code designed to make game creation must easier.</h3>
@email
@features
	<h3>Extends the Lua Libraires</h3>
	<p>Adds several useful function into the main lua libraries such as string, math, etc..</p>
	<h3>No Dependencies</h3>
	<p>CoG needs nothing but itself to run correctly. No installing, no configuring, no mess.</p>
	<h3>CoG has game development in mind</h3>
	<p>CoG ships with not only geometry classes but also with classes like pot(potentiometer), targetor(for managing targeting), combator(handles combat) and several others. All these classes can be extendable to suit the specific needs of your game while still maintaining a general usage standard that can be applied to several different game types.</p>
	<h3>Classes</h3>
	<h4>Audio</h4>
	<ul>
		<li>playlist<br>Allows the creation and manipulation of song playlists.</li>
	</ul>
	<h4>Component</h4>
	<ul>
		<li><strong>pot</strong><br>A logical potentiomter class capable of being fixed or revolving.</p></li>
		<li><p><strong>protean</strong><br>Designed to hold a base value which can be operated on without needing to change the base value when altering addative or multiplicative values derived from the base. Great for things like character stats or any other value which needs to have its original value available and unchanged after being altered by bonuses or penalties.</p></li>
	</ul>
	<h4>Geometry</h4>
	<ul>
		<li><p><strong></strong><br></p></li>
		<li><p><strong></strong><br></p></li>
		<li><p><strong></strong><br></p></li>
		<li><p><strong></strong><br></p></li>
		<li><p><strong></strong><br></p></li>
		<li><p><strong></strong><br></p></li>
		<li><p><strong></strong><br></p></li>
		<li><p><strong></strong><br></p></li>
	</ul>
	<h4>Uncategorized</h4>
	<ul>
		<li><p><strong></strong><br></p></li>
		<li><p><strong></strong><br></p></li>
		<li><p><strong></strong><br></p></li>
		<li><p><strong></strong><br></p></li>
	</ul>
	<h3>Libraries</h3>
	<ul>
		<li><p><strong></strong><br></p></li>
		<li><p><strong></strong><br></p></li>
		<li><p><strong></strong><br></p></li>
		<li><p><strong></strong><br></p></li>
	</ul>
	<h3>Static <em>(non-class)</em> Modules</h3>
@license <p>The Unlicense<br>
<br>Copyright Public Domain<br>
<br>
This is free and unencumbered software released into the public domain.
<br><br>
Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.
<br><br>
In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.
<br><br>
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
<br><br>
For more information, please refer to <http://unlicense.org/>
</p>
@plannedfeatures
<ul>
	<li>Lua 5.4 features while remaining backward compatible with Lua 5.1</li>
</ul>
@moduleid cog|CoG
@todo
<ul>
	<li>Finish the Basic Combat Classes</li>
</ul>
@usage
	<h2>Coming Soon</h2>
@version 0.5
@versionhistory
<ul>
	<li>
		<b>0.5</b>
		<br>
		<p>Change: updated all modules and classes to use the new LuaEx system.</p>
		<p>Change: removed queue class.</p>
		<p>Change: removed stack class.</p>
		<b>0.4</b>
		<br>
		<p>Removed the class module (as well other commonly-used Lua libraries) and ported them to a new project. Added CoG's dependency on said project.</p>
		<b>0.3</b>
		<br>
		<p>Created an init module to allow for a single require call to CoG which loads all desired modules</p>
		<b>0.2</b>
		<br>
		<p>Added the class module (create by Bas Groothedde).</p>
		<p>Added several classes.</p>
		<b>0.1</b>
		<br>
		<p>Compiled various modules into CoG.</p>
	</li>
</ul>
@website https://github.com/CentauriSoldier/CoG
*]]

--warn the user if debug is missing
assert(type(debug) == "table", "CoG requires the debug library during initialization. Please enable the debug library before initializing CoG.");

--determine the call location
local sPath = debug.getinfo(1, "S").source;
--remove the calling filename
sPath = sPath:gsub("@", ""):gsub("[Ii][Nn][Ii][Tt].[Ll][Uu][Aa]", "");
--remove the "/" at the end
sPath = sPath:sub(1, sPath:len() - 1);
--update the package.path (use the main directory to prevent namespace issues)
package.path = package.path..";"..sPath.."\\..\\?.lua";

local rCoG				= "CoG";
local rStatic 			= rCoG..".static";
local rGenerators		= rStatic..".generators";
local rClasses 			= rCoG..".classes";
local rClassesAudio 	= rClasses..".audio";
local rClassesComponent	= rClasses..".component";
local rClassesGeometry	= rClasses..".geometry";
local rClassesShapes	= rClassesGeometry..".shapes";

--require LuaEx
if not (LUAEX_INIT) then
	require("CoG.LuaEx.init");
end

--warn the user if LuaEx is missing
assert(type(LUAEX_INIT) == "boolean" and LUAEX_INIT, "CoG requires the LuaEx library during initialization. Please include and load the LuaEx library before initializing CoG.");

--TODO move to constants.lua file

--[[The anchor point of a shape
	is the point that is used
	when setting or getting
	the position of the shape.
	Note: the anchor point may
	or may not lie outside the
	bounds of the shape.]]
constant("SHAPE_ANCHOR_COUNT",	 		 5); --DO NOT CHANGE THIS VALUE
constant("SHAPE_ANCHOR_TOP_LEFT", 		-5); --DO NOT CHANGE THIS VALUE
constant("SHAPE_ANCHOR_TOP_RIGHT", 		-4); --DO NOT CHANGE THIS VALUE
constant("SHAPE_ANCHOR_BOTTOM_RIGHT", 	-3); --DO NOT CHANGE THIS VALUE
constant("SHAPE_ANCHOR_BOTTOM_LEFT", 	-2); --DO NOT CHANGE THIS VALUE
constant("SHAPE_ANCHOR_CENTROID",	 	-1); --DO NOT CHANGE THIS VALUE
--constant("SHAPE_ANCHOR_VERTEX",	 		-1); --DO NOT CHANGE THIS VALUE
--[[For any shape that DOES NOT
	define it's own anchor point,
	this will be the default anchor
	point for that shape. Keep in
	mind, that some shapes do define
	their own anchor point and, in
	that case, this default will
	not	be used.]]
constant("SHAPE_ANCHOR_DEFAULT",		SHAPE_ANCHOR_CENTROID);

--static entities and generators
lists 		= require(rStatic			..".lists"); --TODO change this a less common name!
name 		= require(rGenerators		..".name"); --TODO change this a less common name!

--classes (geometry)
point 		= require(rClassesGeometry	..".point");
line 		= require(rClassesGeometry	..".line");
shape 		= require(rClassesShapes	..".shape");
circle 		= require(rClassesShapes	..".circle");
polygon		= require(rClassesShapes	..".polygon");
hexagon		= require(rClassesShapes	..".hexagon");
rectangle 	= require(rClassesShapes	..".rectangle");
triangle	= require(rClassesShapes	..".triangle");

--classes (component)
pot 		= require(rClassesComponent	..".pot");
protean 	= require(rClassesComponent	..".protean");

--classes (other)
--action 	= require(rClasses			..".action");
--bank 		= require(rClasses			..".bank");
--combator 	= require(rClasses			..".combator");
iota 		= require(rClasses			..".iota");
targetor	= require(rClasses			..".targetor");
aStar		= require(rClasses			..".aStar");
--useful if using CoG as a dependency in multiple modules to prevent the need for loading multilple times
constant("COG_INIT", true);
