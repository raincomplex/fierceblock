
local C = Object.Component()

function C:init(mode)
   self.mode = mode
end

local pieces = {'J','I','L','T','S','O','Z'}

function C:getnextrandom(player)
   local r = love.math.random(1, 7)
   return pieces[r]
end

return C
