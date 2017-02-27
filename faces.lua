
Draw.loadface('blocks/gameboy.png', {
   {name='J', x=0, y=0, w=64, h=64},
   {name='T', x=64, y=0, w=64, h=64},
   {name='S', x=128, y=0, w=64, h=64},
   {name='I', x=192, y=0, w=64, h=64},
   {name='O', x=0, y=64, w=64, h=64},
   {name='Z', x=64, y=64, w=64, h=64},
   {name='L', x=128, y=64, w=64, h=64},
})

local sh = {}
local i = 1
for x = 0, 3 do
   for y = 0, 3 do
      table.insert(sh, {name=i, x=x*16, y=y*16, w=16, h=16})
      i = i + 1
   end
end
Draw.loadface('blocks/etqws3_1.png', sh)
