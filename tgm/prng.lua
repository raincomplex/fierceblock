
local C = Class()

local function split(n)
   -- low, high
   return bit.band(n, 0xffff), bit.rshift(n, 16)
end

local function nosign(n)
   if n < 0 then return n + 0x100000000 end
   return n
end

function C.bigmul(a, b)
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

   local low = nosign(x + bit.lshift(y, 16))
   local high = nosign(z + bit.lshift(w, 16))
   return low, high
end

function C.theOp(a)
   local b, c, _
   a = bit.rshift(a, 10)
   _, b = C.bigmul(a, 0x24924925)  -- /7
   c = bit.rshift(a - b, 1)
   b = bit.rshift(b + c, 2)
   c = bit.lshift(b, 3) - b  -- *7
   return bit.band(a - c, 0xffffffff)
end

function C.rand(n)
   local lo, hi = C.bigmul(n, 0x41C64E6D)
   return bit.band(lo + 12345, 0xffffffff)
end

function C:init(seed)
   self.state = seed
end

function C:read()
   self.state = C.rand(self.state)
   return self.state
end

return C
