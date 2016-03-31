-- Assortment of driving behaviors
-- All functions return an acc (all have psi 0 except turning)

require 'torch'
require 'Util'

local drive = torch.class('Drive')

function drive:__init(opt)
	self.dt = opt.dt
end

function drive:driveStraight(v_desired, v_current, accel)
	print(v_desired)
	print(v_current)

	local v_d = v_desired - v_current
	local acc = 0

	if not near(v_d, 0, 0.01) then
		if (v_d < 0) then 
			acc = -accel * self.dt
		elseif (v_d > 0) then
			acc = accel * self.dt
		end
	end

	return acc, 0
end

