--[[ Copyright 2014 Google Inc.
This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
]]

--[[ Game class that provides an interface for Love2D
In general, you would want to use:
    love.game(gamename)
]]

require 'torch'
local game = torch.class('Game')
require 'paths'


--[[
Parameters:
 * `options`  (table) - a table of options
Where `options` has the following keys:
 * `useRGB`   (bool) - true if you want to use RGB pixels.
]]
function game:__init(options)
    options = options or {}

    self.name = gamename
   
    self.observations = self._newScreenshot(true);
    self.action = {torch.Tensor{0}}

    -- setup initial observations by playing a no-action command
    self:saveState()
    local x = self:play(0)
    self.observations = x.data
    self:loadState()
end

--TODO
function game:game_over()
    return false
end

function game:stochastic()
    return false
end


function game:shape()
    return self.observations[1]:size():totable()
end


function game:nObsFeature()
    return torch.prod(torch.Tensor(self:shape()),1)[1]
end


function game:saveState()
    --Store state of game momentarily
end


function game:loadState()
    --Load most recent save state
end


function game:actions()
    --Return actions as a table
end

--[[
Parameters:
 * `action` (int [0-17]), the action to play
Returns a table containing the result of playing given action, with the
following keys:
 * `reward` - reward obtained
 * `data`   - observations
 * `pixels` - pixel space observations
 * `terminal` - (bool), true if the new state is a terminal state
]]
function game:play(action)
    action = action or 0
    self.action[1][1] = action

    -- take the step in the environment

    -- apply the action
    local step_result = self._stepSimulation(self.action)
    local pixels = self._newScreenshot(true);
    
    local is_game_over = self.game_over(reward)

    local data = pixels
    local gray = pixels

    --[[if self.useRGB then
        data = self.env:getRgbFromPalette(pixels)
        pixels = data
    end --]]

    return {reward=reward, data=data, pixels=pixels,
            terminal=is_game_over, gray=gray}
end

function game:_stepSimulation(action)
    return 1
end

function game:getState()
    return self.env:saveSnapshot()
end


function game:restoreState(state)
    self.env:restoreSnapshot(state)
end