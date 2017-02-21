
local C = Class()

function C:init(mode)
   self.mode = mode
end

function C:getnextrandom(player)
   local r = love.math.random(1, 7)
   local pieces = {'J','I','L','T','S','O','Z'}
   player.nextrandom = pieces[r]
end

return C
