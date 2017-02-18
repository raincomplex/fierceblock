
local C = Class()

function C:init()
   self.components = {}
end

function C:add(comp)
   table.insert(self.components, comp)
end

function C:send(name, ...)
   for i, comp in ipairs(self.components) do
      local f = comp[name]
      if f then
         f(comp, ...)
      end
   end
end

return C
