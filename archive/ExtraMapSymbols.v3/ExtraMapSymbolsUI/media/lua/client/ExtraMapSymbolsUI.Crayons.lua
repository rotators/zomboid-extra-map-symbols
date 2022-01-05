require "ExtraMapSymbolsUI"

-- changes to crayons list must be done before player uses worldmap/map item for a first time; later changes require editing ISColorPicker list --

-- remove default color, if still present --
-- in case all crayons colors should be removed, use ExtraMapSymbolsUI.Crayons = {}
ExtraMapSymbolsUI:DelCrayon(0, 0, 0)

--[[
     Magic Scent Crayons

     In 1994, Crayola produced a 16-pack of crayons that released fragrances when used. In 1995, Crayola changed some of the scents because of
     complaints received from parents that some of the crayons smelled good enough to eat, like the Cherry, Chocolate, and Blueberry scented crayons.
     Crayons with food scents were retired in favor of non-food scents. The 30 crayons all consisted of regular Crayola colors.

     https://en.wikipedia.org/wiki/List_of_Crayola_crayon_colors#Magic_Scent_Crayons
]]--

ExtraMapSymbolsUI:AddCrayon(0xFF, 0xFF, 0xFF) -- Baby Powder (White) --
ExtraMapSymbolsUI:AddCrayon(0xFE, 0xD8, 0x5D) -- Banana (Dandelion) --
--ExtraMapSymbolsUI:AddCrayon(0x45, 0x70, 0xE6) -- Blueberry (Blue (II)) --
ExtraMapSymbolsUI:AddCrayon(0xFC, 0x80, 0xA5) -- Bubble Gum (Tickle Me Pink) --
--ExtraMapSymbolsUI:AddCrayon(0xCA, 0x34, 0x35) -- Cedar Chest (Mahogany) --
--ExtraMapSymbolsUI:AddCrayon(0xC3, 0x21, 0x48) -- Cherry (Maroon) --
--ExtraMapSymbolsUI:AddCrayon(0xAF, 0x59, 0x3E) -- Chocolate (Brown) --
--ExtraMapSymbolsUI:AddCrayon(0xFF, 0xFF, 0xFF) -- Coconut (White) --
--ExtraMapSymbolsUI:AddCrayon(0xFB, 0xE8, 0x70) -- Daffodil (Yellow) --
ExtraMapSymbolsUI:AddCrayon(0x9E, 0x5B, 0x40) -- Dirt (Sepia) --
--ExtraMapSymbolsUI:AddCrayon(0x29, 0xAB, 0x87) -- Eucalyptus (Jungle Green) --
ExtraMapSymbolsUI:AddCrayon(0x76, 0xD7, 0xEA) -- Fresh Air (Sky Blue) --
ExtraMapSymbolsUI:AddCrayon(0x83, 0x59, 0xA3) -- Grape (Violet) --
ExtraMapSymbolsUI:AddCrayon(0xFF, 0x88, 0x33) -- Jelly Bean (Orange) --
--ExtraMapSymbolsUI:AddCrayon(0x00, 0x00, 0x00) -- Leather Jacket (Black) --
--ExtraMapSymbolsUI:AddCrayon(0xFB, 0xE8, 0x80) -- Lemon (Yellow) --
--ExtraMapSymbolsUI:AddCrayon(0x00, 0x00, 0x00) -- Licorice (Black) --
ExtraMapSymbolsUI:AddCrayon(0xC9, 0xA0, 0xDC) -- Lilac (Wisteria) --
ExtraMapSymbolsUI:AddCrayon(0xC5, 0xE1, 0x7A) -- Lime(Yellow Green) --
--ExtraMapSymbolsUI:AddCrayon(0xFD, 0xD5, 0xB1) -- Lumber (Apricot) --
--ExtraMapSymbolsUI:AddCrayon(0x00, 0x66, 0xFF) -- New Car (Blue (III)) ---
--ExtraMapSymbolsUI:AddCrayon(0xFF, 0x88, 0x33) -- Orange --
--ExtraMapSymbolsUI:AddCrayon(0xFF, 0xCB, 0xA4) -- Peach --
ExtraMapSymbolsUI:AddCrayon(0x01, 0x78, 0x6F) -- Pine (Pine Green) --
--ExtraMapSymbolsUI:AddCrayon(0xED, 0x0A, 0x3F) -- Rose (Red) --
--ExtraMapSymbolsUI:AddCrayon(0xFF, 0xA6, 0xC9) -- Shampoo (Carnation Pink) --
--ExtraMapSymbolsUI:AddCrayon(0x8B, 0x86, 0x80) -- Smoke (Gray) --
ExtraMapSymbolsUI:AddCrayon(0xC3, 0xCD, 0xE6) -- Soap (Periwinkle) --
ExtraMapSymbolsUI:AddCrayon(0xFF, 0x33, 0x99) -- Strawberry (Wild Strawberry) --
--ExtraMapSymbolsUI:AddCrayon(0xFF, 0x88, 0x33)  -- Tulip (Orange) --

ExtraMapSymbolsUI:SetCrayonSize(4, 3) -- ISColorPicker columns and rows --
