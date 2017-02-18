
Game = Class()

function Game:init()
   self.wells = {}
   self.players = {}
end

function Game:addWell(...)
   table.insert(self.wells, Well(self, ...))
end

function Game:addPlayer(...)
   table.insert(self.players, Player(self, ...))
end

function Game:copy()
   return table.deepcopy(self)
end


Player = Class()

function Player:init(game)
   self.game = game
   self.input = {}  -- {left=bool, cw=bool, ...}
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

function Well:spawn(player, piecedata)
   local p = Piece(player, self, piecedata)
   table.insert(self.active, p)
   return p
end


Piece = Class()

function Piece:init(player, well, data)
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

-- return 'wall', 'stack', or 'piece' if colliding, false otherwise
function Piece:collide()
   for _, block in ipairs(self.blocks) do
      local x = self.x + block.x
      local y = self.y + block.y
      
      if x < 1 or x > self.well.width then
         return 'wall'
      end
      if y < 1 or self.well:get(x, y) then
         return 'stack'
      end
      
      for _, piece2 in ipairs(self.well.active) do
         if piece2 ~= self then
            for _, block2 in ipairs(piece2.blocks) do
               local x2 = piece2.x + block2.x
               local y2 = piece2.y + block2.y
               if x == x2 and y == y2 then
                  return 'piece'
               end
            end
         end
      end
   end
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
