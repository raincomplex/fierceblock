
local C = Class()

local function split(n)
   -- low, high
   return bit.band(n, 0xffff), bit.rshift(n, 16)
end

-- remove sign from 32-bit int
local function unsigned(n)
   if n < 0 then return n + 0x100000000 end
   return n
end

local function uint32(n)
   return ffi.new('uint32_t', n)
end

function C.bigmul(a, b)
   --local m = uint32(a) * uint32(b)
   --return tonumber(uint32(m))
   
   local al, ah = split(a)
   local bl, bh = split(b)

   -- al*bl       = r1 r2
   --    ah*bl    =    r3 r4
   --    al*bh    =    r5 r6
   --       ah*bh =       r7 r8
   --               x  y  z  w

   local r1, r2 = split(al * bl)
   local r3, r4 = split(ah * bl)
   local r5, r6 = split(al * bh)
   local r7, r8 = split(ah * bh)

   local x, y, z, w, c
   x = r1
   y, c = split(r2 + r3 + r5)
   z, c = split(c + r4 + r6 + r7)
   w = c + r8

   local low = unsigned(x + bit.lshift(y, 16))
   local high = unsigned(z + bit.lshift(w, 16))
   return low, high
end

function C.rand(n)
   local lo, hi = C.bigmul(n, 0x41C64E6D)
   return bit.band(lo + 12345, 0xffffffff)
end

function C.unrand(n)
   local lo, hi = C.bigmul(n - 12345, 0xeeb9eb65)
   return bit.band(lo, 0xffffffff)
end

function C:init(seed)
   self.state = seed
end

function C:read()
   self.state = C.rand(self.state)
   return bit.band(bit.rshift(self.state, 10), 0x7fff)
end

return C
