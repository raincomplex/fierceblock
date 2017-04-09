
local C = Object.Component()

local lockdelay = 60*60

function C:paintpiece(piece)
   piece.lockdelay = 0
end

function C:fallstep(piece)
   piece.lockdelay = 0
end

function C:update(game)
   for _, player in ipairs(game.players) do
      for _, piece in ipairs(player.active) do
         if piece:resting() then
            piece.lockdelay = piece.lockdelay + 1
            if piece.lockdelay >= lockdelay then
               piece:lock()
            end
         end
      end
   end
end

return C
