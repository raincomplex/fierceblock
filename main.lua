
require('util')
Class = require('class')
Object = require('object')
Hook = require('hook')
Timer = require('timer')

require('state')
Draw = require('draw')
require('faces')

Modes = {}
Modes.tgm = require('tgm/mode')
Modes.pento = require('pento/mode')

FPSTimer = require('fps')

function love.load(args)
   -- TODO accept replay file to verify

   Draw.load()
   startMode(Modes.tgm)
end

function startMode(m)
   mode, game = m.new()
   fpstimer = FPSTimer(m.fps or 60)
end

function love.update(dt)
   if mode then
      local frames = fpstimer:tick(dt)

      for i = 1, frames do
         game:update()
         mode:update(game)
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

   if key == 'r' then
      startMode(Modes.pento)
   end
   
   if bind then
      local player = game.players[bind.player]
      if player then
         player.input[bind.name] = value
      end
   end
end

function love.draw()
   love.graphics.clear(127, 127, 127)
   Draw.drawbg()

   local scrw, scrh = love.graphics.getDimensions()
   local h = scrh * .7
   local w = h / 2
   local x = scrw / 2 - w / 2
   local y = scrh / 2 - h / 2
   Draw.draw(game.wells[1], {x=x, y=y, w=w, h=h})
end
