
local M = {}
local bgs = {}
local frames = {}
local blockfaces = {}

function M.load()
   bgs.cafe = love.graphics.newImage('bgs/cafe.jpg')
   frames.wood = {
      texture = love.graphics.newImage('frames/wood.png'),
      inner = {x=98, y=98, w=493, h=986},
   }
end

function M.drawbg()
   local bg = bgs.cafe
   
   local w, h = bg:getDimensions()
   local scrw, scrh = love.graphics.getDimensions()
   local scale = scrh / h
   local x = scrw / 2 - (w * scale) / 2
   love.graphics.draw(bg, x, 0, 0, scale)
end

function M.draw(well, rect)
   local frame = frames.wood
   
   local bw = rect.w / well.width
   local bh = rect.h / well.height

   local function drawblock(x, y, block)
      -- invert y
      y = well.height - y + 1
      
      if block.color then
         love.graphics.setColor(block.color.r, block.color.g, block.color.b)
      else
         love.graphics.setColor(255, 255, 255)
      end
      
      local bf = block.face and blockfaces[block.face]
      if bf then
         love.graphics.draw(bf.tex, bf.quad, rect.x + (x-1)*bw, rect.y + (y-1)*bh, 0, bw/bf.w, bh/bf.h)
      else
         love.graphics.rectangle('fill', rect.x + (x-1)*bw, rect.y + (y-1)*bh, bw, bh)
      end
   end

   -- draw frame
   if frame then
      local fw, fh = frame.texture:getDimensions()
      local sx = rect.w / frame.inner.w
      local sy = rect.h / frame.inner.h
      local ox = -sx * frame.inner.x
      local oy = -sy * frame.inner.y
      love.graphics.draw(frame.texture, ox + rect.x, oy + rect.y, 0, sx, sy)
   else
      -- default frame is just a translucent box
      love.graphics.setColor(0, 0, 0, 192)
      love.graphics.rectangle('fill', rect.x, rect.y, rect.w, rect.h)
   end
   
   for y = well.height, 1, -1 do
      for x = 1, well.width do
         local block = well:get(x, y)
         if block then
            drawblock(x, y, block)
         end
      end
   end

   for _, piece in ipairs(well.active) do
      for _, block in ipairs(piece.blocks) do
         local x = piece.x + block.x
         local y = piece.y + block.y
         drawblock(x, y, block)
      end

      for i = 1, 3 do
         local p = piece.player.sequence:peek(i)
         for _, block in ipairs(p.blocks) do
            local x = well.width + 4 + block.x
            local y = well.height + 3 - i*4 + block.y
            drawblock(x, y, block)
         end
      end
   end

   for _, player in ipairs(well.game.players) do
      if player.level then
         love.graphics.print(player.level, 20, 420)
      end
      if player.lines then
         love.graphics.print(player.lines, 20, 440)
      end
   end
end

-- sprites = {{name=, x=, y=, w=, h=}}
function M.loadface(texturepath, sprites)
   local texture = love.graphics.newImage(texturepath)
   local w, h = texture:getDimensions()
   
   for _, sprite in ipairs(sprites) do
      local face = {}
      face.tex = texture
      face.quad = love.graphics.newQuad(sprite.x, sprite.y, sprite.w, sprite.h, w, h)
      face.w = sprite.w
      face.h = sprite.h
      
      blockfaces[sprite.name] = face
   end
end

return M
