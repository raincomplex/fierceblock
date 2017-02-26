
local M = {}

M.fps = 61.681173

local Core = require('tgm/core')
local PieceData = require('tgm/pieces')
local Randomizer = require('tgm/randomizer')
local FullRandom = require('fullrandom')

function M.newmode()
   local mode = Object()
   mode:add(Core)
   mode.piecedata = PieceData
   mode:add(Randomizer)
   --mode:add(FullRandom)
   return mode
end

function M.newgame(mode)
   local game = Game()
   game:addPlayer()
   game:addWell(10, 20)

   game.state = 'spawn'
   game.seed = os.time()
   
   -- call component init()s
   mode:call('init', game)
   
   return game
end

return M
