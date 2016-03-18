-- Turn behavior policies

require 'Util'
require 'torch'

local turnData = {
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

-- Alan's MATLAB implementation 
--
-- if turn == 4   %% Turn right onto main road
--    acc = 0;
--    r = 5;
--    xc = 2;
--    yc = 12;
--    d = V*dt + acc*dt^2;
--    dtheta = d/r;
--    dx = (X(2) - xc)/r;
--     if dx > 1
--        dx = 1;
--     elseif dx < -1
--        dx = -1;
--     end
--    theta_c = acos(dx);
--    theta_d2 = theta_c + dtheta;
--    ref = [xc + r*sin(theta_d2); yc + r*cos(theta_d2)];
-- end

-- this function computes a series of acc, psi pairs 
-- that commands the vehicle to turn right onto the main road
-- acc = 0 for turns
function turn(x, y, theta, v, acc, direction, road, dt)
	local r 	= turnData[direction][road].r
	local xc 	= turnData[direction][road].xc
	local yc 	= turnData[direction][road].yc
	local maxSteeringAngle = turnData[direction][road].maxSteeringAngle
	local spinDirection = turnData[direction][road].spinDirection

	if direction == "right" and road == "main" then 
		if x - xc < 0 or near(math.abs(theta), 0, 0.01) then
			return 0, 0
		end
	elseif direction == "right" and road == "side" then 
		if y - yc < 0 or near(math.abs(theta), math.pi/2, 0.01) then 
			return 0, 0
		end 
	elseif direction == "left" and road == "side" then
		if y - yc > 0 or near(math.abs(theta), 3 * math.pi / 2, 0.01) then 
			return 0, 0 
		end
	elseif direction == "left" and road == "main" then
		if x - xc < 0 or near(math.abs(theta), math.pi, 0.01) then 
			return 0, 0
		end
	end

	local d 	= v * dt
	local dx 	= (x - xc) / r

	dx = clamp(dx, -1, 1)

	local theta_c = math.acos(dx)
	local theta_d = theta_c + (d / r)

	local ref = torch.Tensor({xc + r * math.sin(theta_d), yc + r * math.cos(theta_d)})

	local psi = radsLimit(math.atan(ref[2] - y, ref[1] - x))

	psi = clamp(psi, -maxSteeringAngle, maxSteeringAngle)

	return 0, spinDirection * psi
end

