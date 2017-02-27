
local C = Object.Component()

function C:movepiece(piece, dx, dy)
   piece:move(dx, dy)
   if piece:collide() then
      piece:move(-dx, -dy)
      return false
   end
   return true
end

function C:rotatepiece(piece, dr)
   piece:rotate(dr)
   if piece:collide() then
      -- kick right
      piece:move(1, 0)
      if piece:collide() then
         -- kick left
         piece:move(-2, 0)
         if piece:collide() then
            -- rotate fails
            piece:move(1, 0)
            piece:rotate(-dr)
            return false
         end
      end
   end
   return true
end

return C
