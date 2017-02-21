
local M = {}

M.fps = 61.681173

local Core = require('tgm/core')
local PieceData = require('tgm/pieces')
local Randomizer = require('tgm/randomizer')
local Checks = require('checks')

function M.newmode()
   local m = Object()
   m:add(Core(m))
   m.piecedata = PieceData
   m:add(Randomizer(m))
   m:add(Checks())
   return m
end

function M.newgame()
   local game = Game()
   game:addPlayer()
   game:addWell(10, 20)

   game.state = 'spawn'
   
   return game
end

return M
