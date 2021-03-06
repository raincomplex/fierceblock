
function table.pack(...)
   return {n=select('#', ...), ...}
end

table.unpack = unpack

function table.copy(t)
   local c = {}
   for k, v in pairs(t) do
      c[k] = v
   end
   return c
end

-- won't be copied by deepcopy()
function table.makestatic(t)
   t._static = true
end

function table.deepcopy(t, ref)
   if t._static then
      return t
   end
   
   if not ref then
      ref = {}  -- {original_table = copy_table}
   end
   if ref[t] then
      return ref[t]
   end
   
   local c = {}
   ref[t] = c
   
   for k, v in pairs(t) do
      if type(k) == 'table' then
         k = table.deepcopy(k, ref)
      end
      if type(v) == 'table' then
         v = table.deepcopy(v, ref)
      end

      c[k] = v
   end
   
   setmetatable(c, getmetatable(t))
   return c
end

function table.dump(t, depth, ref)
   if not depth then depth = 0 end
   if not ref then ref = {} end
   local indent = string.rep('  ', depth)
   
   if ref[t] then
      print(indent..'('..tostring(t)..')')
      return
   end
   ref[t] = true
   
   if type(t) == 'table' then
      print(indent .. '{')
      for k, v in pairs(t) do
         local s = indent..'  '..k..' = '
         local tv = type(v)
         if tv ~= 'table' then
            s = s .. tostring(v)
         end
         print(s)
         if tv == 'table' then
            table.dump(t, depth + 1, ref)
         end
      end
      print(indent .. '}')
   else
      print(indent .. t)
   end
end

function table.removeValue(t, v)
   for k, tv in pairs(t) do
      if v == tv then
         t[k] = nil
         return
      end
   end
end
