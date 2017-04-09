
local C = Object.Component()

function C:movepiece(piece, dx, dy)
   piece:move(dx, dy)
   if piece:collide() then
      piece:move(-dx, -dy)
      return false
   end
   return true
end

local adjacent = {{x=-1, y=0}, {x=1, y=0}, {x=0, y=-1}, {x=0, y=1}}

local searchspot = {}
do
   for dx = -4, 4 do
      for dy = -4, 4 do
         table.insert(searchspot, {dx=dx, dy=dy})
      end
   end
   local function order(a, b)
      -- closer first
      local amag = math.sqrt(a.dx^2 + a.dy^2)
      local bmag = math.sqrt(b.dx^2 + b.dy^2)
      if amag < bmag then return true end
      if amag > bmag then return false end
      -- then downward
      if a.dy > b.dy then return true end
      if a.dy < b.dy then return false end
      -- then left to right
      if a.dx < b.dx then return true end
      if a.dx > b.dx then return false end
      -- equal
      return false
   end
   table.sort(searchspot, order)
end

function C:rotatepiece(piece, dr)
   piece:rotate(dr)
   if not piece:collide() then
      -- simple rotation
      return true
   end
   
   -- find a spot which still overlaps and has the most number of surrounding blocks

   -- get original blocks
   piece:rotate(-dr)
   local orig = {}
   for _, block in ipairs(piece:getblocks()) do
      orig[block.x..','..block.y] = true
   end
   piece:rotate(dr)
   
   local best = -1
   local bestpos
   for _, spot in ipairs(searchspot) do
      local dx, dy = spot.dx, spot.dy
      piece:move(dx, dy)
      
      local overlap = false
      for _, block in ipairs(piece:getblocks()) do
         if orig[block.x..','..block.y] then
            overlap = true
            break
         end
      end
      
      if overlap and not piece:collide() then
         local current = {}
         for _, block in ipairs(piece:getblocks()) do
            current[block.x..','..block.y] = true
         end
         local count = 0
         for _, block in ipairs(piece:getblocks()) do
            for _, e in ipairs(adjacent) do
               local x = block.x + e.x
               local y = block.y + e.y
               if not current[x..','..y] and piece.well:get(x, y) then
                  count = count + 1
               end
            end
         end

         if count > best then
            best = count
            bestpos = {dx=dx, dy=dy}
         end
      end
      
      piece:move(-dx, -dy)
   end

   if best >= 0 then
      piece:move(bestpos.dx, bestpos.dy)
      return true
   end

   piece:rotate(-dr)
   return false
end

return C
