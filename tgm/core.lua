
local PieceData = require('tgm/pieces')

local C = Object.Component()

function C:init()
end

function C:update(game)
   local player = game.players[1]
   local well = game.wells[1]
   
   if game.state == 'entry' then
      game.timer:tick()
      if game.timer:expired() then
         game.state = 'spawn'
      end

   elseif game.state == 'spawn' then
      local data = self:getnextpiece(player)
      local piece = well:spawn(player, data)
      self:paintpiece(piece)

      game.state = 'active'

   elseif game.state == 'active' then
      local piece = well.active[1]
      if piece.player.input.cw then
         piece:rotate(1)
         piece.player.input.cw = false
      end
      if piece.player.input.ccw then
         piece:rotate(-1)
         piece.player.input.ccw = false
      end

   elseif game.state == 'lineclear' then
      
   end
end

function C:getnextpiece(player)
   local nr = self:getnextrandom(player)
   return PieceData[nr]
end

function C:paintpiece(piece)
   for _, block in ipairs(piece.blocks) do
      block.face = piece.data.name --love.math.random(1, 7)
   end
end

return C
