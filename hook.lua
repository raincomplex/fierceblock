
-- when a Hook object is called, all functions registered with the hook will be called (regardless of what they return)
-- when a registered function returns some non-nil value(s), they will be passed back to the caller. if more than one registered function returns values, it is an error.

local C = Class()

function C:init(name)
   self.name = name  -- for debugging
   self.hooks = {}
end

function C:register(func)
   table.insert(self.hooks, func)
end

function C:registerBound(inst, funcname)
   self:register(function(...) return inst[funcname](inst, ...) end)
end

function C:__call(...)
   local ret
   for _, func in ipairs(self.hooks) do
      local r = table.pack(func(...))

      for i = 1, r.n do
         if r[i] ~= nil then
            if ret then
               error('multiple functions returned values, when only one is allowed to')
            end
            ret = r
            break
         end
      end
   end
   
   if ret then
      return table.unpack(ret)
   end
end

return C
