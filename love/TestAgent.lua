require 'Simulator'
require 'SimulationEnvironment'

local options = {
	scenario=1,
    scale=8,
    envWidth=51,
    envHeight=100,
	vehicleLength=4.8,
	vehicleWidth=1.82,
	wheelBase=2.74,
	roadWidth=11,
	blockWidth=20,
	sceneLength=100,
	trajectoryLength=100,
	numScenarios=3
}

local env = SimulationEnvironment(options)
local sim = Simulator(options, env)
local dt = 1000

local policy = torch.zeros(4 * options.trajectoryLength, 4)
policy[{ 1, 1 }] = 7/dt -- m/s^2
policy[{ 1, 3 }] = 7/dt -- m/s^2

local idx = 1

while(true) do
	if idx < policy:size(1) then
		local reward, isTerminal = sim:step(policy[idx])
		idx = idx + 1
	else
		break
	end
end

print("Finished test")