--[[*
	@moduleid pool
	@authors Centauri Soldier
	@copyright Copyright © 2020 Centauri Soldier
	@description <h2>pool</h2><h3>Utility class used to keep track of things like Health, Magic, etc.</h3><p>You can operate on <strong>pool</strong> objects using some math operators.</p>
	<ul>
		<li><p><b>+</b>: adds a number to the pool's CURRENT value or, if adding another pool object instead of a number, it will add the other pool's CURRENT value to it's own <em>(up to it's MAX)</em> value.</p></li>
		<li><p><b>-</b>: does the same as addition but for subtraction. Will not go below the pool's MIN value.</p></li>
		<li><p><b>%</b>: will modify a pool's MAX value using a number value or another pool object <em>(uses it's MAX value)</em>. Will not allow itself to be set at or below the MIN value.</p></li>
		<li><p><b>*</b>: operates as expected on the object's CURRENT value.</p></li>
		<li><p><b>/</b>: operates as expected on the object's CURRENT value. All div is floored.</p></li>
		<li><p><b>-</b><em>(unary minus)</em>: will set the object's CURRENT value to the value of MIN.</p></li>
		<li><p><b>#</b>: will set the object's CURRENT value to the value of MAX.</p></li>
		<li><p><b></b></p></li>
		<li><p><b></b></p></li>
	</ul>
	@version 0.2
	@todo Complete the binary operator metamethods.
	*]]
	
	--[[!
	@module pool
	@func __construct
	@scope local
	@desc The constructor for the pool class.	
!]]
assert(type(CONST) == "function", "CONST has not been loaded.");

--set the constants for this class
POOL					= CONST("POOL");
POOL.CURRENT			= "Current";
POOL.MAX				= "Max";
POOL.MIN				= "Min";

POOL_CALLBACK			= CONST('POOL_CALLBACK');
POOL_CALLBACK.ON_ADD	= 'onAdd';
POOL_CALLBACK.ON_ALL	= 'onAll';
POOL_CALLBACK.ON_DIV	= 'onDiv';
POOL_CALLBACK.ON_MAX	= 'onMax';
POOL_CALLBACK.ON_MIN	= 'onMin';
POOL_CALLBACK.ON_MOD	= 'onMod';
POOL_CALLBACK.ON_MUL	= 'onMul';
POOL_CALLBACK.ON_SET	= 'onSet';
POOL_CALLBACK.ON_SUB	= 'onSet';



local tPool = {};

--[[local function callback(sEvent, oPool)
	
	if (type(oPool.callbacks[sEvent]) == 'function') then
		oPool.callbacks[sEvent](oPool);
	end

end]]

function check(...)
	local oPool 	= tPool[select(1, ...)];
	local sEvent 	= select(2, ...);
	--error(oPool.values[POOL.MAX])
	if (oPool.values[POOL.CURRENT] > oPool.values[POOL.MAX]) then
		oPool.values[POOL.CURRENT] = oPool.values[POOL.MAX];
	
	elseif (oPool.values[POOL.CURRENT] < oPool.values[POOL.MIN]) then
		oPool.values[POOL.CURRENT] = oPool.values[POOL.MIN];
	end
	
	if (oPool.values[POOL.MAX] <= oPool.values[POOL.MIN]) then
		oPool.values[POOL.MAX] = oPool.values[POOL.MIN] + 1;
	end
	
	--execute the callback if it exists
	if (type(oPool.callbacks[POOL_CALLBACK.ON_ALL]) == 'function') then
		oPool.callbacks[POOL_CALLBACK.ON_ALL](oPool);
	elseif (type(oPool.callbacks[sEvent]) == 'function') then
		oPool.callbacks[sEvent](oPool);
	end
	
end


function setValue(oPool, sValueType, nValue, sEvent)
	tPool[oPool].values[sValueType] = nValue;	
	check(oPool, sEvent);
end

class "pool" {
	
	__construct = function(...)
		local this = select(1, ...);
		
		tPool[this] = {
			callbacks 	= {},
			values 		= {},
		};
		
		--setup the callbacks		
		for _, sEvent in pairs(POOL_CALLBACK()) do			
			tPool[this].callbacks[sEvent] = nil;
		end
		
		
		--initialize the values
		local nID = 1;
		
		for _, sValue in pairs(POOL()) do
			nID = nID + 1;
			tPool[this].values[sValue] = select(nID, ...) or 0;
		end		
		
	end,
	
	
	--[[!
	@module pool
	@func __add
	@scope local
	@desc NOT DONE YET!	
	!]]
	__add = function(vLeft, vRight)
		local sLeftType 	= type(vLeft);
		local sRightType 	= type(vRight);
		local sPool 		= "pool";
		local oRet 			= nil;
				
		if (leftOnlyObject(sLeftType, sRightType, sPool)) then
			oRet = vLeft;
			setValue(vLeft, POOL.CURRENT, tPool[vLeft].values[POOL.CURRENT] + vRight, POOL_CALLBACK.ON_ADD);
						
		elseif (rightOnlyObject(sLeftType, sRightType, sPool)) then
			oRet = vRight;
			setValue(vRight, POOL.CURRENT, tPool[vRight].values[POOL.CURRENT] + vLeft, POOL_CALLBACK.ON_ADD);
						
		elseif (bothObjects(sLeftType, sRightType, sPool)) then
			oRet = vLeft;
			setValue(vLeft, POOL.CURRENT, tPool[vLeft].values[POOL.CURRENT] + tPool[vRight].values[POOL.CURRENT], POOL_CALLBACK.ON_ADD);
						
		end
		
		return oRet;
	end,
	
	
	__div = function(vLeft, vRight)
		local sLeftType 	= type(vLeft);
		local sRightType 	= type(vRight);
		local sPool 		= "pool";
		local oRet 			= nil;
				
		if (leftOnlyObject(sLeftType, sRightType, sPool)) then
			oRet = vLeft;
			setValue(vLeft, POOL.CURRENT, math.floor(tPool[vLeft].values[POOL.CURRENT] / vRight), POOL_CALLBACK.ON_DIV);
					
		elseif (rightOnlyObject(sLeftType, sRightType, sPool)) then
			oRet = vRight;
			setValue(vRight, POOL.CURRENT, math.floor(tPool[vRight].values[POOL.CURRENT] / vLeft), POOL_CALLBACK.ON_DIV);
			
		elseif (bothObjects(sLeftType, sRightType, sPool)) then
			oRet = vLeft;
			setValue(vLeft, POOL.CURRENT, math.floor(tPool[vLeft].values[POOL.CURRENT] / tPool[vRight].values[POOL.CURRENT]), POOL_CALLBACK.ON_DIV);
			
		end
		
		return oRet;
	end,
	
	__len = function(oThis)
		setValue(oThis, POOL.CURRENT, tPool[oThis].values[POOL.MAX], POOL_CALLBACK.ON_MAX);		
		return oThis;
	end,

	
	--[[!
	@module pool
	@func __mod
	@scope local
	@desc <p>Sets the pool object's MIN or MAX value depending on order.</p>
	<ul>
		<li><p>If the pool object is on the left and a number on the right, sets the object's MAX value to the indicated value.</p></li>
		<li><p>If the object is on the right and a number on the left, sets the MIN value to indicated number.</p></li>
		<li><p>If both sides are pool objects, it sets the MIN and MAX values of the left side object to the MIN and MAX values of that of the right object.</p></li>
	</ul>
	<p>Note: if the MAX is ever set below or equal to the MIN value, it will be automatically altered to be one higher than the MIN value.</p>
	!]]
	__mod = function(vLeft, vRight)
		local sLeftType 	= type(vLeft);
		local sRightType 	= type(vRight);
		local sPool 		= "pool";
		local oRet 			= nil;
				
		if (leftOnlyObject(sLeftType, sRightType, sPool)) then
			oRet = vLeft;
			setValue(vLeft, POOL.MAX, vRight, POOL_CALLBACK.ON_MOD);
			
		elseif (rightOnlyObject(sLeftType, sRightType, sPool)) then
			oRet = vRight;
			setValue(vRight, POOL.MIN, vLeft, POOL_CALLBACK.ON_MOD);
			
		elseif (bothObjects(sLeftType, sRightType, sPool)) then
			setValue(vLeft, POOL.MIN, tPool[vRight].values[POOL.MIN], POOL_CALLBACK.ON_MOD);
			setValue(vLeft, POOL.MAX, tPool[vRight].values[POOL.MAX], POOL_CALLBACK.ON_MOD);
			
		end
				
		return oRet;
	end,
	
	
	__mul = function(vLeft, vRight)
		local sLeftType 	= type(vLeft);
		local sRightType 	= type(vRight);
		local sPool 		= "pool";
		local oRet 			= nil;
				
		if (leftOnlyObject(sLeftType, sRightType, sPool)) then
			oRet = vLeft;
			setValue(vLeft, POOL.CURRENT, tPool[vLeft].values[POOL.CURRENT] * vRight, POOL_CALLBACK.ON_MUL);
			
		elseif (rightOnlyObject(sLeftType, sRightType, sPool)) then
			oRet = vRight;
			setValue(vRight, POOL.CURRENT, tPool[vRight].values[POOL.CURRENT] * vLeft, POOL_CALLBACK.ON_MUL);
			
		elseif (bothObjects(sLeftType, sRightType, sPool)) then
			oRet = vLeft;
			setValue(vLeft, POOL.CURRENT, tPool[vLeft].values[POOL.CURRENT] * tPool[vRight].values[POOL.CURRENT], POOL_CALLBACK.ON_MUL);
			
		end
		
		return oRet;
	end,

	
	__sub = function(vLeft, vRight)
		local sLeftType 	= type(vLeft);
		local sRightType	= type(vRight);
		local sPool 		= "pool";
		local oRet 			= nil;
				
		if (leftOnlyObject(sLeftType, sRightType, sPool)) then
			oRet = vLeft;
			setValue(vLeft, POOL.CURRENT, tPool[vLeft].values[POOL.CURRENT] - vRight, POOL_CALLBACK.ON_SUB);
			
		elseif (rightOnlyObject(sLeftType, sRightType, sPool)) then
			oRet = vRight;
			setValue(vRight, POOL.CURRENT, tPool[vRight].values[POOL.CURRENT] - vLeft, POOL_CALLBACK.ON_SUB);
			
		elseif (bothObjects(sLeftType, sRightType, sPool)) then
			oRet = vLeft;
			setValue(vLeft, POOL.CURRENT, tPool[vLeft].values[POOL.CURRENT] - tPool[vRight].values[POOL.CURRENT], POOL_CALLBACK.ON_SUB);
			
		end
		
		return oRet;
	end,
	
	
	__tostring = function(...)
		local oPool 	= tPool[select(1, ...)];
		local sRet 		= "";
		
		for _, sValue in pairs(POOL()) do
			sRet = sRet..sValue..': '..oPool.values[sValue]..' ';
		end 
		
		return sRet;
	end,
	
	
	__unm = function(oThis)
		local oPool = tPool[oThis];
		setValue(oThis, POOL.CURRENT, oPool.values[POOL.MIN], POOL_CALLBACK.ON_MIN)
		return oPool;
	end,
	
	
	get = function(...)
		local oPool 	= tPool[select(1, ...)];
		local sIndex 	= select(2, ...);
		local nRet 		= nil;
		
		if (sIndex and oPool.values[sIndex]) then
			nRet = oPool.values[sIndex];
		end
		
		return nRet or math.huge;
	end,
	
	
	copy = function(...)
		local oPool = tPool[select(1, ...)];
		local oRet = pool();
		
		for nID, sValue in pairs(POOL()) do		
			setValue(oRet, sValue, oPool.values[sValue]);
		end
		
		return oRet;
	end,
	
	set = function(...)
		local this 		= select(1, ...)
		local oPool 	= tPool[this];
		local sIndex 	= select(2, ...);
		local nValue 	= select(3, ...);
		
		if (sIndex and nValue and (type(nValue) == 'number') and oPool.values[sIndex]) then
			setValue(this, sIndex, nValue, POOL_CALLBACK.ON_SET);		
		end	
				
	end,
	
	setCallback = function(...)
		local this 		= select(1, ...);
		local sEvent	= select(2, ...);
		local fCallback = select(3, ...);
		
		if (sEvent and fCallback and type(sEvent) == 'string' and POOL_CALLBACK.isMyConst(sEvent) and type(fCallback) == 'function') then
			tPool[this].callbacks[sEvent] = fCallback;
		end
		
	end,
}