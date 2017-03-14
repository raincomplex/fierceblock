
local C = Object.Component()

local pieces = require('pento/pieces')

function C:init(game)
   self.rng = love.math.newRandomGenerator()
   for _, player in ipairs(game.players) do
      self.rng:setSeed(game.seed)
      player.rand = self.rng:getState()
      player.randbuffer = {}
   end

   self.piecenames = {}
   for name in pairs(pieces) do
      table.insert(self.piecenames, name)
   end
end

function C:getnextrandom(player)
   if #player.randbuffer == 0 then
      self:call('peeknextrandom', player, 1)
   end
   return table.remove(player.randbuffer, 1)
end

function C:peeknextrandom(player, n)
   n = n or 1
   assert(n >= 1)
   
   while not player.randbuffer[n] do
      self.rng:setState(player.rand)
      local p = self.rng:random(1, #self.piecenames)
      player.rand = self.rng:getState()
      table.insert(player.randbuffer, self.piecenames[p])
   end

   return player.randbuffer[n]
end

return C
