-- Different behavior policies for the vehicles 

-- Behavior key
-- 
-- 1. Drive south
-- 2. Drive north
-- 3. Turn left onto side road
-- 4. Turn right onto side road
-- 5. Turn left onto main road
-- 6. Turn right onto main road

require 'Util'
require 'torch'
require 'Drive'
require 'Turn'
local acc_levels = require 'Actions'

-- If the RL agent predicts that a collision 
-- is likely to occur, the desired velocity goes to v_min
-- until the agent deems it safe to proceed
v_max = 17.88 -- m/s  ~ 40 mph
v_min = 0
EGO = 0
OBSTACLE = 4

local behaviors = torch.class('Behaviors')

function behaviors:__init(opt)
	self.dt = opt.dt
	self.driver = Drive(opt)
	self.turning = Turn(opt) 
	-- Y value for when the car pulls level with the
	-- start of the side road when driving N/S
	self.sideRoadSouthStart = 55.5
	self.sideRoadNorthStart = 45.5
	self.mainRoadStart = 20
end

-- driving south and north are the same function call
function behaviors:driveStraight(vehicle, state, acc)
	local v_current = state[4 + vehicle]
	local acc_t, psi_t = self.driver:driveStraight(self:v(acc), v_current, acc)
	return acc_t, psi_t
end

-- set `vehicle` to 4 for obstacle vehicle and 0 for ego vehicle

function behaviors:makeTurn(vehicle, state, acc, turnDirection, road)
	local x = state[1 + vehicle]
	local y = state[2 + vehicle]
	local v = state[4 + vehicle]
	local acc_t = 0
	local psi_t = 0
	local diff = 0
	local doneTurning = false

	if turnDirection == "right" and road == "main" then 
		--diff = -(x - self.mainRoadStart)
		diff = -torch.csub(x, self.mainRoadStart)
	elseif turnDirection == "right" and road == "side" then 
		diff = y - self.sideRoadNorthStart
	elseif turnDirection == "left" and road == "side" then
		diff = y - self.sideRoadSouthStart
	elseif turnDirection == "left" and road == "main" then
		diff = -(x - self.mainRoadStart)
	end

	if diff > 0 then 
		acc_t, psi_t = self.driver:driveStraight(self:v(acc), v, acc)
	else 

		psi_t, doneTurning = self.turning:turnVehicle(vehicle, state, turnDirection, road)

		if doneTurning then
			acc_t, psi_t = self.driver:driveStraight(self:v(acc), v, acc_levels.NONE)
		end
	end

	return acc_t, psi_t
end

function behaviors:v(acc)
	if acc == acc_levels.GO or acc == acc_levels.NONE then
		return v_max
	else
		return v_min
	end
end