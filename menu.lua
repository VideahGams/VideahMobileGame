menu = {}

function menu.load()

	menu.title = "Untitled Android Game"
	menu.titleimage = "data/images/videahenginelogo.png"
	menu.titletype = "text"
	menu.color = {236,240,241}

	menu.image = "data/images/menubg.png"
	menu.options = {"Start", "Quit"}
	menu.optionsstate = {"game", "quit"}

	menu.type = "color"
	menu.scrolldirection = "left"
	menu.scrollspeed = 50

	menu.InternalVariables()

	menu.GenerateMenuFrame()

	print("Loaded menu system ...")

end

function menu.draw()

	menu.GenerateBackground()
	menu.Generatetitle()

end

function menu.update(dt)

	menu.CalculateScrolling(dt)

end

function menu.GenerateBackground()

	if menu.type == "tiled" then

		menu.image:setWrap('repeat', 'repeat')
		menu.bgQuad = love.graphics.newQuad( 0, 0, global.screenWidth, global.screenHeight, menu.image:getHeight(), menu.image:getWidth() )
		love.graphics.draw( menu.image, menu.bgQuad, 0, 0)

	elseif menu.type == "fill" then

		--TODO: Add code for more types of menu backgrounds.

	elseif menu.type == "scrolling_tiled" then

		menu.image:setWrap('repeat', 'repeat')
		menu.bgQuad = love.graphics.newQuad( menu.bgOffset, 0, global.screenWidth, global.screenHeight, menu.image:getHeight(), menu.image:getWidth() )
		love.graphics.draw( menu.image, menu.bgQuad, 0, 0)

	elseif menu.type == "color" then

		love.graphics.setColor(menu.color)
		love.graphics.rectangle( "fill", 0, 0, global.screenWidth, global.screenHeight )
		love.graphics.setColor(255, 255, 255)

	end
end

function menu.Generatetitle()

	if menu.titletype == "text" then

		love.graphics.setColor(44, 62, 80)

		love.graphics.setFont(font.menutitle)

		love.graphics.printf(menu.title, 0, global.screenHeight / 10, global.screenWidth, 'center')

		love.graphics.setFont(font.default)

		love.graphics.setColor(255, 255, 255)
	end

	if menu.titletype == "image" then

		love.graphics.draw(menu.titleimage, (global.screenWidth / 2) - (menu.titleimage:getWidth() / 2), 0)

	end

end

function menu.GenerateMenuFrame()

	button = {}
	buttonStartPos = (global.screenHeight / 2) - (62 * #menu.options)

	for i=1, #menu.options do

		ui.createButton(menu.options[i], (global.screenWidth / 2) - 145, buttonStartPos, 290, 100, nil, function() state:changeState(menu.optionsstate[i]) end)
		buttonStartPos = buttonStartPos + 125

	end

end

function menu.CalculateScrolling(dt)

	if menu.type == "scrolling_tiled" then
		if menu.scrolldirection == "left" then

			menu.bgOffset = menu.bgOffset + menu.scrollspeed * dt

		elseif menu.scrolldirection == "right" then

			menu.bgOffset = menu.bgOffset - menu.scrollspeed * dt

		end
	end
end



function menu.InternalVariables()

	menu.image = love.graphics.newImage( menu.image )
	menu.titleimage = love.graphics.newImage( menu.titleimage )
	menu.bgOffset = 0

end