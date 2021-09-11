--[[*
@moduleid combator
@authors Centauri Soldier
@copyright Copyright © 2020 Centauri Soldier
@description <h2>combator</h2><h3>Handles all non-targeting aspect of attack and defense.</h3>
<h3>Implementation must set the following constants:</h3>
<ul>
	<li>COMBATOR <em>(constant type)</em></li>
	<li>COMBATOR.TO_HIT_MIN <em>(number)</em></li>
	<li>COMBATOR.TO_HIT_MAX <em>(number)</em></li>
	<li>COMBATOR.HIT_EVADE_MIN <em>(number)</em></li>
	<li>COMBATOR.HIT_EVADE_MAX <em>(number)</em></li>
	<li>COMBATOR.DAMAGE_REDUX_MIN <em>(number)</em></li>
	<li>COMBATOR.DAMAGE_REDUX_MAX <em>(number)</em></li>
</ul>
<h3>The following callback functions may be defined by the implementation:</h3>
<ul>
	<li></li>
	<li></li>
	<li></li>
	<li></li>
	<li></li>
	<li></li>
	<li></li>
</ul>
@version 0.1
*]]
assert(type(const) 		== "function", "const has not been loaded.");
assert(type(protean)	== "function", "protean has not been loaded.");

COMBATOR 					= const("COMBATOR", "This is the main combator const category.", true);
COMBATOR.TO_HIT_MIN			= 0;
COMBATOR.TO_HIT_MAX			= 1;
COMBATOR.HIT_EVADE_MIN		= 2;
COMBATOR.HIT_EVADE_MAX		= 3;
COMBATOR.DAMAGE_REDUX_MIN	= 4;
COMBATOR.DAMAGE_REDUX_MAX	= 5;

local tCombator = {

	Check = function(oCombator)

	end

};



class "combator" {

	--[[!
	@module combator
	@func combator
	@scope local
	@desc The constructor for the combator class.
	!]]
	__construct = function(this)

		tCombator[this] = {
			dot			= {
				attack 	= protean(),
				defense = protean(),
			},
			ap			= {
				current  = protean(),
				recharge = protean(),
			},
			evade	 	= protean(),
			hp			= protean(),
			mp			= protean(),
			toHit 		= protean(),
		};

		for _, sDOTType in pairs(DOTTYPE()) do
			tCombator[this].dot[sDOTType] 		= pool();
			tCombator[this].dotRedux[sDOTType]	= pool();
		end

	end,


	__lt = function(oThis, oOther)
		oMe		= tCombator[oThis];
		oThem 	= tCombator[oOther];
	end,

};

function combator:dot(...)
	AAA.CheckCount("combator", "DOT", arg, 1);
	local sDOTType = AAA.CheckTypes("combator", "DOT", arg, 1, {"string"});
	--assert(DOTTYPE.isMyType(sDOTType), "Error in combator:DOT(): not a DOT type.");
	return tCombator[self].dot[sDOTType];
end

function combator:dotRedux()
	AAA.CheckCount("combator", "DOTRedux", arg, 1);
	local sDOTType = AAA.CheckTypes("combator", "DOTRedux", arg, 1, {"string"});
	--assert(DOT.IsMyType(sDOTType), "Error in combator:DOTRedux(): not a DOT type.");
	return tCombator[self].dotRedux[sDOTType];
end

function combator:ep()
	return tCombator[self].ep;
end

function combator:evade()
	return tCombator[self].evade;
end

function combator:hp()
	return tCombator[self].hp;
end

function combator:toHit()
	return tCombator[self].toHit;
end
