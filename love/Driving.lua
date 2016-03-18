-- Assortment of driving behaviors
-- All functions return an acc (all have psi 0 except turning)

require 'torch'
require 'Util'

local driving = torch.class('Driving')

function driving:__init(opt)
	self.dt = opt.dt
	self.braking = { HARD = 4, REGULAR = 2, NONE = 1}
	self.speeds = {SPEEDING = 10, NORMAL = 5, SLOW = 1, STOPPED = 0}


function driveStraight(v_current, v_desired, braking_level)
	local acc = (v_desired - v_current) / self.dt

	if (acc <= 0) then 
		acc = acc * braking_level
	end

	acc = clamp(acc, -4, 4)

	return acc, 0
end