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


-- This file defines the alewrap.GameScreen class.

--[[ The GameScreen class is designed to efficiently combine a fixed number
of consecutive images of identical dimensions coming in a sequence

Several Atari games (e.g. Space Invaders, Ms. Pacman, Alien, etc.) contain
blinking sprites, or important game objects which are drawn every other frame
for technical reasons (e.g. asteroids in the eponymous game). Using single
frames as state, even when sampled at a fixed interval, can miss many such
elements, with possibly severe consequences during gameplay (e.g. bullets
blink in most games). Pooling over consecutive frames reduces the risk of
missing such game elements.

The GameScreen class allows users to `paint` individual frames on a simulated
screen and then `grab` the mean/max/etc of the last N painted frames. The
default configuration will return the mean over the last two consecutive frames.
]]
local gameScreen = torch.class('alewrap.GameScreen')


-- Create a game screen with an empty frame buffer.
function gameScreen:__init(_params, _gpu)
    self:reset(_params, _gpu)
end


--[[ Clear frame buffer without releasing storage.

New input frames must have the same dimensions as first inputs.

This method is faster than calling `reset`, which incurs an extra, one-off
cost for reallocating storage, but allows frames with a different dimension to
be used.
]]
function gameScreen:clear()
    if self.frameBuffer then
        self.frameBuffer:zero()
    end
    self.lastIndex  = 0
    self.full       = false
end


--[[ Reset frame buffer settings and release storage.

New input frames must be of the same shape, but that needs not be the same
with dimensions of previous inputs. The screen can also be switched to
use CPU/GPU operations.

Calling `reset` incurs a one-off cost for reallocating storage. If new input
frames will have the same dimension and the same type of CPU/GPU operations
will be used, then it is faster to call `clear` instead of `reset`.
]]
function gameScreen:reset(_params, _gpu)
    self.frameBuffer= nil
    self.poolBuffer = nil
    self.lastIndex  = 0
    self.full       = false
    self.poolFun    = nil
    -- preserve old settings with default reset (no parameters specified)
    self.gpu        = self.gpu          or _gpu
    -- new parameters take precedence
    if _params then
        self.bufferSize = _params['size'] or self.bufferSize
        self.poolType   = _params['type'] or self.poolType
    end
    --- old parameters take precedence over defaults
    self.bufferSize = self.bufferSize   or 2
    self.poolType   = self.poolType     or 'mean'
    self.gpu        = self.gpu          or -1
end


-- Use the frame buffer to capture screen.
function gameScreen:grab()
    assert(self.lastIndex >= 1)
    if self.full then
        self.poolBuffer = self.poolBuffer or
                            self.poolFun(self.frameBuffer, 1):clone()
        self.poolFun(self.poolBuffer, self.frameBuffer, 1)
        return self.poolBuffer
    end
    self.poolBuffer = self.poolBuffer or
            self.poolFun(self.frameBuffer[{{1, self.lastIndex}}], 1):clone()
    self.poolFun(self.poolBuffer, self.frameBuffer[{{1, self.lastIndex}}], 1)
    return self.poolBuffer
end


-- Adds a frame at the top of the buffer.
function gameScreen:paint(frame)
    assert(frame)
    if not self.frameBuffer then
        --- set up frame buffer
        local dims = torch.LongStorage{self.bufferSize,
                                       unpack(frame:size():totable())}
        -- using static tensor storage instead of a
        -- queue for performance reasons (~10x faster on GPUs)
        if self.gpu and self.gpu >= 0 then
            self.frameBuffer = torch.CudaTensor(dims)
        else
            self.frameBuffer = torch.FloatTensor(dims)
        end
        self:clear()
        --- set pooling function
        self.poolFun = getmetatable(self.frameBuffer)[self.poolType]
        assert(self.poolFun, 'Could not get pooling function from metatable of ' ..
                                torch.typename(self.frameBuffer))

    end
    self.lastIndex = (self.lastIndex + 1) % (self.bufferSize + 1)
    if self.lastIndex == 0 then
        self.lastIndex = 1
        self.full = true
    end
    self.frameBuffer[self.lastIndex]:copy(frame):div(255)
end