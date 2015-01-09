ui = {}
ui.buttonlist = {}
ui.checkboxlist = {}

function ui.createButton(text, x, y, width, height, color, func, state)

	if text == nil then text = "Text" end
	if x == nil then x = 0 end
	if y == nil then y = 0 end
	if width == nil then width = 200 end
	if height == nil then height = 50 end
	if color == nil then color = {255, 255, 255} end
	if func == nil then func = function() end end
	if state == nil then state = "all" end

	local button = {text, x, y, width, height, color, func, state}

	table.insert(ui.buttonlist, button)

	util.dprint("Created UI object 'button'")

end

function ui.createCheckbox(text, x, y, width, height, color, boolean, state)

	if text == nil then text = "Text" end
	if x == nil then x = 0 end
	if y == nil then y = 0 end
	if width == nil then width = 50 end
	if height == nil then height = 50 end
	if color == nil then color = {255, 255, 255} end
	if boolean == nil then boolean = false
	if state == nil then state = "all" end

	local checkbox {text, x, y, width, height, color, boolean, state}

	table.insert(ui.checkboxlist, checkbox)

	util.dprint("Created UI object 'checkbox'")

end

function ui.draw()

	for i=1, #ui.buttonlist do

		if ui.getState(i) == state:getState() or ui.getState(i) == "all" then

			love.graphics.setColor(ui.buttonlist[i][6] or 255,255,255)

			util.drawRoundedRectangle("fill", ui.getX(i), ui.getY(i), ui.getWidth(i), ui.getHeight(i), 10, 25)

			love.graphics.setColor(255, 255, 255)

			love.graphics.setFont(font.buttontext)

			love.graphics.printf(ui.getText(i), ui.getX(i) + (ui.getWidth(i) / 2), ui.getY(i) + (ui.getHeight(i) / 2) - (font.buttontext:getHeight() / 2), 0, "center")

			if global.debug then -- DEBUG: Draws button ID number to help with debugging.

				love.graphics.setFont(font.default)

				love.graphics.print(i, ui.getX(i) + 10, ui.getY(i) + 10)

			end

		end

	end

end

function ui.touchpressed(id, x, y, pressure)

	local cx = x * love.graphics.getWidth()
	local cy = y * love.graphics.getHeight()

	for i=1, #ui.buttonlist do

		if ui.getState(i) == state:getState() or ui.getState(i) == "all" then

			local uix = ui.getX(i)
			local uiy = ui.getY(i)

			local uiw = ui.getWidth(i)
			local uih = ui.getHeight(i)

			if x >= uix and x <= uix + uiw and y >= uiy and y <= uiy + uih then -- Oh god is this messy or what?
				ui.buttonlist[i][7]()
			end

		end

	end

end

function ui.mousepressed(x, y, button)

	if button == "l" then

		for i=1, #ui.buttonlist do

			if ui.getState(i) == state:getState() or ui.getState(i) == "all" then

				local uix = ui.getX(i)
				local uiy = ui.getY(i)

				local uiw = ui.getWidth(i)
				local uih = ui.getHeight(i)

				if x >= uix and x <= uix + uiw and y >= uiy and y <= uiy + uih then -- Yep, still messy.
					ui.buttonlist[i][7]()
				end

			end

		end

	end

end

-- Get functions --

function ui.getText(id)

	return ui.buttonlist[id][1]

end

function ui.getX(id)

	return ui.buttonlist[id][2]

end

function ui.getY(id)

	return ui.buttonlist[id][3]

end

function ui.getWidth(id)


	return ui.buttonlist[id][4]

end

function ui.getHeight(id)

	return ui.buttonlist[id][5]

end

function ui.getColor(id)

	return ui.buttonlist[id][6]

end

function ui.getFunction(id)

	return ui.buttonlist[id][7]

end

function ui.getState(id)

	return ui.buttonlist[id][8]

end

-- Set functions --

function ui.setText(id, text)

	ui.buttonlist[id][1] = text

end

function ui.setX(id, x)

	ui.buttonlist[id][2] = x

end

function ui.setY(id, y)

	ui.buttonlist[id][3] = y

end

function ui.setWidth(id, width)

	ui.buttonlist[id][4] = width

end

function ui.setHeight(id, height)

	ui.buttonlist[id][5] = height

end

function ui.setColor(id, color)

	ui.buttonlist[id][6] = color

end

function ui.setFunction(id, func)

	ui.buttonlist[id][7] = func

end

function ui.setState(id, state)

	ui.buttonlist[id][8] = state

end