
require('util')
Class = require('class')
Object = require('component')

require('state')
Draw = require('draw')

Draw.loadface('blocks/gameboy.png', {
                 {name=1, x=0, y=0, w=64, h=64},
                 {name=2, x=64, y=0, w=64, h=64},
                 {name=3, x=128, y=0, w=64, h=64},
                 {name=4, x=192, y=0, w=64, h=64},
                 {name=5, x=0, y=64, w=64, h=64},
                 {name=6, x=64, y=64, w=64, h=64},
                 {name=7, x=128, y=64, w=64, h=64},
})

tgmpieces = require('tgm-pieces')


function love.load()
   math.randomseed(os.time())
   
   g = Game()
   g:addPlayer()
   g:addWell(10, 20)
end

function love.update(dt)
   if #g.wells[1].active == 0 then
      local p = g.wells[1]:spawn(g.players[1], tgmpieces.T)
      
      for _, block in ipairs(p.blocks) do
         block.face = math.random(1, 7)
      end
   end
end

bindings = {
   q = 'ccw',
   e = 'cw',
   kp4 = 'left',
   kp5 = 'down',
   kp6 = 'right',
   kp8 = 'up',
}

function love.keypressed(key)
   local bind = bindings[key]
   local piece = g.wells[1].active[1]
   
   if bind == 'ccw' then
      piece:rotate(-1)
   elseif bind == 'cw' then
      piece:rotate(1)
   elseif bind == 'left' then
      piece:move(-1, 0)
   elseif bind == 'down' then
      piece:move(0, -1)
   elseif bind == 'right' then
      piece:move(1, 0)
   elseif bind == 'up' then
      piece:move(0, 1)
   elseif key == 'space' then
      piece:lock()
   end
end

function love.draw()
   love.graphics.clear(127, 127, 127)
   Draw.draw(g.wells[1], {x=10, y=10, w=200, h=400})
end
