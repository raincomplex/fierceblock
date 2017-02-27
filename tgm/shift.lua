
local C = Object.Component()

local shiftAmount = 12

function C:updateshift(player)
   if player.input.left or player.input.right then
      local dir = player.input.left and 'left' or 'right'
      if dir ~= player.shiftdir then
         -- first frame we've pressed this direction
         player.shiftdir = dir
         player.shifttime = 0
         player.shifting = true
      else
         player.shifttime = player.shifttime + 1
         player.shifting = (player.shifttime >= shiftAmount)
      end
   else
      player.shiftdir = nil
   end
end

return C
