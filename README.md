![](https://raw.githubusercontent.com/CentauriSoldier/Sim2D/main/Title.png)
# Sim2D
#### A 2D Game Framework for Autoplay Media Studio

----------
### What is Sim2D?
**Sim2D** is a gaming framework designed to make game creation with Autoplay Media Studio simple and fast. It allows for the quick and simple creation of custom objects which, without this framework, would require programming a new Object Plugin for each object a person wished to create.

**Sim2D Objects**

Using Sim2D, all you need to do is create a lua class file which inherits properties from the base (or other) object. You can create any object that you can imagine using built-in objects or your own, custom objects. An object can have several other objects inside it making it easy to create amalgamated objects. If this all sounds complicated, don't fret, it's not. In the provided examples, you can see how easy object creation really is.

**Object Template**

    local tMyObjects 	= {};

	local class 		= class;
	local tSim2D 		= Sim2D.__properties;
	local SIM2D 		= SIM2D;
	local Sim2D 		= Sim2D;



	class "MyObject" : extends(Sim2D) {

		__construct = function(this)
			--object settings
			tMyObjects[this] = {

			};

		end,

		Destroy = function(this)
			local tChildren = this:GetChildren();

			--destory all my children
			for x = 1, #tChildren do
				tChildren[x]:Destroy();
			end
	
			tMyObjects[this] 	= nil;
			this 				= nil;
		end,
	
		OnDraw = function(this)
	
		end,
	
		OnLButtonDown = function(this)
	
		end,
	
		OnLButtonUp = function(this)
	
		end,
	
		OnRButtonDown = function(this)
	
		end,
	
		OnRButtonUp = function(this)
	
		end,
	};
	
	return MyObject;

Using the Draw action plugin, these objects are drawn at run-time over an auto-managed "canvas" (an Input object with a specific name). The objects are drawn in layers so that UI objects show up on top. The objects have events and will soon have (optional) collision.

**Speed**

Besides that, custom object draws are significantly faster than Autoplay Media Studio's object draw, allowing for a real and practical pathway to creating games in AMS.   

**Feasible Game Types**

RPGs, Puzzle, Table-top-style, Text, Scroller, and their ilk.  

### What Sim2D is *NOT*
While Sim2D is great for the creating game types listed above (as well other such game types), it is not, nor ever will be, viable for making graphic-intense games such as 3D games, First Person Shooters, etc. The boon of being able to use AMS for creating games comes with limitations which cannot be overcome by this framework.  

### Plugin Requirements
 - AAA - [*download*](https://github.com/CentauriSoldier/AutoPlayMediaStudioPlugins)
 - Draw - [*download*](https://www.imagine-programming.com/package/ams8-plugins/draw-action-plugin-free.html)
 - GlobalPaths - [*download*](https://github.com/CentauriSoldier/AutoPlayMediaStudioPlugins)
 - Project - [*download*](https://github.com/CentauriSoldier/AutoPlayMediaStudioPlugins)

### Current Features
- Automatic fullscreen mode
- Auto-scaling of all build-time objects (whether AMS or Sim2D)
- App preserves build-time aspect ratio at run-time regardless of display resolution
- Custom object creation
- OOP-based class system for built-in and custom objects
- Makes Use of Autoplay Media Studio's WYSIWYG editor even for custom objects 
- Optional object **Pulse** action which allows for consistent, custom, timed events to occur on your objects (great for making LEDs, particle effects, moving images, etc.).
- Serialization/Deserialization methods great for saving/loading game data.  
- Declaration of object as UI, Game Object or Effect left to user discretion allowing for creation of many types of custom objects.
- Disabling of auto-draw and auto-poll for manual control (used for embedding objects within other objects) 
 
### Planned Features
 - Implementation of Tile maps (produced by the [TILED](https://www.mapeditor.org/) editor)
 - Object Collision
 - ListBox, Scrollbars and several other common objects
 - Factory Objects (for 'bullets' and other such things)
 - Zoom feature for canvas (does not affect UI objects) 

### How Can I Help?

You can help by forking and making pull request with your awesome improvements to this framework! Any little bit is appreciated. If you are known to me, you may also make a contributor request. I will not be accepting all requests but will accept requests from people with whom I am familiar and who have a good rep and a valid AMS license.

In addition, if you're using AMS and haven't yet got a license, please support Indigo Rose by purchasing a valid commercial license.   

----------
### License
##### Sim2D is Licensed under The Unlicense except where otherwise noted in individual files/modules.
