
local C = Class()

--[[ update()
   called once per frame
   reads player inputs, advances the game state
]]

--[[ getnextpiece(player)
   sets player.nextpiece to the data to use to spawn
]]

function C:post_getnextpiece(player)
   assert(player.nextpiece, 'getnextpiece didn\'t set player.nextpiece')
end

--[[ paintpiece(piece)
   set the appearance of the piece
]]

return C
