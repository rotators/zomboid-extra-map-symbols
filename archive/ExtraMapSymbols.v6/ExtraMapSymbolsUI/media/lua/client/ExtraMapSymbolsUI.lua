--[[

ExtraMapSymbolsUI
Copyright (C) Rotators  2021-2022

TODO

- symbols/text scaling
- crayons addnote/editnote

TWEAKS FOR EXTERNAL MODS

- MapLegendUI : https://steamcommunity.com/sharedfiles/filedetails/?id=2710167561
  toggle legend visibility

]]--

require "ISBaseObject"
require "ISUI/ISButton"
require "ISUI/ISColorPicker"
require "ISUI/ISPanelJoypad"
require "ISUI/ISSpinBox"
require "ISUI/ISTickbox"
require "ISUI/Maps/ISMap"
require "ISUI/Maps/ISWorldMap"
require "ISUI/Maps/ISWorldMapSymbols"

ExtraMapSymbolsUI = ISBaseObject:derive("ExtraMapSymbolsUI")

function ExtraMapSymbolsUI:new()
	local this =
	{
		Crayons = {{ r = 0, g = 0, b = 0 }},
		CrayonsColumns = 1,
		CrayonsRows = 1,

		CONST =
		{
			ColumnsMin = 4,
			ColumnsMax = 16,

			Pad = 5,

			ColorX = 30,
			ColorY = 50,
			ColorSize = 23,

			-- that's beyond stupid, but lua hates my lack of knowledge --

			OptionsButtonX = 30,
			OptionsButtonY = 50 + 23 + 5,
			OptionsButtonH = getTextManager():getFontHeight(UIFont.Small) + 2 * 2,

			SymbolX = 30,
			SymbolY = 50 + 23 + 5 + (getTextManager():getFontHeight(UIFont.Small) + 2 * 2) + 5,
			SymbolSize = 30,

			ToolX = 30,
			ToolH = getTextManager():getFontHeight(UIFont.Small) + 2 * 2,

			MarginXY = 15,

			ScaleJmp = 0.222,
			ScaleNum = 20,
			ScaleMax = -1,
			ScaleMin = -1
		}
	}

	setmetatable(this, self)
	self.__index = self

	return this
end

ExtraMapSymbolsUI = ExtraMapSymbolsUI:new()

---

function ExtraMapSymbolsUI:AddCrayon(rx, gx, bx)
	local rf = rx / 255
	local gf = gx / 255
	local bf = bx / 255

	for idx = #self.Crayons, 1, -1 do
		if self.Crayons[idx].r == rf and self.Crayons[idx].g == gf and self.Crayons[idx].b == bf then
			return
		end
	end

	table.insert( self.Crayons, { r=rf, g=gf, b=bf })

end

function ExtraMapSymbolsUI:DelCrayon(rx, gx, bx)
	local rf = rx / 255
	local gf = gx / 255
	local bf = bx / 255

	for idx = #self.Crayons, 1, -1 do
		if self.Crayons[idx].r == rf and self.Crayons[idx].g == gf and self.Crayons[idx].b == bf then
			table.remove(self.Crayons, idx)
			-- break
		end
	end
end

function ExtraMapSymbolsUI:SetCrayonSize(columns, rows)
	self.CrayonsColumns = columns
	self.CrayonsRows = rows
end

-- main hooks --

local ISWMS_prerender = ISWorldMapSymbols.prerender
function ISWorldMapSymbols:prerender()
	ISWMS_prerender(self)
	self:extraUI_Init()
	self:extraUI_Refresh()
end

local ISWMS_undisplay = ISWorldMapSymbols.undisplay
function ISWorldMapSymbols:undisplay()
	self:extraUI_OptionsHide()
	ISWMS_undisplay(self)
end

local ISM_canWrite = ISMap.canWrite
function ISMap:canWrite()
	local result = ISM_canWrite(self) or self.character:getInventory():contains("Crayons", true)

	return result
end

-- core functionality --

function ISWorldMapSymbols:extraUI_Init()
	if self.extraUI ~= nil then
		return
	end

	-- required to play nice with external mods which might add new buttons --

	if ExtraMapSymbolsUI.CONST.ColumnsMin < #self.colorButtonInfo then
		ExtraMapSymbolsUI.CONST.ColumnsMin = #self.colorButtonInfo
	end

	local const = ExtraMapSymbolsUI.CONST

--- self:extraUI_SetModData("Columns", nil)
	self.extraUI = {
		Columns = PZMath.clamp(self:extraUI_GetModData("Columns") or const.ColumnsMin, const.ColumnsMin, const.ColumnsMax)
	}

	-- create crayons button --

	local crayons = { item="Base.Crayons", colorInfo=ColorInfo.new(ExtraMapSymbolsUI.Crayons[1].r, ExtraMapSymbolsUI.Crayons[1].g, ExtraMapSymbolsUI.Crayons[1].b, 0.9), tooltip=getText("Tooltip_ExtraMapSymbolsUI_NeedCrayons") }
	self.extraUI.CrayonsButton = ISButton:new(0, 0, 0, 0, "", self, self.extraUI_CrayonsShow)
	self.extraUI.CrayonsButton:initialise()
	self.extraUI.CrayonsButton.internal = "COLOR"
	self.extraUI.CrayonsButton.backgroundColor = {r=crayons.colorInfo:getR(), g=crayons.colorInfo:getG(), b=crayons.colorInfo:getB(), a=1}
	self.extraUI.CrayonsButton.borderColor = {r=1, g=1, b=1, a=0.4}
	self.extraUI.CrayonsButton.buttonInfo = crayons

	self.extraUI.CrayonsButton.ColorPicker = ISColorPicker:new(0, 0)
	self.extraUI.CrayonsButton.ColorPicker:initialise()
	self.extraUI.CrayonsButton.ColorPicker.resetFocusTo = self
	self.extraUI.CrayonsButton.ColorPicker.pickedTarget = self
	self.extraUI.CrayonsButton.ColorPicker.pickedFunc = self.extraUI_CrayonsPick
	self.extraUI.CrayonsButton.ColorPicker.backgroundColor = self.backgroundColor
	self.extraUI.CrayonsButton.ColorPicker:setColors(ExtraMapSymbolsUI.Crayons, ExtraMapSymbolsUI.CrayonsColumns, ExtraMapSymbolsUI.CrayonsRows)

	self:addChild(self.extraUI.CrayonsButton)
	table.insert(self.colorButtons, self.extraUI.CrayonsButton)
	table.insert(self.colorButtonInfo, self.extraUI.CrayonsButton.buttonInfo)

	-- create options button and panel; button *must* be somewhere near top to allow changing columns count on lower resolution and/or symbols spam

	self.extraUI.OptionsButton = ISButton:new(0, 0, 0, const.ToolH, "Options", self, self.extraUI_OptionsToggle)
	self:addChild(self.extraUI.OptionsButton)

	local option
	local optionPad = 10
	local options = {}

	self.extraUI.OptionsPanel = ISPanelJoypad:new(0, 0, 100, 100)
	self.extraUI.OptionsPanel:initialise()
	self.extraUI.OptionsPanel.backgroundColor = self.backgroundColor

	option = ISSpinBox:new(0, 0, 100, const.ToolH, self, self.extraUI_ColumnsSet)
	option:initialise()
	for count = const.ColumnsMin, const.ColumnsMax, 1 do
		option:addOption( "Columns" )
	end
	option.selected = self.extraUI.Columns + 1 - const.ColumnsMin

	self.extraUI.OptionsPanel:addChild(option)
	table.insert(options, option)

	if ActiveMods.getById("currentGame"):isModActive("MapLegendUI") and self:getParent().mapLegendWindow ~= nil then -- https://steamcommunity.com/sharedfiles/filedetails/?id=2710167561
		option = ISTickBox:new(0, 0, 100, const.ToolH, "", self, self.extraUI_LegendToggle)
		option:initialise()
		option:addOption("Hide legend")
		self.extraUI.OptionsPanel:addChild(option)
		table.insert(options, option)
	end

	-- automagically reposition all option elements and resize options panel, just for fun --

	local w = 0
	local y = optionPad

	for key,val in ipairs(options) do
		w = math.max(w, val:getWidth())

		val:setX(optionPad)
		val:setY(y)

		y = y + val:getHeight() + optionPad
	end

	self.extraUI.OptionsPanel:setWidth(w + optionPad * 2)
	self.extraUI.OptionsPanel:setHeight(y)
	self.extraUI.OptionsPanel.Attach = false
end

-- this function is currently being called waaay too often for what it does... --
function ISWorldMapSymbols:extraUI_Refresh()

	local const = ExtraMapSymbolsUI.CONST
	local column = 0

	-- pre-resize --

	local w = ((self.extraUI.Columns + 2) * const.SymbolSize) + ((self.extraUI.Columns - 1) * const.Pad)
	self:setWidth(w)

	-- process colors --

	x = self:getWidth() / 2 - (#self.colorButtons * const.ColorSize + (#self.colorButtons - 1) * const.Pad) / 2
	y = const.ColorY

	for key,val in ipairs(self.colorButtons) do
		val:setX(x)
		val:setY(y)
		val:setWidth(const.ColorSize)
		val:setHeight(const.ColorSize)

		x = val:getRight() + const.Pad
	end

	-- process options button --

	self.extraUI.OptionsButton:setX(const.OptionsButtonX)
	self.extraUI.OptionsButton:setY(const.OptionsButtonY)
	self.extraUI.OptionsButton:setWidth(self:getWidth() - const.SymbolSize * 2)

	-- process symbols --

	x = const.SymbolX
	y = const.SymbolY

	for key,val in ipairs(self.buttonList) do
		val:setX(x)
		val:setY(y)
		val:setWidth(const.SymbolSize)
		val:setHeight(const.SymbolSize)

		x = val:getRight() + const.Pad
		column = column + 1
		if column == self.extraUI.Columns then
			x = const.SymbolX
			y = val:getBottom() + const.Pad
			column = 0
		end
	end

	-- process tools --

	x = const.ToolX
	y = self.buttonList[#self.buttonList]:getBottom() + const.Pad * 2

	self.addNoteBtn:setX(x)
	self.addNoteBtn:setY(y)
	self.addNoteBtn:setWidth(self:getWidth() - const.ToolX * 2)
	y = self.addNoteBtn:getBottom() + const.Pad

	self.editNoteBtn:setX(x)
	self.editNoteBtn:setY(y)
	self.editNoteBtn:setWidth(self:getWidth() - const.ToolX * 2)
	y = self.editNoteBtn:getBottom() + const.Pad

	self.moveBtn:setX(x)
	self.moveBtn:setY(y)
	self.moveBtn:setWidth(self:getWidth() - const.ToolX * 2)
	y = self.moveBtn:getBottom() + const.Pad

	self.removeBtn:setX(x)
	self.removeBtn:setY(y)
	self.removeBtn:setWidth(self:getWidth() - const.ToolX * 2)
	y = self.removeBtn:getBottom() + const.Pad

	-- resize and reposition whole ui --

	y = y + const.Pad * 2

	if self:getParent() ~= nil then
		self:setX(self:getParent():getWidth() - self:getWidth() - const.MarginXY)
	end

	self:setY(const.MarginXY)
	self:setWidth(w)
	self:setHeight(y)

	self.extraUI.OptionsPanel:setX(self:getX() - self.extraUI.OptionsPanel:getWidth() - const.MarginXY / 2)
	self.extraUI.OptionsPanel:setY(self:getY())
end

-- options --

function ISWorldMapSymbols:extraUI_GetModData(name)
	return getPlayer():getModData()["ExtraMapSymbolsUI:" .. name]
end

function ISWorldMapSymbols:extraUI_SetModData(name, value)
	getPlayer():getModData()["ExtraMapSymbolsUI:" .. name] = value
end

function ISWorldMapSymbols:extraUI_OptionsToggle()
	self.selectedSymbol = nil
	self:setCurrentTool(nil)

	self.extraUI.OptionsPanel.Attach = not self.extraUI.OptionsPanel.Attach

	if self.extraUI.OptionsPanel.Attach then
		self:getParent():addChild(self.extraUI.OptionsPanel)
	else
		self:getParent():removeChild(self.extraUI.OptionsPanel)
	end
end

function ISWorldMapSymbols:extraUI_OptionsHide()
	if not self.extraUI then
		return
	end

	if self.extraUI.OptionsPanel.Attach then
		self.extraUI.OptionsPanel.Attach = not self.extraUI.OptionsPanel.Attach
		self:getParent():removeChild(self.extraUI.OptionsPanel)
	end
end

function ISWorldMapSymbols:extraUI_ColumnsSet(spinbox)
	self.extraUI.Columns = ExtraMapSymbolsUI.CONST.ColumnsMin + spinbox.selected - 1
	self:extraUI_SetModData("Columns", self.extraUI.Columns)
	self:extraUI_Refresh()
end

function ISWorldMapSymbols:extraUI_LegendToggle() -- https://steamcommunity.com/sharedfiles/filedetails/?id=2710167561
	if self:getParent().mapLegendWindow == nil then
		return
	end

	self.selectedSymbol = nil
	self:setCurrentTool(nil)

	local visible = not self:getParent().mapLegendWindow:isVisible()
	self:getParent().mapLegendWindow:setVisible(visible)
end

-- crayons --

function ISWorldMapSymbols:extraUI_CrayonsShow(button)
	self.selectedSymbol = nil
	self:setCurrentTool(nil)

	self:removeChild(self.extraUI.CrayonsButton.ColorPicker)
	self.extraUI.CrayonsButton.ColorPicker:setX(button:getX() - self.extraUI.CrayonsButton.ColorPicker:getWidth() - ExtraMapSymbolsUI.CONST.Pad)
	self.extraUI.CrayonsButton.ColorPicker:setY(button:getY())
	self:addChild(self.extraUI.CrayonsButton.ColorPicker)
end

function ISWorldMapSymbols:extraUI_CrayonsPick(color, mouseUp)
	if color == nil then
		return
	end

	self.selectedSymbol = nil
	self:setCurrentTool(nil)

	self.extraUI.CrayonsButton.buttonInfo.colorInfo = ColorInfo.new(color.r, color.g, color.b, 0.9)
	self.extraUI.CrayonsButton.backgroundColor = {r=color.r, g=color.g, b=color.b, a=1}

	self:checkInventory()
	self:onButtonClick(self.extraUI.CrayonsButton)
end

---

--[[
    local icon = item.item:getIcon()
    if item.item:getIconsForTexture() and not item.item:getIconsForTexture():isEmpty() then
        icon = item.item:getIconsForTexture():get(0)
    end
    if icon then
        local texture = getTexture("Item_" .. icon)
        if texture then
            self:drawTextureScaledAspect2(texture, self.columns[2].size + iconX, y + (self.itemheight - iconSize) / 2, iconSize, iconSize,  1, 1, 1, 1);
        end
    end
]]--
