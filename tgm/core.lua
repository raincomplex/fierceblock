
local C = Object.Component()

function C:init(game)
   game.timer = Timer(0)
   game.state = 'entry'
end

function C:update(game)
   for i, player in ipairs(game.players) do
      if game.state == 'entry' then
         game.timer:tick()
         if game.timer:expired() then
            game.state = 'spawn'
         end

      elseif game.state == 'spawn' then
         local data = self.piecedata[self:call('getnextrandom', player)]
         local well = game.wells[i]
         local piece = game:addPiece(player, well, data)
         self:call('paintpiece', piece)

         game.state = 'active'

      elseif game.state == 'active' then
         self:call('rotatestep', player)
         self:call('shiftstep', player)
         self:call('gravitystep', player)
         if #player.active == 0 then
            game.state = 'entry'
         end

      elseif game.state == 'lineclear' then
         game.state = 'entry'
      end
   end
end

function C:rotatestep(player)
   for _, piece in ipairs(player.active) do
      if player.inputdelta.cw then
         self:call('rotatepiece', piece, 1)
      end
      if player.inputdelta.ccw then
         self:call('rotatepiece', piece, -1)
      end
   end
end

function C:shiftstep(player)
   self:call('updateshift', player)
   if player.shifting then
      for _, piece in ipairs(player.active) do
         if player.shiftdir == 'left' then
            self:call('movepiece', piece, -1, 0)
         end
         if player.shiftdir == 'right' then
            self:call('movepiece', piece, 1, 0)
         end
      end
   end
end

function C:paintpiece(piece)
   local used = {}
   for _, block in ipairs(piece.blocks) do
      --block.face = piece.data.name
      repeat
         block.face = love.math.random(1, 16)
      until not used[block.face]
      used[block.face] = true
   end
end

return C
