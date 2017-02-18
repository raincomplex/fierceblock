
local M = {}
local blockfaces = {}

function M.draw(well, rect)
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

   love.graphics.setColor(0, 0, 0, 127)
   love.graphics.rectangle('fill', rect.x, rect.y, rect.w, rect.h)
   
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
