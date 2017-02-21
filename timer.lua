
local C = Class()

function C:init(frames)
   self.n = frames
end

function C:tick()
   self.n = self.n - 1
end

function C:expired()
   return self.n <= 0
end

return C
