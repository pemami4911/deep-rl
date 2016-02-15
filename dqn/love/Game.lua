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

--[[ Game class that provides an interface for the atari roms.
In general, you would want to use:
    alewrap.game(gamename)
]]

require 'torch'
local game = torch.class('Game')
require 'paths'


--[[
Parameters:
 * `gamename` (string) - one of the rom names without '.bin' extension.
 * `options`  (table) - a table of options
Where `options` has the following keys:
 * `useRGB`   (bool) - true if you want to use RGB pixels.
 * `useRAM`   (bool) - true if you want to use Atari ROM.
]]
function game:__init(gamename, options, roms_path)
    --[[options = options or {}

    self.useRGB   = options.useRGB
    self.useRAM   = options.useRAM

    self.name = gamename
    local path_to_game = paths.concat(roms_path, gamename) .. '.bin'
    local msg, err = pcall(alewrap.createEnv, path_to_game,
                           {enableRamObs = self.useRAM})
    if not msg then
        error("Cannot find rom " .. path_to_game)
    end
    self.env = err
    self.observations = self.env:envStart()
    self.action = {torch.Tensor{0}}

    self.game_over = function() return self.env.ale:isGameOver() end

    -- setup initial observations by playing a no-action command
    self:saveState()
    local x = self:play(0)
    self.observations[1] = x.data
    self:loadState()--]]
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
    self.env:saveState()
end


function game:loadState()
    return self.env:loadState()
end


function game:actions()
    return self.env:actions():storage():totable()
end


function game:lives()
    return self.env:lives()
end


--[[
Parameters:
 * `action` (int [0-17]), the action to play
Returns a table containing the result of playing given action, with the
following keys:
 * `reward` - reward obtained
 * `data`   - observations
 * `pixels` - pixel space observations
 * `ram`    - ram of the ATARI if requested
 * `terminal` - (bool), true if the new state is a terminal state
]]
function game:play(action)
    action = action or 0
    self.action[1][1] = action

    -- take the step in the environment

    -- apply the action
    local observations = self.env:envStep(self.action)
    
    local is_game_over = self.game_over(reward)

    local pixels = observations[1]
    local ram = observations[2]
    local data = pixels
    local gray = pixels

    if self.useRGB then
        data = self.env:getRgbFromPalette(pixels)
        pixels = data
    end

    return {reward=reward, data=data, pixels=pixels, ram=ram,
            terminal=is_game_over, gray=gray, lives=self:lives()}
end


function game:getState()
    return self.env:saveSnapshot()
end


function game:restoreState(state)
    self.env:restoreSnapshot(state)
end