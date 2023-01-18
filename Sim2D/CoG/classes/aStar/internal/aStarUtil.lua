return {
    clampNodeEntryCost = function(nValue)
	       local nRet 	= nValue 	>= ASTAR_NODE_ENTRY_COST_MIN and nValue or ASTAR_NODE_ENTRY_COST_MIN;
	   nRet 		= nValue 	<= ASTAR_NODE_ENTRY_COST_MAX and nValue or ASTAR_NODE_ENTRY_COST_MAX;
	   return nRet;--TODO should this be floored?
    end,
    mapDimmIsValid = function(nValue)
        return rawtype(nValue) 	== "number" and nValue	> 0 and nValue == math.floor(nValue);
    end,
    mapTypeIsValid = function(nType)
        return 	rawtype(nType) == "number" and
            (	nType == ASTAR_MAP_TYPE_HEX_FLAT 		or
                nType == ASTAR_MAP_TYPE_HEX_POINTED 	or
                nType == ASTAR_MAP_TYPE_SQUARE		    or
                nType == ASTAR_MAP_TYPE_HEX_TRIANGLE
            );
    end,
    isNonBlankString = function(vVal)
        return rawtype(vVal) == "string" and vVal:gsub("%s", "") ~= "";
    end,
    layersAreValid = function(tLayers)
    	local bRet = false;

    	if (rawtype(tLayers) == "table" and #tLayers > 0) then
    		bRet = true;

    		for k, v in pairs(tLayers) do

    			if ( rawtype(k) ~= "number" or not (rawtype(v) == "string" and v:gsub("5s", "") ~= "") ) then
    				bRet = false;
    				break;
    			end

    		end

    	end

    	return bRet;
    end,
    setupActualDecoy = function(tActual, tDecoy, sError)
    	setmetatable(tDecoy, {
    		__index = function(t, k)
    			return tActual[k] or nil;
    		end,
    		__newindex = function(t, k, v)
    			error(sError);
    		end,
    		__len = function()
    			return #tActual;
    		end,
    		__pairs = function(t)
    			return next, tActual, nil;
    		end
    	});
    end,
};
