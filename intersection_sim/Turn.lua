-- Turn behavior policies

require 'Util'
require 'torch'

local turn = torch.class('Turn')

function turn:__init(opt)
	self.dt = opt.dt
	self.turnData = {
		right = {
			main = {
				r = 1,
				xc = 20,
				yc = 55.5,	
				maxSteeringAngle = 1,
				spinDirection = -1
			}, 
			side = {
				r = 1,
				xc = 20, 
				yc = 44.5,
				maxSteeringAngle = -1,
				spinDirection = -1
			}
		},

		left = {
			main = {
				r = 1,
				xc = 20,
				yc = 55.5,
				maxSteeringAngle = 0.4,
				spinDirection = 1
			},
			side = {
				r = 1,
				xc = 20,
				yc = 55.5,
				maxSteeringAngle = 0.4,
				spinDirection = 1
			}
		} 
	}
end

-- this function computes a collection of psi values
-- that commands the vehicle to turn right onto the main road
-- acc = 0 for turns
function turn:turnVehicle(vehicle, vehicleState, direction, road)
	local x = vehicleState[1 + vehicle][1]
	local y = vehicleState[2 + vehicle][1]
	local theta = vehicleState[3 + vehicle][1]
	local v = vehicleState[4 + vehicle][1]

	local r 	= self.turnData[direction][road].r
	local xc 	= self.turnData[direction][road].xc
	local yc 	= self.turnData[direction][road].yc
	local maxSteeringAngle = self.turnData[direction][road].maxSteeringAngle
	local spinDirection = self.turnData[direction][road].spinDirection

	if direction == "right" and road == "main" then 
		if x - xc < 0 then
			return 0, false
		elseif near(math.abs(theta), 0, 0.01) then
			return 0, true
		end
	elseif direction == "right" and road == "side" then 
		if y - yc < 0 then 
			return 0, false
		elseif near(math.abs(theta), math.pi/2, 0.01) then
			return 0, true
		end 
	elseif direction == "left" and road == "side" then
		if y - yc > 0 then 
			return 0, false
		elseif near(math.abs(theta), 3 * math.pi / 2, 0.01) then
			return 0, true 
		end
	elseif direction == "left" and road == "main" then
		if x - xc < 0 then 
			return 0, false
		elseif near(math.abs(theta), math.pi, 0.01) then
			return 0, true
		end
	end

	local d 	= v * self.dt
	local dx 	= (x - xc) / r

	dx = clamp(dx, -1, 1)

	local theta_c = math.acos(dx)
	local theta_d = theta_c + (d / r)

	local ref = torch.Tensor({xc + r * math.sin(theta_d), yc + r * math.cos(theta_d)})

	local psi = radsLimit(math.atan(ref[2] - y, ref[1] - x))

	psi = clamp(psi, -maxSteeringAngle, maxSteeringAngle)

	return spinDirection * psi, false
end

