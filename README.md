![](https://raw.githubusercontent.com/CentauriSoldier/Sim2D/main/Title.png)
# Sim2D
#### A 2D Game Framework for Autoplay Media Studio

----------
### What is Sim2D?
**Sim2D** is a gaming framework designed to make game creation with Autoplay Media Studio simple and fast. It allows for the quick and simple creation of custom objects which, without this framework, would require programming a new Object Plugin for each object a person wished to create. Using Sim2D, all you need to do is create a lua class file which inherits properties from the base (or other) object.

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

  

### What Sim2D is *NOT*
While Sim2D is great for the creating game types listed above (as well other such game types), it is not, nor ever will be, viable for making graphic-intense games such as 3D games, First Person Shooters, etc. The boon of being able to use AMS for creating games comes with limitations which cannot be overcome by this framework.  

### Plugin Requirements
 - AAA - [*download*](https://github.com/CentauriSoldier/AutoPlayMediaStudioPlugins)
 - Draw - [*download*](https://www.imagine-programming.com/package/ams8-plugins/draw-action-plugin-free.html)
 - GlobalPaths - [*download*](https://github.com/CentauriSoldier/AutoPlayMediaStudioPlugins)
 - Project - [*download*](https://github.com/CentauriSoldier/AutoPlayMediaStudioPlugins)

### Current Features
- Automatic fullscreen mode
- Auto-scaling of all build-time objects
- App preserves build-time aspect ratio at run-time regardless of display resolution
- Custom object creation
- OOP-based class system for built-in and custom objects
- Makes Use of Autoplay Media Studio's WYSIWYG editor even for custom objects   
 
### Planned Features
 - Implementation of Tile maps (produced by the [TILED](https://www.mapeditor.org/) editor)
 - 



----------
### License
##### Sim2D is Licensed under The Unlicense except where otherwise noted in individual files/modules.
