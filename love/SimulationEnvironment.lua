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

	self.verticalStreetStart = opt.blockWidth
	self.verticalStreetEnd = (opt.blockWidth + opt.roadWidth)

	self.horizontalStreetStart = ((opt.sceneLength-opt.roadWidth)/2)
	self.horizontalStreetEnd = (((opt.sceneLength-opt.roadWidth)/2) + opt.roadWidth)

	self.roadWidth = opt.roadWidth
	self.sceneLength = opt.sceneLength
	self.sceneWidth = 2 * opt.blockWidth + opt.roadWidth
	self.offset = (0.33 * opt.blockWidth)
	self.edgeBoundary = 6
end

function environment:draw()
	self.lowerLeftBlock:draw('fill')
	self.upperLeftBlock:draw('fill')
	self.farRightBlock:draw('fill')
end

function environment:reward(egoVehicle, obstacleVehicle, actions)
	if egoVehicle:collidesWith(obstacleVehicle) then
		print("Collision with obstacle vehicle!")
	end

	if self:crash(egoVehicle) then
	end
	return 0, false
end

function environment:getScenario(idx) 
	if idx == 1 then
		return self:scenario1()
	elseif idx == 2 then
		return self:scenario2()
	end
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
	if gt(position[1], self.edgeBoundary) and 
		lt(position[1], self.sceneWidth - self.edgeBoundary) and
		gt(position[2], self.edgeBoundary) and
		 lt(position[2], self.sceneLength - self.edgeBoundary) and
		 not self:crash(vehicle) then
		 		return true
	else
		return false
	end
end
--####################################
--Scenarios
--####################################

-- Ego vehicle positioned at bottom of road
-- Obstacle vehicle at side road
function environment:scenario1()
	self.terminatingConditions = {} -- TODO

	return 
	{
		{	-- Ego vehicle
			self.verticalStreetStart + (0.6 * self.roadWidth),
			self.sceneLength - (3 * self.offset),
			math.pi,
			0
		}, 
		{	-- Obstacle vehicle
			self.offset,
			self.horizontalStreetStart + (0.7 * self.roadWidth),
			math.pi/2,
			0
		}
	}	
end

-- Ego vehicle starts at the top of the scene and drives down
function environment:scenario2()
	self.terminatingConditions = {}

	return 
	{
		{	-- Ego vehicle
			self.verticalStreetStart + (0.25 * self.roadWidth),
			self.offset,
			0,
			1
		}, 
		{	-- Obstacle vehicle
			self.offset,
			self.horizontalStreetStart + (0.5 * self.roadWidth),
			math.pi/2,
			0
		}
	}
end