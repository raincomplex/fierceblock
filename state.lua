
Game = Class()

function Game:init()
   self.wells = {}
   self.players = {}
end

-- should be called at the beginning of a frame update (before mode update)
function Game:update()
   for _, player in ipairs(self.players) do
      player:update()
   end
end

function Game:addWell(...)
   local w = Well(self, ...)
   table.insert(self.wells, w)
   return w
end

function Game:addPlayer(...)
   local p = Player(self, ...)
   table.insert(self.players, p)
   return p
end

function Game:addPiece(player, well, ...)
   local p = Piece(player, well, ...)
   table.insert(player.active, p)
   table.insert(well.active, p)
   return p
end

function Game:copy()
   return table.deepcopy(self)
end


Player = Class()

function Player:init(game)
   self.game = game
   self.input = {}  -- {left=bool, cw=bool, ...}
   self.lastinput = {}  -- ", but for last frame
   self.inputdelta = {}  -- ", but only contains values for the first frame they are different
   self.active = {}  -- {Piece}
end

function Player:update()
   for name, value in pairs(self.input) do
      if value ~= self.lastinput[name] then
         self.inputdelta[name] = value
      else
         self.inputdelta[name] = nil
      end
      self.lastinput[name] = value
   end
end


Well = Class()

function Well:init(game, width, height)
   self.game = game
   self.width = width
   self.height = height
   self.active = {}  -- {Piece}

   -- private
   self._blocks = {}
end

-- (1,1) is lower left, (width,height) is upper right
function Well:get(x, y)
   if x < 1 or x > self.width or y < 1 or y > self.height then
      return nil
   end
   return self._blocks[x + y * self.width]
end

function Well:set(x, y, block)
   if x < 1 or x > self.width or y < 1 or y > self.height then
      return
   end
   self._blocks[x + y * self.width] = block
end


Piece = Class()

function Piece:init(player, well, data)
   self.active = true
   self.player = player  -- Player
   self.well = well  -- Well
   self.x = data.spawn.x
   self.y = data.spawn.y
   self.r = 1
   self.data = data  -- PieceData

   self.blocks = {}  -- {Block}
   for i, pos in ipairs(data.rotation[1]) do
      self.blocks[i] = Block(pos)
   end
end

--[[ PieceData =
   {
      name = str,
      spawn = {
         x = int,
         y = int,
         -- r starts at 1
      },
      rotation = {
         -- one entry for each rotation state, in order from spawn, rotating clockwise
         {{x=int, y=int}, ...},
      },
   }
]]

-- doesn't check collisions
function Piece:move(dx, dy)
   self.x = self.x + dx
   self.y = self.y + dy
end

-- doesn't check collisions
-- dr == 1 means cw, -1 means ccw
function Piece:rotate(dr)
   self.r = 1 + (self.r + dr - 1) % #self.data.rotation
   local data = self.data.rotation[self.r]
   for i, block in ipairs(self.blocks) do
      block.x = data[i].x
      block.y = data[i].y
   end
end

-- return 'hard' or 'soft' if colliding, false otherwise
-- collisions are prioritized in order: first stack, then other pieces
function Piece:collide()
   if self:collideHard() then return 'hard' end
   if self:collideSoft() then return 'soft' end
   return false
end

-- return whether piece collides with the well or the stack
function Piece:collideHard()
   for _, block in ipairs(self.blocks) do
      local x = self.x + block.x
      local y = self.y + block.y
      
      if x < 1 or x > self.well.width or y < 1 or self.well:get(x, y) then
         return true
      end
   end
   return false
end

-- return whether piece collides with another piece or a line clear
function Piece:collideSoft()
   for _, block in ipairs(self.blocks) do
      local x = self.x + block.x
      local y = self.y + block.y
      
      for _, piece2 in ipairs(self.well.active) do
         if piece2 ~= self then
            for _, block2 in ipairs(piece2.blocks) do
               local x2 = piece2.x + block2.x
               local y2 = piece2.y + block2.y
               if x == x2 and y == y2 then
                  return true
               end
            end
         end
      end

      -- TODO check line clears
   end
   return false
end

-- return what the piece is resting on (what collision occurs if the piece were shifted down one)
function Piece:resting()
   self:move(0, -1)
   local c = self:collide()
   self:move(0, 1)
   return c
end

-- copies blocks into well and removes piece from active list
function Piece:lock()
   for _, block in ipairs(self.blocks) do
      local x = self.x + block.x
      local y = self.y + block.y

      self.well:set(x, y, block)
      block.x = nil
      block.y = nil
   end

   self:remove()
end

-- remove piece from player's and well's active lists
function Piece:remove()
   self.active = false
   
   for i, piece in ipairs(self.player.active) do
      if piece == self then
         table.remove(self.player.active, i)
         break
      end
   end
   
   for i, piece in ipairs(self.well.active) do
      if piece == self then
         table.remove(self.well.active, i)
         break
      end
   end
end


Block = Class()

function Block:init(pos)
   -- offsets from Piece position
   self.x = pos.x
   self.y = pos.y

   -- appearance
   --self.face = nil
end
