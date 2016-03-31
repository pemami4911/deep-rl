require 'torch'

local scenarios = torch.class('Scenarios')

function scenarios:__init(vehicleStartPositions, positionVariance)
	self.vehicleStartPositions = vehicleStartPositions
	self.positionVariance = positionVariance or 1

	self.legalBehaviors = 
	{
		north = {1, 4},
		south = {2, 3},
		east = {5, 6}
	}
end

-- Generate a scenario with info for 
-- both vehicles
function scenarios:getScenario()
	
	local egoVehicle = { pos, behavior, velocity }
	local obsVehicle = { pos, behavior, velocity }
	
	egoVehicle.pos, obsVehicle.pos = self:__getStartStates()
	egoVehicle.behavior, obsVehicle.behavior = self:__getLegalBehavior(egoVehicle.pos.location, obsVehicle.pos.location)
	egoVehicle.velocity = math.random(5) - 1	-- between 0 and 4
	obsVehicle.velocity = math.random(5) - 1 	-- between 0 and 4
	local terminatingCondition = self:__getTerminatingCondition(egoVehicle.behavior)

	return {egoVehicle, obsVehicle, terminatingCondition}
end	

function scenarios:__getStartStates()
	local startLocations = {"north", "south", "east"}
	local egoIdx = math.random(#startLocations)
	local egoVehicleStart = startLocations[egoIdx]
	table.remove(startLocations, egoIdx)
	local obstacleVehicleStart = startLocations[math.random(#startLocations)]

	-- add some noise to the start positions for variability

	local egoVehiclePos = 
	{
		location = egoVehicleStart,
		x = self.vehicleStartPositions[egoVehicleStart].x + torch.normal(0, positionVariance),
		y = self.vehicleStartPositions[egoVehicleStart].y + torch.normal(0, positionVariance),
		heading = self.vehicleStartPositions[egoVehicleStart].heading
	}

	local obsVehiclePos = 
	{
		location = obstacleVehicleStart,
		x = self.vehicleStartPositions[obstacleVehicleStart].x + torch.normal(0, positionVariance),
		y = self.vehicleStartPositions[obstacleVehicleStart].y + torch.normal(0, positionVariance),
		heading = self.vehicleStartPositions[obstacleVehicleStart].heading
	}

	return egoVehiclePos, obsVehiclePos
end

function scenarios:__getLegalBehavior(egoLocation, obsLocation)
	local egoVehicleBhv = self.legalBehaviors[egoLocation][math.random(2)]
	local obsVehicleBhv = self.legalBehaviors[obsLocation][math.random(2)]
	return egoVehicleBhv, obsVehicleBhv
end

function scenarios:__getTerminatingCondition(egoBhv)
	if egoBhv == 1 or egoBhv == 6 then
		return 2	-- end at south side
	elseif egoBhv == 2 or egoBhv == 5 then
		return 3 	-- end at north side
	elseif egoBhv == 3 or egoBhv == 4 then
		return 1	-- end at east side
	end
end