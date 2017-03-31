
local face = 'gameboy'

local function paint_byname(piece)
   for _, block in ipairs(piece.blocks) do
      block.face = piece.data.name
   end
end

local function paint_random(piece)
   local used = {}
   for _, block in ipairs(piece.blocks) do
      repeat
         block.face = love.math.random(1, 16)
      until not used[block.face]
      used[block.face] = true
   end
end

if face == 'gameboy' then
   Draw.loadface('blocks/gameboy.png', {
                    {name='J', x=0, y=0, w=64, h=64},
                    {name='T', x=64, y=0, w=64, h=64},
                    {name='S', x=128, y=0, w=64, h=64},
                    {name='I', x=192, y=0, w=64, h=64},
                    {name='O', x=0, y=64, w=64, h=64},
                    {name='Z', x=64, y=64, w=64, h=64},
                    {name='L', x=128, y=64, w=64, h=64},
   })

   Draw.paintfunc = paint_byname
end

if face == 'pento' then
   local s = 'IJLXSZNGUTFaFbPQWYaYbV'
   local list = {}
   local x = 0
   for name in s:gmatch('[A-Z][a-z]*', s) do
      table.insert(list, {name=name, x=x, y=0, w=16, h=16})
      x = x + 16
   end

   Draw.loadface('blocks/felicity.png', list)
   Draw.paintfunc = paint_byname
end

if face == 'old' then
   local sh = {}
   local i = 1
   for x = 0, 3 do
      for y = 0, 3 do
         table.insert(sh, {name=i, x=x*16, y=y*16, w=16, h=16})
         i = i + 1
      end
   end
   Draw.loadface('blocks/etqws3_1.png', sh)
   Draw.paintfunc = paint_random
end
