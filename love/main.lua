require 'Simulator'
require 'SimulationEnvironment'
require 'Turn'
require 'Driving'

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
	dt=1/100
}

local env = SimulationEnvironment(options)
local sim = Simulator(options, env)
local driver = Driving({dt = 0.001})
local simTime = 10000
local count = 1
--local policy = torch.zeros(4 * options.trajectoryLength, 4)
-- set accel for the first steps
--policy[{ 1, 1 }] = 1 -- m/s^2
--policy[{ 1, 3 }] = 1 -- m/s^2


function love.load()
    love.window.setMode(options.scale * options.envWidth, options.scale * options.envHeight, {resizable=false, vsync=false})
end

function love.update(dt)
	count = count + 1

	if count < simTime then

		-- local actions = policy[math.floor(idx)]
		local currentState = sim:state()
		-- local acc, psi = turn(currentState[1][1], currentState[2][1], currentState[3][1], currentState[4][1], actions[1] * options.dt, "left", "side", options.dt)
		-- actions[2] = psi
		-- local acc, psi = turn(currentState[5][1], currentState[6][1], currentState[7][1], currentState[8][1], actions[3] * options.dt, "left", "main", options.dt)
		-- actions[4] = psi

		if count < 100 then
			local acc1, ps1 = driver:driveStraight(currentState[4][1], 8, 1)
			actions = torch.Tensor({acc1, ps1, 0, 0})
		else 
			local acc1, ps1 = driver:driveStraight(currentState[4][1], 0, 1)
			actions = torch.Tensor({acc1, ps1, 0, 0})
		end	
				
		local reward, isTerminal = sim:step(actions)
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