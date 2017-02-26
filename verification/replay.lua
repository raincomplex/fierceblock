
local M = {}

function M.load(path)
   local rec = {pos=1}
   for line in io.open(path, 'r'):lines() do
      local item = {}
      for w in line:gmatch('%S+') do
         table.insert(item, w)
      end

      if item[1] == 'prng' then
         table.remove(item, 1)
         rec.prngseed = item
      elseif item[1] == 'piece' then
         table.remove(item, 1)
         rec.piece = item
      elseif item[1] == 'mode' then
         table.remove(item, 1)
         rec.mode = tonumber(item[1])
      elseif item[1] == 'frame' or item[1] == 'input' then
         table.insert(rec, item)
      elseif item[1] == 'src' then
         rec.src = item[2]
      else
         print('skipping unknown item: '..item[1])
      end
   end
   return rec
end

return M
