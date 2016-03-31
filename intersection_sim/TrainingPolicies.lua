-- Sample Policies
require 'Behaviors' -- v_max, v_min, makeTurn, driveStraight
require 'torch'

local acc_levels = require 'Actions'

local trainingPolicies = torch.class('TrainingPolicies')

function trainingPolicies:__init(options)
	self.behaviors = Behaviors(options)
end

-- a ~ pi(s)
function trainingPolicies:computeAction(egoVehicleBhv, obsVehicleBhv, state, time, isCollisionPolicy)
	local egoAcc = 0
	local egoPsi = 0
	local obsAcc = 0
	local obsPsi = 0
	local collisionFlag = 0
	local doneTurning = false

	if egoVehicleBhv == 3 and obsVehicleBhv == 5 then

		if time > 250 then
			obsAcc, obsPsi = self.behaviors:makeTurn(OBSTACLE, state, acc_levels.GO, "left", "main")
		end

		if isCollisionPolicy then	-- collision
			egoAcc, egoPsi = self.behaviors:makeTurn(EGO, state, acc_levels.GO, "left", "side")			
		else
			if time < 250 then
				egoAcc, egoPsi = self.behaviors:makeTurn(EGO, state, acc_levels.GO, "left", "side")
			elseif time >= 250 and time < 600 then
				egoAcc, egoPsi, collisionFlag = self:avoidCollision(state)
			else
				egoAcc, egoPsi = self.behaviors:makeTurn(EGO, state, acc_levels.GO, "left", "side")
				
				if doneTurning then
					egoAcc, egoPsi = self.behaviors:driveStraight(EGO, state, acc_levels.NONE)
				end
			end		
		end

	elseif egoVehicleBhv == 1 and obsVehicleBhv == 5 then
		obsAcc, obsPsi = self.behaviors:makeTurn(OBSTACLE, state, acc_levels.GO, "left", "main")

		if isCollisionPolicy then
			egoAcc, egoPsi = self.behaviors:driveStraight(EGO, state, acc_levels.GO)
		else
			if time >= 0 and time < 450 then
				egoAcc, egoPsi, collisionFlag = self:avoidCollision(state)
			else
				egoAcc, egoPsi = self.behaviors:driveStraight(EGO, state, acc_levels.GO)
			end
		end
	elseif egoVehicleBhv == 5 and obsVehicleBhv == 2 then
		if time > 200 then
			obsAcc, obsPsi = self.behaviors:driveStraight(OBSTACLE, state, acc_levels.GO)
		end

		if isCollisionPolicy then
			if time > 200 then
				egoAcc, egoPsi = self.behaviors:makeTurn(EGO, state, acc_levels.GO, "left", "main")
			end
		else
			if time >= 500 and time < 550 then
				egoAcc, egoPsi, collisionFlag = self:avoidCollision(state)
			elseif time > 200 and time < 500 then
				egoAcc, egoPsi = self.behaviors:makeTurn(EGO, state, acc_levels.GO, "left", "main")
			else 
				egoAcc, egoPsi = self.behaviors:makeTurn(EGO, state, acc_levels.GO, "left", "main")
			end	
		end
	elseif egoVehicleBhv == 2 and obsVehicleBhv == 5 then
		if time > 200 then
			obsAcc, obsPsi = self.behaviors:makeTurn(OBSTACLE, state, acc_levels.GO, "left", "main")
		end

		if isCollisionPolicy then
			egoAcc, egoPsi = self.behaviors:driveStraight(EGO, state, acc_levels.GO)
		else
			if time >= 300 and time < 500 then
				egoAcc, egoPsi, collisionFlag = self:avoidCollision(state)
			elseif time <= 700 then
				egoAcc, egoPsi = self.behaviors:driveStraight(EGO, state, acc_levels.GO)				
			elseif time > 700 then
				egoAcc, egoPsi = self.behaviors:driveStraight(EGO, state, acc_levels.NONE)
			end
		end
	elseif egoVehicleBhv == 5 and obsVehicleBhv == 1 then
		obsAcc, obsPsi = self.behaviors:driveStraight(OBSTACLE, state, acc_levels.GO)

		if isCollisionPolicy then
			egoAcc, egoPsi = self.behaviors:makeTurn(EGO, state, acc_levels.GO, "left", "main")
		else
			if time < 300 then
				egoAcc, egoPsi, collisionFlag = self:avoidCollision(state)
			else
				egoAcc, egoPsi = self.behaviors:makeTurn(EGO, state, acc_levels.GO, "left", "main")
			end
		end
	end	

	return {
		egoVehicle = { acc = egoAcc, psi = egoPsi },
		obstacleVehicle = { acc = obsAcc, psi = obsPsi } }, collisionFlag
end

function trainingPolicies:avoidCollision(state)
	egoAcc, egoPsi = self.behaviors:driveStraight(EGO, state, acc_levels.BRAKE)
	return egoAcc, egoPsi, 1
end