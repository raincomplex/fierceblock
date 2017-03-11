
local M = {}

local Core = require('tgm/core')
local Physics = require('tgm/physics')
local Gravity = require('tgm/gravity')
local Shift = require('tgm/shift')
local Lock = require('tgm/lock')
local Randomizer = require('pento/randomizer')
local PieceData = require('pento/pieces')

local function newmode()
   local mode = Object()
   
   function mode:update(game)
      self:call('update', game)
   end
   
   mode:add(Core)
   mode:add(Physics)
   mode:add(Gravity)
   mode:add(Shift)
   mode:add(Lock)
   mode:add(Randomizer)
   mode.piecedata = PieceData
   return mode
end

local function newgame(mode)
   local game = Game()
   game:addPlayer()
   game:addWell(12, 22)

   game.seed = os.time()
   
   -- call component init()s
   mode:call('init', game)
   
   return game
end

function M.new()
   local mode = newmode()
   local game = newgame(mode)
   return mode, game
end

return M
