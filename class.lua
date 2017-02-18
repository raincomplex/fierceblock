
local Class, construct

function Class()
   local C = {}
   C.__index = C
   setmetatable(C, {__call=construct})
   
   return C
end

function construct(C, ...)
   local inst = {}
   setmetatable(inst, C)
   if inst.init then
      inst:init(...)
   end
   return inst
end

return Class
