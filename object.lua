
-- some notes:
-- Component functions are Hookified
-- 'add' is reserved as a function name, for adding Components to the Object
-- Object doesn't call init() for Components, you have to do that once they are all added
-- private functions should be local to the Component's module, as there is no way to make a member function private to the Component

local Hook = require('hook')

local C = Class()

-- components are just tables with functions in them, with a metatable for type checking

local ComponentMT = {}
function C.Component()
   return setmetatable({}, ComponentMT)
end

local function isComponent(c)
   return getmetatable(c) == ComponentMT
end

function C:add(comp)
   assert(isComponent(comp), 'argument must be an Object.Component')
   
   for name, value in pairs(comp) do
      if type(value) == 'function' then
         if name == 'add' then
            error('Components may not use reserved names for functions: '..name)
         end
         
         if not self[name] then
            self[name] = Hook(name)
         end
         self[name]:register(value)
         
      else
         error('Component with non-function value: '..name)
      end
   end
end

return C
