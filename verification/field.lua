
local M = {}

local field = {}
local piecenames = {'?', 'I', 'Z', 'S', 'J', 'L', 'O', 'T'}

function M.read()
   local addr = fieldAddr
   local i = 1
   return function()
      if i > 200 then
         return nil
      end
      
      local value = memory:read_u8(addr)
      local block
      if value & 0x10 ~= 0 then
         block = piecenames[value & 0xf] or '?'
      end
      
      i = i + 1
      addr = addr + 6
      if i % 10 == 9 then
         addr = addr + 12
      end

      return i-1, block
   end
end

function M.readDelta()
   local delta = {}

   for i, new in M.read() do
      if field[i] ~= new then
         field[i] = new
         delta[i] = new or false
      end
   end
   
   return delta
end

function M.getpos(i)
   -- using fb coords (lower left is 1,1)
   i = i - 1  -- 0-199
   local x = 1 + i % 10
   local y = math.floor(1 + (i - i%10) / 10)
   return x, y
end

return M
