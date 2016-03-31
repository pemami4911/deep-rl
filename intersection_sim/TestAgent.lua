require 'Simulator'
require 'SimulationEnvironment'
require 'TrainingPolicies'

-- move this to command line opts
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
	numScenarios=3,
	dt=1/40
}

-- Reinforcement Learning case: 
-- 1. Uniformly choose start positions of both vehicles (not same position)
-- 2. Sample noise for start positions for ego and obstacle vehicle from standard normal
-- 3. Randomly select a legal behavior for obstacle vehicles
-- 4. Sample a wait time for the obstacle vehicle from exponential with param (1) ?
-- 5. for t in 1 to T: 
-- 		Update state of obstacle vehicles
-- 		Select action for ego vehicle -> do this 4 times and take highest freq action? 
-- 		terminal = simulator:step(action)
-- 		if not terminal 
-- 			continue
-- 		else
-- 			break
-- 6. collect terminal reward for backprop
-- 7. store experiences in experience bank
	
-- For pre-training will need to assemble a collection of hand-tuned policies between the vehicles
-- showing good and behavior behaviors
-- Don't need to enumerate and show every possible - overfitting! 20% of all possible scenarios is probably enough
 
local env = SimulationEnvironment(options)
local scenario = env:getScenario(options.scenario, true)
local sim = Simulator(options, env)
local policies = TrainingPolicies(options)
local runs = 1000
local time = 1
local runCount = 1

local doCollisionPolicy = false

while(true) do
	time = time + 1

	if runCount < runs then

		local currentState = sim:state()

		actions, collisionFlag = policies:computeAction(
			scenario.egoVehicleBehavior,
			 scenario.obstacleVehicleBehavior,
			  currentState, time, doCollisionPolicy)
		
		print(collisionFlag)

		local reward, isTerminal = sim:step(actions)

		if isTerminal then
			local newScenarioIdx = math.random(5)
			sim:reset(newScenarioIdx, true)
			--sim:reset(-1, true)

			if torch.bernoulli(0.5) == 1 then
				doCollisionPolicy = true
			else
				doCollisionPolicy = false
			end

			scenario = env:getScenario(newScenarioIdx, true)
			time = 1
			runCount = runCount + 1
		end
	else
		print('Done with sim')
	end
end

print("Finished test")