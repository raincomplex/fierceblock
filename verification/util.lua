
function readmem(addr, size)
   local list = {}
   for i = 1, size do
      table.insert(list, memory:read_u8(addr))
      addr = addr + 1
   end
   return list
end

function writemem(addr, list)
   for i = 0, #list-1 do
      memory:write_u8(addr + i, list[i+1])
   end
end

function list2str(list)
   return table.concat(list, ' ')
end

function listsEqual(a, b)
   if #a ~= #b then return false end
   for i = 1, #a do
      if a[i] ~= b[i] then return false end
   end
   return true
end

function MessageHandler(err)
   local tb = debug.traceback(err, 2)

   -- reduce verbosity
   local pattern = scriptdir:gsub('%p', '%%%0')
   tb = tb:gsub(pattern, '..')
   
   print(tb)
end

function makeFatal(func)
   return function(...)
      local success, err = xpcall(func, MessageHandler, ...)
      if not success then
         machine:exit()
      end
   end
end
