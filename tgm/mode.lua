
local M = {}

M.fps = 61.681173

local Core = require('tgm/core')
local PieceData = require('tgm/pieces')
local Randomizer = require('tgm/randomizer')

function M.newmode()
   local mode = Object()
   mode:add(Core)
   mode.piecedata = PieceData
   mode:add(Randomizer)

   mode:init()
   return mode
end

function M.newgame()
   local game = Game()
   game:addPlayer()
   game:addWell(10, 20)

   game.state = 'spawn'
   
   return game
end

return M
