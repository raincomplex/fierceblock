
local C = Class()

function C:init(fps)
   self.fps = fps
   self.spf = 1 / fps
   self.t = 0
end

function C:tick(dt)
   self.t = self.t + dt
   local c = 0
   while self.t >= self.spf do
      self.t = self.t - self.spf
      c = c + 1
   end

   return c
end

return C
