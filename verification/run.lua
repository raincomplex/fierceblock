
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

fieldaddr = 0x6078657
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
   end
end

do
   local frame = 0
   local press = {}
   local mode = modenumber
   -- modes: normal, master, tgm+, death, doubles
   
   function startup()
      if frame == 195 then
         press.a = 2
      elseif frame == 205 then
         press.coin = 1
      elseif frame == 215 then
         press.start = 1
      elseif frame == 245 then
         if mode > 1 then
            press.down = 1
            frame = frame - 5
            mode = mode - 1
         end
      elseif frame == 250 then
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

frame = 0

function tick()
   if machine.paused then
      return
   end

   if startup then
      startup()
      return
   end
   
   -- user input
   frame = frame + 1
   
   if mode == 'record' then
      local r = portinput.readDelta()
      for k, v in pairs(r) do
         print('input', k, v and '1' or '0')
      end
   else
      local i = Replay.pos + 1
      if not Replay[i] then
         finished(i)
         return
      end
      
      Replay.pos = i
      
      portinput.writeDelta(Replay[i].input)
   end
   
   if mode == 'record' then
      print('frame')
   end
end

function finished(...)
   print('done', ...)
   --startup = function() end
   machine:exit()
end

emu.register_frame(makeFatal(tick))
