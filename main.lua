
require('util')
Class = require('class')
Object = require('object')
Hook = require('hook')

require('state')
Draw = require('draw')

Draw.loadface('blocks/gameboy.png', {
                 {name='J', x=0, y=0, w=64, h=64},
                 {name='T', x=64, y=0, w=64, h=64},
                 {name='S', x=128, y=0, w=64, h=64},
                 {name='I', x=192, y=0, w=64, h=64},
                 {name='O', x=0, y=64, w=64, h=64},
                 {name='Z', x=64, y=64, w=64, h=64},
                 {name='L', x=128, y=64, w=64, h=64},
})

Modes = {}
Modes.tgm = require('tgm/mode')

FPSTimer = require('fps')

function love.load()
   startMode(Modes.tgm)
end

function startMode(m)
   mode = m.newmode()
   game = m.newgame(mode)
   fpstimer = FPSTimer(m.fps or 60)
end

function love.update(dt)
   if mode then
      local frames = fpstimer:tick(dt)

      for i = 1, frames do
         mode:call('update', game)
      end
   end
end

bindings = {}

function setbind(key, player, bind)
   if player and bind then
      bindings[key] = {player=player, name=bind}
   else
      bindings[key] = nil
   end
end

setbind('q', 1, 'ccw')
setbind('e', 1, 'cw')
setbind('kp4', 1, 'left')
setbind('kp5', 1, 'down')
setbind('kp6', 1, 'right')
setbind('kp8', 1, 'up')
setbind('space', 1, 'hold')

function love.keypressed(key)
   keyPressed(key, true)
end
function love.keyreleased(key)
   keyPressed(key, false)
end

function keyPressed(key, value)
   local bind = bindings[key]

   if bind then
      local player = game.players[bind.player]
      if player then
         player.input[bind.name] = value
      end
   end
end

function love.draw()
   love.graphics.clear(127, 127, 127)
   Draw.draw(game.wells[1], {x=10, y=10, w=200, h=400})
end
