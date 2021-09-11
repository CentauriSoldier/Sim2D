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
		<li><p><strong>queue</strong><br>A basic queue class with obligatory methods.</p></li>
		<li><p><strong>stack</strong><br>A basic stack class with obligatory methods.</p></li>
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
@version 0.4
@versionhistory
<ul>
	<li>
		<b>0.1</b>
		<br>
		<p>Compiled various modules into CoG.</p>
		<b>0.2</b>
		<br>
		<p>Added the class module (create by Bas Groothedde).</p>
		<p>Added several classes.</p>
		<b>0.3</b>
		<br>
		<p>Created an init module to allow for a single require call to CoG which loads all desired modules</p>
		<b>0.4</b>
		<br>
		<p>Removed the class module (as well other commonly-used Lua libraries) and ported them to a new project. Added CoG's dependency on said project.</p>
	</li>
</ul>
@website https://github.com/CentauriSoldier/CoG
*]]
local rStatic 			= "static";
local rGenerators		= "static.generators";
local rClasses 			= "classes";
local rClassesAudio 	= "classes.audio";
local rClassesComponent	= "classes.component";
local rClassesGeometry	= "classes.geometry";
local rClassesShapes	= "classes.geometry.shapes";

--warn the user if debug is missing
assert(type(debug) == "table", "CoG requires the debug library during initialization. Please enable the debug library before initializing CoG.");

--determine the call location
local sPath = debug.getinfo(1, "S").source;
--remove the calling filename
sPath = sPath:gsub("@", ""):gsub("init.lua", "");
--remove the "/" at the end
sPath = sPath:sub(1, sPath:len() - 1);
--format the path to be suitable for the 'require()' function
sPath = sPath:gsub("\\", "."):gsub("/", ".");

local function import(sFile)
	return require(sPath..'.'..sFile);
end

if not(LUAEX_INIT) then
	import("LuaEx.init");
	LUAEX_INIT = true;
end

--warn the user if LuaEx is missing
assert(type(LUAEX_INIT) == "boolean" and LUAEX_INIT, "CoG requires the LuaEx library during initialization. Please include and load the LuaEx library before initializing CoG.");

--static entities
lists 		= import(rStatic	..".lists"); --TODO change this a less common name!
name 		= import(rGenerators..".name"); --TODO change this a less common name!

--classes (geometry)
point 		= import(rClassesGeometry	..".point");
line 		= import(rClassesGeometry	..".line");
shape 		= import(rClassesShapes		..".shape");
circle 		= import(rClassesShapes		..".circle");
hex 		= import(rClassesShapes		..".hex");
rectangle 	= import(rClassesShapes		..".rectangle");
triangle	= import(rClassesShapes		..".triangle");

--classes (component)
pot 		= import(rClassesComponent..".pot");
protean 	= import(rClassesComponent..".protean");
stack 		= import(rClassesComponent..".stack");
queue 		= import(rClassesComponent..".queue");

--classes (other)
--action 		= import(rClasses.."action");
--bank 		= import(rClasses.."bank");
--combator 	= import(rClasses.."combator");
iota 		= import(rClasses..".iota");
--targetor	= import(rClasses.."targetor");

--useful if using CoG as a dependency in multiple modules to prevent the need for loading multilple times
COG_INIT = true;
