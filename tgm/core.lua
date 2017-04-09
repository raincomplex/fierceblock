
local C = Object.Component()

function C:init(game)
   game.timer = Timer(0)
   game.state = 'entry'

   for i, player in ipairs(game.players) do
      player.level = 0
      player.lines = 0

      -- FIXME binding game and player here is bad
      local function generator()
         local r = self:call('getnextrandom', player)
         local data = self.piecedata[r]
         local well = game.wells[i]
         
         local piece = Piece(nil, nil, data)
         self:call('paintpiece', piece)

         return piece
      end
      player.sequence = Sequence(generator)
   end
end

function C:update(game)
   for i, player in ipairs(game.players) do
      if game.state == 'entry' then
         game.timer:tick()
         if game.timer:expired() then
            game.state = 'spawn'
         end

      elseif game.state == 'spawn' then
         local piece = player.sequence:pop()
         piece:addTo(player, game.wells[i])

         if player.level % 100 ~= 99 then
            player.level = player.level + 1
         end
         
         self:call('gravitystep', player)
         
         if piece:collide() then
            game.state = 'over'
         else
            game.state = 'active'
         end

      elseif game.state == 'active' then
         self:call('rotatestep', player)
         self:call('shiftstep', player)
         self:call('gravitystep', player)
         self:call('clearstep', player)
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

function C:clearstep(player)
   local well = player.active[1] and player.active[1].well
   if not well then
      return
   end

   local full = {}
   for y = 1, well.height do
      if well:filled(y) then
         table.insert(full, y)
         -- TODO erase/collapse with a timer
      end
   end

   if #full > 0 then
      well:collapse(full)
      player.lines = player.lines + #full
      player.level = player.level + #full
   end
end

function C:paintpiece(piece)
   if Draw.paintfunc then
      Draw.paintfunc(piece)
   end
end

return C
