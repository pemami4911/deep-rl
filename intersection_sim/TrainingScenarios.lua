require 'torch'

local trainingScenarios = torch.class('TrainingScenarios')

--Heading is measured such that pi rads is driving north, pi/2 rads is driving east,
-- 0 rads is driving south, and -pi/2 rads is driving west

-- TODO: refactor egoVehicleX to egoVehicle.X 

function trainingScenarios:__init(vehicleStartPositions)

	self.scenarios =
	{
		{
			-- egoVehicleX < this, is terminal
			-- ending at East side 
			terminatingCondition = 1,
			egoVehicle = 
			{
				x = vehicleStartPositions.south.x,
				y = vehicleStartPositions.south.y,
				heading = vehicleStartPositions.south.heading,
				velocity = 2,
				behavior = 3 -- turn left onto side road
			},
			obstacleVehicle = 
			{
				x = vehicleStartPositions.east.x,
				y = vehicleStartPositions.east.y,
				heading = vehicleStartPositions.east.heading,
				velocity = 0,
				behavior = 5 -- turn left onto main road
			}			
		}, -- Scenario 1
		{
			-- egoVehicleY > this, is terminal
			-- ending at South end
			terminatingCondition = 2,
			egoVehicle = 
			{
				x = vehicleStartPositions.north.x,
				y = vehicleStartPositions.north.y,
				heading = vehicleStartPositions.north.heading,
				velocity = 4,
				behavior = 1, -- Drive south
			},
			obstacleVehicle = 
			{
				x = vehicleStartPositions.east.x,
				y = vehicleStartPositions.east.y,
				heading = vehicleStartPositions.east.heading,
				velocity = 0,
				behavior = 5 -- turn left onto main road
			}			
		}, -- Scenario 2
		{
			-- EgoVehicleY < thisCondition, is terminal
			-- starting on side road, ending at north end
			terminatingCondition = 3,
			egoVehicle = 
			{
				x = vehicleStartPositions.east.x,
				y = vehicleStartPositions.east.y,
				heading = vehicleStartPositions.east.heading,
				velocity = 2,
				behavior = 5, -- turn left onto main road
			},
			obstacleVehicle = 
			{
				x = vehicleStartPositions.south.x,
				y = vehicleStartPositions.south.y,
				heading = vehicleStartPositions.south.heading,
				velocity = 2,
				behavior = 2 -- Drive north
			}			
		}, -- Scenario 3
						{
			-- Egovehicle driving north
			-- obstacle vehicle turns left onto main road
			-- egoVehicleY < this, is terminal
			terminatingCondition = 3,
			egoVehicle = 
			{
				x = vehicleStartPositions.south.x,
				y = vehicleStartPositions.south.y,
				heading = vehicleStartPositions.south.heading,
				velocity = 1,
				behavior = 2, -- drive north
			},
			obstacleVehicle = 
			{
				x = vehicleStartPositions.east.x,
				y = vehicleStartPositions.east.y,
				heading = vehicleStartPositions.east.heading,
				velocity = 0,
				behavior = 5 -- turn left onto main road
			}			
		}, -- Scenario 4
		{
			-- egoVehicleX < this, is terminal
			-- ending at East side 
			terminatingCondition = 3,
			egoVehicle = 
			{
				x = vehicleStartPositions.east.x,
				y = vehicleStartPositions.east.y,
				heading = vehicleStartPositions.east.heading,
				velocity = 1,
				behavior = 5, -- turn left onto main road
			},
			obstacleVehicle = 
			{
				x = vehicleStartPositions.north.x,
				y = vehicleStartPositions.north.y,
				heading = vehicleStartPositions.north.heading,
				velocity = 4,
				behavior = 1 -- Drive south
			}			
		} -- Scenario 5		
	} 
end

function trainingScenarios:getTrainingScenario(id)
	return self.scenarios[id]
end
