--[[

ExtraMapSymbolsUI
Rotators 2021-2022

NOTES

- checkInventory() is called as last when creating childred, and during prerender phase when drawing/erasing status changes
  probably weird place for a hook, but still better than overriding half of TIS UI; as long vars names are unchanged, mod should be fine (famous last words~)
- worldmap and annotated maps symbols ui are different objects, means wm/maps options can be different from each other; bug/feature?

TODO

- crayons
- symbols scaling

KNOWN

- ui is in slightly wrong position on annotated maps; how to check if symbols ui is added to wm or map? and get its size while on it?

]]--

-- main hook --

local ISWMS_checkInventory = ISWorldMapSymbols.checkInventory

function ISWorldMapSymbols:checkInventory()
	self:extraUI_Init()
	self:extraUI_Refresh()
	ISWMS_checkInventory(self)
end

-- core functionality --

local ID = 0;

function ISWorldMapSymbols:extraUI_Init()
	if self.extraUI ~= nil then
		return
	end

	self.extraUI = {}
	self.extraUI.Options = {}

	ID = ID + 1
	self.extraUI.ID = ID

	-- vars --

	self.extraUI.OptionsShown = false
	self.extraUI.Columns = 4
	self.extraUI.Left = false

	-- constants --

	self.extraUI.ParentWidth = self:getX() + self:getWidth() + 20 -- screen width or annotated map window width, there has to be more reliable way to find it...

	self.extraUI.ColumnsMin = 4
	self.extraUI.ColumnsMax = 16

	self.extraUI.ButtonY = 50 -- y position of first color buttons row
	self.extraUI.ButtonSize = 30 -- aka btnHgt2; vanilla: 32
	self.extraUI.ButtonPad = 5 -- space between buttons
	self.extraUI.ColorSize = 27 -- unused [for now?]
	self.extraUI.ToolH = getTextManager():getFontHeight(UIFont.Small) + 2 * 2 -- aka btnHgt
	self.extraUI.MarginXY = 15 -- space between screen edges and symbols ui; vanilla: 20

	-- create options pseudopanel and its visibility toggle --

	self.extraUI.OptionsButton = ISButton:new(0, 0, 0, self.extraUI.ToolH, "Options", self, self.extraUI_Options)
	self:addChild(self.extraUI.OptionsButton)

	local x = self.extraUI.ButtonSize
	local y = self.colorButtons[#self.colorButtons]:getBottom() + self.extraUI.ToolH + 5
	local obj

	obj = ISLabel:new(x, y, self.extraUI.ToolH, "Columns", 1, 1, 1, 1)
	obj:initialise()
	obj:setX(x)
	self:extraUI_Option(obj)
	x = obj:getRight() + 5

	obj = ISButton:new(x, y + 2, 16, 15, "+", self, self.extraUI_ColumnAdd)
	self:extraUI_Option(obj)
	x = obj:getRight() + 5

	obj = ISButton:new(x, y + 2, 16, 15, "-", self, self.extraUI_ColumnDel)
	self:extraUI_Option(obj)

--[[
	-- would make more sense if it would move worldmap buttons as well; disabled for now --

	x = self.extraUI.ButtonSize
	y = y + self.extraUI.ToolH + 3

	obj = ISLabel:new(x, y, self.extraUI.ToolH, "Position", 1, 1, 1, 1)
	obj:initialise()
	obj:setX(x)
	self:extraUI_Option(obj)
	x = obj:getRight() + 5

	obj = ISButton:new(x, y + 2, 16, 15, "<", self, self.extraUI_PositionLeft)
	self:extraUI_Option(obj)
	x = obj:getRight() + 5

	obj = ISButton:new(x, y + 2, 16, 15, ">", self, self.extraUI_PositionRight)
	self:extraUI_Option(obj)
]]--

end

function ISWorldMapSymbols:extraUI_Refresh()
	local x = 0
	local y = 0
	local column = 0
	local w = ((self.extraUI.Columns + 2) * self.extraUI.ButtonSize) + ((self.extraUI.Columns - 1) * self.extraUI.ButtonPad)

	-- pre-resize --

	self:setWidth(w)

	-- process colors --

	x = self.extraUI.ButtonSize
	y = self.extraUI.ButtonY

	for key,val in ipairs(self.colorButtons) do
		val:setX(x)
		val:setY(y)
		val:setWidth(self.extraUI.ButtonSize)
		val:setHeight(self.extraUI.ButtonSize)

		x = val:getRight() + self.extraUI.ButtonPad
	end

	-- process options elements --

	self.extraUI.OptionsButton:setX(self.extraUI.ButtonSize)
	self.extraUI.OptionsButton:setY(self.colorButtons[#self.colorButtons]:getBottom() + 10)
	self.extraUI.OptionsButton:setWidth(self.width - self.extraUI.ButtonSize * 2)

	x = self.extraUI.ButtonSize
	y = self.extraUI.OptionsButton:getBottom() + 10
	column = 0

	for key,val in ipairs(self.extraUI.Options) do
		val:setVisible(self.extraUI.OptionsShown)
		if self.extraUI.OptionsShown then
			y = val:getBottom() + 10
		end
	end

	-- process symbols --

	for key,val in ipairs(self.buttonList) do
		val:setX(x)
		val:setY(y)
		val:setWidth(self.extraUI.ButtonSize)
		val:setHeight(self.extraUI.ButtonSize)

		x = x + self.extraUI.ButtonSize + self.extraUI.ButtonPad
		column = column + 1
		if column == self.extraUI.Columns then
			x = self.extraUI.ButtonSize
			y = y + self.extraUI.ButtonSize + self.extraUI.ButtonPad
			column = 0
		end
	end

	y = self.buttonList[#self.buttonList]:getBottom() + 15

	-- process tools --

	self.addNoteBtn:setX(self.extraUI.ButtonSize)
	self.addNoteBtn:setY(y)
	self.addNoteBtn:setWidth(self.width - self.extraUI.ButtonSize * 2)
	y = y + self.extraUI.ToolH + 10

	self.editNoteBtn:setX(self.extraUI.ButtonSize)
	self.editNoteBtn:setY(y)
	self.editNoteBtn:setWidth(self.width - self.extraUI.ButtonSize * 2)
	y = y + self.extraUI.ToolH + 10

	self.moveBtn:setX(self.extraUI.ButtonSize)
	self.moveBtn:setY(y)
	self.moveBtn:setWidth(self.width - self.extraUI.ButtonSize * 2)
	y = y + self.extraUI.ToolH + 10

	self.removeBtn:setX(self.extraUI.ButtonSize)
	self.removeBtn:setY(y)
	self.removeBtn:setWidth(self.width - self.extraUI.ButtonSize * 2)
	y = y + self.extraUI.ToolH + 15

	-- resize and reposition whole ui --

	if self.extraUI.Left then
		self:setX(self.extraUI.MarginXY)
	else
		self:setX(self.extraUI.ParentWidth - self:getWidth() - self.extraUI.MarginXY)
	end
	self:setY(self.extraUI.MarginXY)
	self:setWidth(w)
	self:setHeight(y)

end

-- options --

function ISWorldMapSymbols:extraUI_Option(element)
	element:setVisible(self.extraUI.OptionsShown)
	self:addChild(element)
	table.insert(self.extraUI.Options, element)
end

function ISWorldMapSymbols:extraUI_Options()
	self.selectedSymbol = nil
	self.extraUI.OptionsShown = not self.extraUI.OptionsShown
	self:extraUI_Refresh()
end

function ISWorldMapSymbols:extraUI_ColumnAdd()
	if self.extraUI.Columns < self.extraUI.ColumnsMax then
		self.extraUI.Columns = self.extraUI.Columns + 1
		self:extraUI_Refresh()
	end
end

function ISWorldMapSymbols:extraUI_ColumnDel()
	if self.extraUI.Columns > self.extraUI.ColumnsMin then
		self.extraUI.Columns = self.extraUI.Columns - 1
		self:extraUI_Refresh()
	end
end

function ISWorldMapSymbols:extraUI_PositionLeft()
	self.extraUI.Left = true
	self:extraUI_Refresh()
end

function ISWorldMapSymbols:extraUI_PositionRight()
	self.extraUI.Left = false
	self:extraUI_Refresh()
end
