
local C = Object.Component()

function C:init(game)
   for _, player in ipairs(game.players) do
      player.lockdelay = 20
   end
end

function C:paintpiece(piece)
   piece.lockdelay = 0
end

function C:setlockdelay(player, amount)
   player.lockdelay = amount
end

function C:fallstep(piece)
   piece.lockdelay = 0
end

function C:update(game)
   for _, player in ipairs(game.players) do
      for _, piece in ipairs(player.active) do
         if piece:resting() then
            piece.lockdelay = piece.lockdelay + 1
            if piece.lockdelay >= player.lockdelay then
               piece:lock()
            end
         end
      end
   end
end

return C
