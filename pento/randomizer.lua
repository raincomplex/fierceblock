
local C = Object.Component()

local pieces = require('pento/pieces')

function C:init(game)
   self.rng = love.math.newRandomGenerator()
   for _, player in ipairs(game.players) do
      self.rng:setSeed(game.seed)
      player.rand = self.rng:getState()
   end

   self.piecenames = {}
   for name in pairs(pieces) do
      table.insert(self.piecenames, name)
   end
end

function C:getnextrandom(player)
   self.rng:setState(player.rand)
   local p = self.rng:random(1, #self.piecenames)
   player.rand = self.rng:getState()
   return self.piecenames[p]
end

return C
