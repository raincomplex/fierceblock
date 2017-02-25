
local C = Object.Component()

local pieces = {'J','I','L','T','S','O','Z'}

function C:init(game)
   self.rng = love.math.newRandomGenerator()
   for _, player in ipairs(game.players) do
      self.rng:setSeed(game.seed)
      player.rand = self.rng:getState()
   end
end

function C:getnextrandom(player)
   self.rng:setState(player.rand)
   local p = self.rng:random(1, #pieces)
   player.rand = self.rng:getState()
   return pieces[p]
end

return C
