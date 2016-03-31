require 'Simulator'
require 'SimulationEnvironment'
require 'TrainingPolicies'

local options = {
	scenario=4,
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
	positionVariance=1,
	dt=1/40 -- don't change this!
}

local env = SimulationEnvironment(options)
local scenario = env:getScenario(true, options.scenario)
local sim = Simulator(options, env)
local policies = TrainingPolicies(options)
local simTime = 10000
local count = 1
local doCollisionPolicy = false

function love.load()
    love.window.setMode(options.scale * options.envWidth, options.scale * options.envHeight, {resizable=false, vsync=false})
end

function love.update(dt)
	count = count + 1

	if count < simTime then

		local currentState = sim:state()

		actions, collisionFlag = policies:computeAction(
			scenario.egoVehicle.behavior,
			 scenario.obstacleVehicle.behavior,
			  currentState, count, doCollisionPolicy)
		
		local reward, isTerminal = sim:step(actions)

		if isTerminal then
			local newScenarioIdx = math.random(5)
			sim:reset(true, newScenarioIdx)
			--sim:reset(true, )

			if torch.bernoulli(0.5) == 1 then
				doCollisionPolicy = true
			else
				doCollisionPolicy = false
			end

			scenario = env:getScenario(true, newScenarioIdx)
			count = 1
		end
	else
		print('Done with sim')
	end
end

function love.draw()
    -- shapes can be drawn to the screen
    love.graphics.setColor(255,255,255)
    env:draw()

    love.graphics.setColor(255, 0, 0)
    sim:drawEgoVehicle()

    love.graphics.setColor(0, 0, 255)
    sim:drawObstacleVehicle()

end