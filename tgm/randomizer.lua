
local PRNG = require('tgm/prng')

local C = Object.Component()

local pieces = {[0]='I','Z','S','J','L','O','T'}
local nrolls = 6

function C:init(game)
   -- XXX 235 72 199 36
   game.seed = os.time() --0xeb48c724

   -- for seeds from MAME, need to roll back by one read(), because the first piece was already generated
   game.seed = PRNG.unrand(game.seed)
   
   for _, player in ipairs(game.players) do
      player.prng = PRNG(game.seed)

      local b = 1
      while b == 1 or b == 2 or b == 5 do  -- skip SZO
         b = player.prng:read() % 7
      end

      player.history = {b, 1, 2, 2} -- ZSS

      --[[ XXX
      local target = 'TIJOSTZIJSLZIJSLTOZJSLTOJZLTSOIZLJSIZLTO'
      for i = 1, target:len() do
         local x = self:call('getnextrandom', player)
         local y = target:sub(i, i)
         print(i, x, y, x == y and '' or 'NOPE')
      end
      --]]
   end
end

function C:getnextrandom(player)
   local ret = pieces[player.history[1]]
   
   local b
   for i = 1, nrolls - 1 do
      b = player.prng:read() % 7
      
      local inhistory = false
      for _, c in ipairs(player.history) do
         if b == c then
            inhistory = true
            break
         end
      end
      if not inhistory then
         break
      end
      
      b = player.prng:read() % 7
   end

   table.remove(player.history)
   table.insert(player.history, 1, b)

   return ret
end

return C
