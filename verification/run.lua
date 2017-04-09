
math.randomseed(os.time())

machine = manager:machine()
memory = machine.devices[":maincpu"].spaces["program"]

scriptdir = os.getenv('SCRIPTDIR')
replaypath = os.getenv('REPLAY')
recordmode = os.getenv('RECORD')

validmodes = {'normal', 'master', 'plus', 'death', 'doubles'}
-- modenumber set below

package.path = scriptdir..'/?.lua'

require('util')
portinput = require('portinput')
replaymod = require('replay')
fieldmod = require('field')

--portinput.printfields()


if replaypath then
   mode = 'replay'
   
   if replaypath:sub(1, 1) ~= '/' then
      replaypath = scriptdir..'/'..replaypath
   end
   Replay = replaymod.load(replaypath)
   modenumber = Replay.mode

else
   mode = 'record'

   local good = false
   for i = 1, #validmodes do
      if validmodes[i] == recordmode then
         good = true
         modenumber = i
      end
   end
   if not good then
      print('invalid or missing mode (specify RECORD env var)')
      print('valid modes:')
      for i, m in ipairs(validmodes) do
         print('    '..m)
      end
      machine:exit()
      return
   end
end

if emu.romname() ~= 'tgm2p' then
   print('rom isn\'t tgm2p, bailing')
   return
end

fieldAddr = 0x6078657
BlockStateAddr = 0x06064BF5
prngAddr = 0x06064BA8
pieceAddr = 0x6064bf7
blockHistory = 0x06064C04

function startFunc()
   if mode == 'record' then
      print('src', 'mame')
      print('mode', modenumber)
      print('prng', list2str(readmem(prngAddr, 4)))
      local piece = readmem(pieceAddr+2, 1)
      print('piece', list2str(piece))
      local h = readmem(blockHistory, 4)
      assert(h[2] == 1 and h[3] == 2 and h[4] == 2, 'unexpected history')
      assert(h[1] == piece[1] - 2, 'history mismatch')
      print('start')
      
   else
      print('starting replay')
      writemem(prngAddr, Replay.prng)
      writemem(pieceAddr+2, {Replay.piece})
      local h = {Replay.piece - 2, 1, 2, 2}
      writemem(blockHistory, h)

      -- write the first input frame
      portinput.writeDelta(Replay[1].input)
   end
end

do
   local frame = 0
   local press = {}
   -- modenumber is an int 0=normal, 1=master, 2=tgm+, 3=death, 4=doubles

   local base = 195
   if mode == 'record' then
      -- FIXME this is a hack to prevent the same seed from being used for every game
      -- the real fix here is to find a random seed and inject it
      base = base + math.random(0, 60)
   end

   local modenumber = modenumber
   function startup()
      if frame == base then
         press.a = 2
      elseif frame == base+10 then
         press.coin = 1
      elseif frame == base+20 then
         press.start = 1
      elseif frame == base+50 then
         if modenumber > 1 then
            press.down = 1
            frame = frame - 5
            modenumber = modenumber - 1
         end
      elseif frame == base+55 then
         press.a = 1
      elseif memory:read_u8(BlockStateAddr) == 1 then
         -- game is about to start
         startup = nil -- done with this func
         startFunc()
      end

      local inp = {}
      for name, time in pairs(press) do
         if time > 0 then
            inp[name] = true
            press[name] = time - 1
         else
            inp[name] = false
            press[name] = nil
         end
      end
      
      portinput.writeDelta(inp)

      frame = frame + 1
   end
end

frame = 1
verify = {
   field = {},
}

function tick()
   if machine.paused then
      return
   end

   if startup then
      startup()
      return
   end
   
   if mode == 'record' then
      -- user input
      local r = portinput.readDelta()
      for k, v in pairs(r) do
         print('input', k, v and '1' or '0')
      end

      -- play field
      for i, block in pairs(fieldmod.readDelta()) do
         local x, y = fieldmod.getpos(i)
         print('field', x, y, block or '-')
      end
      
      print('frame')
      
   else -- mode == 'replay'
      local cur = Replay[Replay.pos]
      local next = Replay[Replay.pos + 1]
      if not cur then
         finished(Replay.pos)
         return
      end
      Replay.pos = Replay.pos + 1

      -- set user input
      -- it's shifted back by a frame because we read it after it's been used, so it needs to be written before that frame happens
      if next then
         portinput.writeDelta(next.input)
      end

      -- verify play field
      for i, block in pairs(cur.field) do
         if block == '-' then block = nil end
         verify.field[i] = block
      end
      for i, block in fieldmod.read() do
         local x, y = fieldmod.getpos(i)
         if verify.field[i] ~= block then
            desync('field', x, y, cur.field[i], block)
         end
      end
   end

   frame = frame + 1
end

function desync(kind, ...)
   local n = select('#', ...)
   local args = {...}
   for i = 1, n do
      args[i] = tostring(args[i])
   end
   table.insert(args, 1, kind)
   table.insert(args, 1, frame)

   print('DESYNC', unpack(args))
   
   local f = io.open(scriptdir..'/desync.log', 'a')
   f:write(table.concat(args, '\t'))
   f:write('\n')
   f:close()
end

function finished(...)
   print('done', ...)
   --startup = function() end
   machine:exit()
end

emu.register_frame(makeFatal(tick))
