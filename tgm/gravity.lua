
local C = Object.Component()

function C:paintpiece(piece)
   piece.fall = 0
end

function C:gravitystep(player)
   local gravity = 32
   for _, piece in ipairs(player.active) do
      piece.fall = piece.fall + gravity
      while piece.fall >= 256 do
         piece.fall = piece.fall - 256
         local r = piece:resting()
         if r == 'soft' then
            if piece.fall == math.huge then
               -- inf grav, fell onto another player's piece
               break
            end
            if piece.fall < 256 - gravity then
               piece.fall = 256 - gravity
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
