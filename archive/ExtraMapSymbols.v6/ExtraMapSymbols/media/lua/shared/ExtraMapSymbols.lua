-- if you brainlessly copypaste this, at least change symbol/texture prefix; you know who you are --

local function map_symbol(name)
    MapSymbolDefinitions.getInstance():addTexture("extra:" .. name, "media/ui/ExtraMapSymbols/" .. name .. ".png")
end

-- four icons per row --

map_symbol("water")
map_symbol("food")
map_symbol("pills")
map_symbol("book")

map_symbol("pistol")
map_symbol("ammo")
map_symbol("sledge")
map_symbol("sheriff")

map_symbol("medic")
map_symbol("heart")
map_symbol("shirt")
map_symbol("vhs")

map_symbol("fuel")
map_symbol("car")
map_symbol("truck")
map_symbol("fuel2")

map_symbol("helicopter")
map_symbol("parachute")
map_symbol("boat")
map_symbol("marine")

map_symbol("helmet")
map_symbol("loot")
map_symbol("bed")
map_symbol("meet")

map_symbol("school")
map_symbol("warehouse")
map_symbol("tent")
map_symbol("cross")

map_symbol("axe")
map_symbol("axe2")
map_symbol("fire")
map_symbol("radioactive")

map_symbol("wrench")
--map_symbol("placeholder1")
--map_symbol("placeholder2")
--map_symbol("placeholder3")

map_symbol("line1")
map_symbol("line2")
map_symbol("line3")
map_symbol("line4")

map_symbol("arrow4")
map_symbol("arrow1")
map_symbol("arrow3")
map_symbol("arrow2")

map_symbol("dot")
map_symbol("x_small")
map_symbol("trashpanda") -- "We need Spiffo lol"  "That one would need to be made by someone who had art class, so not me"
