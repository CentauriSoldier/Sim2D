 --[[*
@authors Centauri Soldier
@copyright Public Domain
@description
	<h2>Sim2D/h2>
	<h3>A gaming, graphics framework of UI Components for AutoPlay Media Studio.</h3>
@email
@features
	<h3>Allows game creation in a, largely, WYSIWYG environment.</h3>
	<p>Uses the Draw Action Plugin (by Immagine Programming), CoG and LuaEx to make game creation in Autoplay Media Studio a reality.</p>
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
	<li></li>
</ul>
@moduleid cog|CoG
@todo
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
@website https://github.com/CentauriSoldier/Sim2D
*]]
--error(type(Project.GetDetails))
--warn the user if debug is missing
assert(type(debug) 		== "table", 												"Sim2D requires the debug library during initialization. Please enable the debug library before initializing Sim2D.");
assert(type(_ExeFolder) == "string" and Folder.DoesExist(_ExeFolder), 				"Sim2D requires the GlobalPaths plugin during initialization. Please enable the GlobalPaths plugin before initializing Sim2D.");
--assert(type(AMSPInfo) 	== "table", 												"Sim2D requires the AMSPInfo plugin during initialization. Please enable the AMSPInfo plugin before initializing Sim2D.");
assert(type(Canvas) 	== "table" 	and type(DrawingImage) 			== "table", 	"Sim2D requires the Draw plugin during initialization. Please enable the Draw plugin before initializing Sim2D.");
assert(type(Project) 	== "table" 	and type(Project.GetDetails) 	== "function", 	"Sim2D requires the Project plugin during initialization. Please enable the Project plugin before initializing Sim2D.");


local Project = Project;

--determine the call location
local sPath = debug.getinfo(1, "S").source;
--remove the calling filename
sPath = sPath:gsub("@", ""):gsub("[Ii][Nn][Ii][Tt].[Ll][Uu][Aa]", "");
--remove the "/" at the end
sPath = sPath:sub(1, sPath:len() - 1);
--format the path to be suitable for the 'require()' function
sPath = sPath:gsub("\\", "%."):gsub("/", "%.");

local function import(sFile)
	return require(sPath..'.'..sFile);
end

if not(COG_INIT) then
	import("CoG.init");
end

--warn the user if CoG is missing
assert(type(COG_INIT) == "boolean" and COG_INIT, "Sim2D requires the CoG library during initialization. Please include and load the CoG library before initializing Sim2D.");

--Sim2D constants
import("Constants");
--Sim2D enums
import("Enums");

--create the SIM2D and USER directories (if they don't exist)
local function createDirectories(eEnum)
	local tMeta = getmetatable(eEnum);

	--make this is an enum object
	if (type(tMeta) == "table" and type(tMeta["__call"]) == "function") then
		--TextFile.WriteFromString(_ExeFolder.."\\DIR TEST.txt", tostring(eEnum).."\r\n", true); TODO log this item

		for sName, vValue in eEnum() do
			local sType = vValue.valueType;

			if (sType == "string") then
				--TextFile.WriteFromString(_ExeFolder.."\\DIR TEST.txt", vValue.value.."\r\n", true);TODO log this item
				if not (Folder.DoesExist(vValue.value)) then
					Folder.Create(vValue.value);
				end

			else
				createDirectories(vValue);
			end

		end

	end

end

createDirectories(SIM2D.PATH.DIR);
createDirectories(SIM2D.PATH.USER.DIR);




---import the Sim2D base object and set the global properties table
Sim2D 				= import("Objects.Sim2D");
Sim2D.__properties 	= import("Properties");

--process the build data
					  import("Init.StoreBuildData");

--build the Sim2D ports
					  import("Init.PortsBuilder");

---import the Sim2D util functions
				  	  import("Functions.Util");

---import the Sim2D internal callback functions
				  	  import("Functions.InternalCallback");

--init the Sim2D base object
Sim2D.Init();

--import the Sim2D global event functions
				  	  import("Functions.Event");
--TODO ISN'T THIS DONE IN THE ENUMS?
--base objects
Ani 				= import("Objects.Ani");
Btn 				= import("Objects.Btn");
Prg 				= import("Objects.Prg");
LED 				= import("Objects.LED");
HexBtn 				= import("Objects.HexBtn");
CircleBtn 			= import("Objects.CircleBtn");
RectangleBtn 		= import("Objects.RectangleBtn");

--import the custom objects
local tCustomObjects = File.Find(SIM2D.PATH.USER.DIR.OBJECTS.value.."\\", "*.lua", false, false, nil, nil);

if (type(tCustomObjects) == "table" and #tCustomObjects > 0) then

	for x = 1, #tCustomObjects do
		local sRequirePath = tCustomObjects[x]:gsub(_Scripts.."\\", ""):sub(1, -5):gsub("\\", "%.");
		require(sRequirePath);
	end

end



--useful if using Sim2D as a dependency in multiple modules to prevent the need for loading it multilple times.
constant("SIM2D_INIT", true)
