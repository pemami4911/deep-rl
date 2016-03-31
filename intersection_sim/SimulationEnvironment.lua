-- Patrick Emami

-- Environment - 100 m (H) x 51 m (W)

--XXXXs--|--sXXXX
--XXXXs--|--sXXXX
--XXXXs--|--sXXXX
--XXXXs--|--sXXXX
--sssss--|--sXXXX
---------|--sXXXX
---------|--sXXXX
--sssss--|--sXXXX
--XXXXs--|--sXXXX
--XXXXs--|--sXXXX
--XXXXs--|--sXXXX
--XXXXs--|--sXXXX
--
-- Dimensions
--
-- Lanes are 3.66 m each
-- Road shoulders are 1.83 m 
-- White striped lines are 0.15 m
-- 2-Lane road is ~11 m wide
-- 100 m long stretch, with side road about halfway
-- Env can be 20 + 11 + 20 = 51 m wide 

-- check for collisions
    --for shape, delta in pairs(HC.collisions(mouse)) do

require 'torch'
require 'Util'
require 'Scenarios'
local acc_levels = require 'Actions'

local HC = require 'HC'

local environment = torch.class("SimulationEnvironment")

-- store coordinates of non-navigable polygons

function environment:__init(opt)
	self.upperLeftBlock = HC.rectangle(0, 0, opt.scale * opt.blockWidth,
	 opt.scale * ((opt.sceneLength-opt.roadWidth)/2))
	
	self.lowerLeftBlock = HC.rectangle(0, opt.scale * (((opt.sceneLength-opt.roadWidth)/2) + opt.roadWidth),
	 opt.scale * opt.blockWidth, opt.scale * ((opt.sceneLength-opt.roadWidth)/2))
	
	self.farRightBlock = HC.rectangle(opt.scale * (opt.blockWidth + opt.roadWidth),
	 0, opt.scale * opt.blockWidth, opt.scale * opt.sceneLength)

	self.road = 
	{
		verticalStreetStart = opt.blockWidth,
		verticalStreetEnd = (opt.blockWidth + opt.roadWidth),
		horizontalStreetStart = ((opt.sceneLength-opt.roadWidth)/2),
		horizontalStreetEnd = (((opt.sceneLength-opt.roadWidth)/2) + opt.roadWidth),
		roadWidth = opt.roadWidth,
		sceneLength = opt.sceneLength,
		sceneWidth = 2 * opt.blockWidth + opt.roadWidth,
		offset = (0.33 * opt.blockWidth),
		edgeBoundary = 6
	}

	self.vehicleStartPositions = 
	{
		north = 
		{ 
			x = self.road.verticalStreetStart + (0.25 * self.road.roadWidth),
			y = self.road.offset,
			heading = 0
		},
		south = 
		{
			x = self.road.verticalStreetStart + (0.7 * self.road.roadWidth),
			y = self.road.sceneLength - self.road.offset,
			heading = math.pi
		},
		east = 
		{
			x = 2 * self.road.offset,
			y = self.road.horizontalStreetStart + (0.5 * self.road.roadWidth),
			heading = math.pi/2
		}
	}
	

	self.trainingScenarios = TrainingScenarios(self.vehicleStartPositions)

	self.scenarios = Scenarios(self.vehicleStartPositions, opt.positionVariance)

	self.terminatingConditions = 
	{
		self.road.offset, -- ego vehicle X < 
		self.road.sceneLength - self.road.offset, --ego vehicle Y >
		2 * self.road.offset -- ego vehicle Y < 
	}
end

function environment:draw()
	self.lowerLeftBlock:draw('fill')
	self.upperLeftBlock:draw('fill')
	self.farRightBlock:draw('fill')
end

function environment:reward(egoVehicle, obstacleVehicle, state, actions)
	if egoVehicle:collidesWith(obstacleVehicle) then
		print("Collision with obstacle vehicle!")
		return -1, true
	end

	if self:crash(egoVehicle) then
		print("Crashed into environment!")
		return -1, true
	end

	-- add penalty for false alarm ?
	-- add reward for braking ?
	
	if not self:isTerminal(state) then 
		return 0, false
	else 
		return 1, true
	end
end

function environment:setTerminalCondition(condition)
	self.tcIdx = condition
end

-- Checks if the vehicle crashed into one of the blocks
function environment:crash(vehicle)
	if vehicle:collidesWith(self.upperLeftBlock) or
		vehicle:collidesWith(self.lowerLeftBlock) or
		vehicle:collidesWith(self.farRightBlock) then
		return true
	else 
		return false
	end 
end

-- position is an (x, y) coordinate 
function environment:isValid(position, vehicle)
	if gt(position[1], self.road.edgeBoundary) and 
		lt(position[1], self.road.sceneWidth - self.road.edgeBoundary) and
		gt(position[2], self.road.edgeBoundary) and
		 lt(position[2], self.road.sceneLength - self.road.edgeBoundary) and
		 not self:crash(vehicle) then
		 		return true
	else
		return false
	end
end

-- Check the terminating conditions
function environment:isTerminal(egoVehicleState)
	if self.tcIdx == 1 then
		if lt(egoVehicleState[1], self.terminatingConditions[self.tcIdx]) then
			return true
		else 
			return false
		end
	elseif self.tcIdx == 2 then
		if gt(egoVehicleState[2], self.terminatingConditions[self.tcIdx]) then
			return true
		else 
			return false
		end
	elseif self.tcIdx == 3 then
		if lt(egoVehicleState[2], self.terminatingConditions[self.tcIdx]) then
			return true
		else 
			return false
		end
	end
end

function environment:getScenario(training, id)
	if training then
		return self.trainingScenarios:getTrainingScenario(id)
	else
		return self.scenarios:getScenario()
	end
end
