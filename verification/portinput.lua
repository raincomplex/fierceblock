
local M = {}
local port = manager:machine():ioport().ports[':INPUTS']

function M.printfields()
   print('input fields:')
   for k, v in pairs(port.fields) do
      print(k, v, v.mask)
   end
   print('end fields')
end

local mameToBind = {
   ['P1 Up']='up',
   ['P1 Down']='down',
   ['P1 Left']='left',
   ['P1 Right']='right',
   ['P1 Button 1']='a',
   ['P1 Button 2']='b',
   ['P1 Button 3']='c',
   ['1 Player Start']='start',
   ['Coin 1']='coin',
}

local bindToMame = {}
for k, v in pairs(mameToBind) do
   bindToMame[v] = k
end

function M.read()
   local v = port:read()
   local r = {}

   for name, bind in pairs(mameToBind) do
      local m = port.fields[name].mask
      local pressed = (bit32.band(m, v) == 0)
      r[bind] = pressed
   end

   return r
end

local lastread = {}
function M.readDelta()
   local r = M.read()
   local d = {}
   for k, v in pairs(r) do
      if lastread[k] ~= v then
         d[k] = v
      end
   end
   lastread = r
   return d
end

function M.writeDelta(d)
   for bind, value in pairs(d) do
      local field = port.fields[bindToMame[bind]]
      field:set_value(value and field.mask or 0)
   end
end

return M
