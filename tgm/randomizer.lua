
local PRNG = require('tgm/prng')

local C = Object.Component()

local pieces = {[0]='I','Z','S','J','L','O','T'}

function C:init(game)
   -- XXX 235 72 199 36
   game.seed = 0xeb48c724
   --game.seed = 0x24c748eb
   
   for _, player in ipairs(game.players) do
      player.prng = PRNG(game.seed)
      for i = 1, 0 do
         player.prng:read()
      end

      local b = 1
      while b == 1 or b == 2 or b == 5 do
         b = PRNG.theOp(player.prng:read())
      end

      player.history = {b, 1, 2, 1}

      print('first piece', pieces[b])
      for i = 1, 10 do
         print(self:getnextrandom(player))
      end
   end
end

-- tijostzijs

function C:getnextrandom(player)
   local b
   local nrolls = 6
   for i = 1, nrolls - 1 do
      b = PRNG.theOp(player.prng:read())
      
      local match = false
      for _, c in ipairs(player.history) do
         if b == c then
            match = true
            break
         end
      end
      if match == 0 then
         break
      end
      
      b = PRNG.theOp(player.prng:read())
   end

   table.remove(player.history)
   table.insert(player.history, 1, b)

   return pieces[b]
end

return C
