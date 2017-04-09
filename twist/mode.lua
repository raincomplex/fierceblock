
local M = {}

M.fps = 61.681173

local Core = require('tgm/core')
local Physics = require('twist/physics')
local Gravity = require('twist/gravity')
local Shift = require('tgm/shift')
local Lock = require('twist/lock')
local PieceData = require('tgm/pieces')
local Randomizer = require('tgm/randomizer')

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
   mode.piecedata = PieceData
   mode:add(Randomizer)
   return mode
end

local function newgame(mode)
   local game = Game()
   game:addPlayer()
   game:addWell(10, 20)

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
