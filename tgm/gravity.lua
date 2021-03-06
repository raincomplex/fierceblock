
local C = Object.Component()

function C:init(game)
   for _, player in ipairs(game.players) do
      player.gravity = 8
   end
end

function C:paintpiece(piece)
   piece.fall = 0
end

function C:setgravity(player, amount)
   player.gravity = amount
end

function C:gravitystep(player)
   for _, piece in ipairs(player.active) do

      if not player.input.down then
         player.lockprotect = false
      end
      
      if player.input.down and not player.lockprotect then
         if player.gravity < 256 then
            piece.fall = piece.fall + 256 - player.gravity
         end
         if piece:resting() then
            player.lockprotect = true
            piece:lock()
            goto continue
         end
      end
      
      piece.fall = piece.fall + player.gravity
      while piece.fall >= 256 do
         piece.fall = piece.fall - 256
         local r = piece:resting()
         if r == 'soft' then
            if piece.fall == math.huge then
               -- inf grav, fell onto another player's piece
               break
            end
            if piece.fall < 256 - player.gravity then
               piece.fall = 256 - player.gravity
               break -- just in case gravity is 0
            end
         elseif not r then
            self:call('fallpiece', piece)
            if not piece.active then
               break
            end
         else
            if piece.fall ~= math.huge then
               piece.fall = piece.fall % 256
            end
            break
         end
      end

      ::continue::
   end
end

function C:fallpiece(piece)
   piece:move(0, -1)
   if piece:collide() then
      piece:move(0, 1)
   end
   self:call('fallstep', piece)
end

return C
