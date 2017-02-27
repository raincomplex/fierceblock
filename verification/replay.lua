
local M = {}

local function newFrame()
   return {input={}}
end

function M.load(path)
   local rec = {pos=1}
   local frame
   
   for line in io.open(path, 'r'):lines() do
      local item = {}
      for w in line:gmatch('%S+') do
         table.insert(item, w)
      end

      if not frame then
         if item[1] == 'start' then
            frame = newFrame()
            
         else
            local name = item[1]
            table.remove(item, 1)
            
            for i = 1, #item do
               local n = tonumber(item[i])
               if n then
                  item[i] = n
               end
            end
            if #item == 1 then
               item = item[1]
            end
            
            rec[name] = item
         end
         
      elseif item[1] == 'frame' then
         table.insert(rec, frame)
         frame = newFrame()
         
      elseif item[1] == 'input' then
         frame.input[item[2]] = (item[3] == '1')

      else
         print('skipping unknown item: ' .. item[1])
      end
   end
   return rec
end

return M
