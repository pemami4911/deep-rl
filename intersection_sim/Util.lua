require 'torch'

-- return a boolean if the input tensor element is positve
function pos(t)
	return torch.any(torch.gt(t, 0))
end

-- overload torch.gt to return a boolean
function gt(x, y)
	return torch.any(torch.gt(x, y)) 
end

-- overload torch.lt to return a boolean
function lt(x, y)
	return torch.any(torch.lt(x ,y))
end

function clamp(val, low, high)
	if val > high then 
		val = high
	elseif val < low then
		val = low
	end
	return val
end

function radsLimit(rads)
	if rads > 2 * math.pi then
		rads = rads - 2 * math.pi
	elseif rads < 0 then 
		rads = rads + 2 * math.pi
	end
	return rads
end

function near(val, target, nearness)
	if math.abs(val - target) < nearness then 
		return true
	else 
		return false
	end
end