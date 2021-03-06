--local _Debug table for holding all variables
local _Debug = {
	errors = {},
	prints = {},
	order = {},
	orderOffset = 0,
	longestOffset = 0,

	drawOverlay = false,
	tickTime = 0.5,
	tick = 0.5,
	drawTick = true,

	input = "",
	inputMarker = 0,

	lastH = nil,
	lastCut = nil,
	lastRows = 1,

	history = {''},
	historyIndex = 1,

	Font = love.graphics.newFont("game/data/fonts/consola.ttf", 17),
	BigFont = love.graphics.newFont(24),
	Proposals = {},
	ProposalLocation = _G;
	Proposal_String = "",
	
	trackKeys = {},
	keyRepeatInterval = 0.05,
	keyRepeatDelay = 0.4,
	
	liveOutput='',
	liveLastModified=love.filesystem.getLastModified('main.lua'),
	liveDo=false
}

--Settings
_DebugSettings = {
	MultipleErrors = false,
	OverlayColor = {0, 0, 0},
	
	LiveAuto = false,
	LiveFile = 'main.lua',
	LiveReset = false
}


--Print all settings
_DebugSettings.Settings = function()
	print("Settings:")

	print("   _DebugSettings.MultipleErrors  [Boolean]  Controls if errors should appear multiple times, default is false")
	print("   _DebugSettings.OverlayColor  [{int, int, int}]  Sets the color of the overlay, default is {0,0,0}")
	print("   _DebugSettings.LiveAuto  [Boolean]  Check if the code should be reloaded when it's modified, default is false")
	print("   _DebugSettings.LiveFile  [String]  Sets the file that lovedebug reloads, default is 'main.lua'")
	print("   _DebugSettings.LiveReset  [Boolean]  Rather or not love.run() should be reloaded if the code is HotSwapped, default is false")
end




local super_print = print

--Override print and call super
_G["print"] = function(...)
	super_print(...)
	local str = {}
	for i = 1, select('#', ...) do
		str[i] = tostring(select(i, ...))
	end
	table.insert(_Debug.prints, table.concat(str, "       "))
	table.insert(_Debug.order, "p" .. tostring(#_Debug.prints))
end


--Error catcher
_Debug.handleError = function(err)
	if _DebugSettings.MultipleErrors == false then
		for i,v in pairs(_Debug.errors) do
			if v == err then
				return --Don't print the same error multiple times!
			end
		end
	end
	table.insert(_Debug.errors, err)
	table.insert(_Debug.order, "e" .. tostring(#_Debug.errors))
end


--Get Linetype
_Debug.lineInfo = function(str)
	local prefix = string.sub(str, 1, 1)
	local err = (prefix == "e")
	local index = tonumber(str:sub(2))
	return err, index
end


--Overlay drawer
_Debug.overlay = function()
	local font = love.graphics.getFont()
	local r, g, b, a = love.graphics.getColor()

	local fontSize = _Debug.Font:getHeight()
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	local R, G, B = unpack(_DebugSettings.OverlayColor)
	love.graphics.setColor(R, G, B, 200)
	love.graphics.rectangle("fill", 0, 0, w, h)
	love.graphics.setColor(255, 255, 255)
	love.graphics.setFont(_Debug.Font)
	local count = 0
	local cutY = 0
	if h ~= _Debug.lastH then --Did the height of the window change?
		local _cutY = h - 40
		cutY = _cutY
		local rows = 0
		while rows * (fontSize + 2) < _cutY do --Find out how long the scissor should be
			rows = rows + 1
			cutY = rows * (fontSize + 2)
		end
		_Debug.lastRows = rows
	else
		cutY = _Debug.lastCut --Use the last good value
	end
	love.graphics.setScissor(0, 0, w, cutY + 1)
	local drawing_length = #_Debug.order
	if 1 + _Debug.orderOffset + _Debug.lastRows < drawing_length then
		drawing_length = 1 + _Debug.orderOffset + _Debug.lastRows
	end
	for i = 1 + _Debug.orderOffset, drawing_length do
		count = count + 1
		local v = _Debug.order[i]
		local x = 5
		local y = (fontSize + 2) * count
		local err, index = _Debug.lineInfo(v) --Obtain message and type
		local msg = err and _Debug.errors[index] or _Debug.prints[index]
		if err then --Add a red and fancy prefix
			love.graphics.setColor(255, 0, 0)
			love.graphics.print("[Error]", x, y)
			x = _Debug.Font:getWidth("[Error]") + 5
		end
		love.graphics.setColor(255, 255, 255)
		love.graphics.print(msg, x, y)
	end
	love.graphics.setScissor()
	love.graphics.print(">", 6, h - 27)
	local input_prefix = _Debug.input:sub(1, _Debug.inputMarker)
	local input_prefix_width = _Debug.Font:getWidth(input_prefix)
	local autocomplete_width = 0
	local input_suffix = _Debug.input:sub(_Debug.inputMarker + 1)
	if #_Debug.Proposals > 0 then
		autocomplete_width = _Debug.Font:getWidth(_Debug.Proposals[_Debug.proposaltoenter])
		local proposal_prefix_width = _Debug.Font:getWidth(_Debug.Proposal_String)
		love.graphics.setColor(127, 127, 127)
		love.graphics.print(_Debug.Proposals[_Debug.proposaltoenter], 20 + input_prefix_width, h - 27)
		love.graphics.setColor(70, 70, 70)
		for i = math.max(_Debug.proposaltoenter - 1, 1), math.min(_Debug.proposaltoenter + 1, #_Debug.Proposals) do
			if i ~= _Debug.proposaltoenter then
				local index = i - _Debug.proposaltoenter
				love.graphics.print(_Debug.Proposal_String .. _Debug.Proposals[i], 20 + input_prefix_width - proposal_prefix_width, h - 27 - (fontSize - 1) * index)
			end
		end
		love.graphics.setColor(255, 255, 255)
	end
	if _Debug.drawTick then
		love.graphics.print("_", 20 + input_prefix_width, h - 27)
	end
	love.graphics.print(input_prefix, 20, h - 27)
	love.graphics.print(input_suffix, 20 + input_prefix_width + autocomplete_width, h - 27)
	if (#_Debug.order - _Debug.longestOffset > _Debug.lastRows - 1) then
		love.graphics.setFont(_Debug.BigFont)
		love.graphics.print("...", w - 30, h - 30)
	end
	love.graphics.setColor(r, g, b, a)
	if font then love.graphics.setFont(font) end
	_Debug.lastCut = cutY
	_Debug.lastH = h
end

--Handle Mousepresses
_Debug.handleMouse = function(a, b, c)
	if c == "wd" and _Debug.orderOffset < #_Debug.order - _Debug.lastRows + 1 then
		_Debug.orderOffset = _Debug.orderOffset + 1
		if _Debug.orderOffset > _Debug.longestOffset then
			_Debug.longestOffset = _Debug.orderOffset
		end
	end
	if c == "wu" and _Debug.orderOffset > 0 then
		_Debug.orderOffset = _Debug.orderOffset - 1
	end
	if c == "m" and love.keyboard.isDown('lctrl') and _Debug.orderOffset < #_Debug.order - _Debug.lastRows + 1 then
		 _Debug.orderOffset = #_Debug.order - _Debug.lastRows + 1
	end
end

--Process Keypresses
_Debug.keyConvert = function(key)
	if string.len(key)==1 then
		-- No special characters.
		_Debug.inputMarker = _Debug.inputMarker + 1
		_Debug.tick = 0
		_Debug.drawTick = false
		return key
	elseif key == "left" then
		if _Debug.inputMarker > 0 then
			_Debug.inputMarker = _Debug.inputMarker - 1
			_Debug.tick = 0
			_Debug.drawTick = false
		end
	elseif key == "right" then
		if _Debug.inputMarker < #_Debug.input then
			_Debug.inputMarker = _Debug.inputMarker + 1
			_Debug.tick = 0
			_Debug.drawTick = false
		end
	elseif key == "up" then
		if #_Debug.Proposals > 0 and not love.keyboard.isDown('lshift', 'rshift') then
			_Debug.proposaltoenter = _Debug.proposaltoenter % #_Debug.Proposals + 1
			_Debug.resetProposals = false
		else 
			if _Debug.historyIndex > 1 then
				if _Debug.historyIndex == #_Debug.history then
					_Debug.history[_Debug.historyIndex] = _Debug.input
				end
				_Debug.historyIndex = _Debug.historyIndex - 1
				_Debug.input = _Debug.history[_Debug.historyIndex]
				_Debug.inputMarker = #_Debug.input
				_Debug.tick = 0
				_Debug.drawTick = false
			end
		end
	elseif key == "down" then
		if #_Debug.Proposals > 0 and not love.keyboard.isDown('lshift', 'rshift') then
			_Debug.proposaltoenter = (_Debug.proposaltoenter - 2) % #_Debug.Proposals + 1
			_Debug.resetProposals = false
		else 
			if _Debug.historyIndex < #_Debug.history then
				_Debug.historyIndex = _Debug.historyIndex + 1
				_Debug.input = _Debug.history[_Debug.historyIndex]
				_Debug.inputMarker = #_Debug.input
				_Debug.tick = 0
				_Debug.drawTick = false
			end
		end
	elseif key == "backspace" then
		local suffix = _Debug.input:sub(_Debug.inputMarker + 1, #_Debug.input)
		if _Debug.inputMarker == 0 then --Keep the input from copying itself
			suffix = ""
		end
		_Debug.input = _Debug.input:sub(1, _Debug.inputMarker - 1) .. suffix
		if _Debug.inputMarker > 0 then
			_Debug.inputMarker = _Debug.inputMarker - 1
			_Debug.tick = 0
			_Debug.drawTick = false
		end
	elseif key == 'f5' then
		_Debug.liveDo=true
	elseif key == "return" then --Execute Script
		print("> " .. _Debug.input)
		_Debug.history[#_Debug.history] = _Debug.input
		table.insert(_Debug.history, '')
		_Debug.historyIndex = #_Debug.history

		local f, err = loadstring(_Debug.input)
		if f then
			f, err = pcall(f)
		end
		if not f then
			local sindex = 16 + #_Debug.input
			if sindex > 63 then
				sindex = 67
			end
			_Debug.handleError(err:sub(sindex))
		end
		_Debug.input = ""
		_Debug.inputMarker = 0
		if _Debug.orderOffset < #_Debug.order - _Debug.lastRows + 1 then
			_Debug.orderOffset = #_Debug.order - _Debug.lastRows + 1
		end
		_Debug.tick = 0
		_Debug.drawTick = false
	elseif key == "home" then
		_Debug.inputMarker = 0
		_Debug.tick = 0
		_Debug.drawTick = false
	elseif key == "end" then
		_Debug.inputMarker = #_Debug.input
		_Debug.tick = 0
		_Debug.drawTick = false
	elseif key == "tab" and #_Debug.Proposals > 0 then
		_Debug.input = _Debug.input:sub(1, _Debug.inputMarker) .. _Debug.Proposals[_Debug.proposaltoenter] .. _Debug.input:sub(_Debug.inputMarker + 1)
		_Debug.inputMarker = _Debug.inputMarker + #_Debug.Proposals[_Debug.proposaltoenter]
		_Debug.tick = 0
		_Debug.drawTick = false
	else
		_Debug.resetProposals = false
	end
end

local _kwList = {'and', 'break', 'do', 'else', 'elseif', 'end', 'false', 'for',
	'function', 'if', 'in', 'local', 'nil', 'not', 'or', 'repeat', 'return',
	'then', 'true', 'until', 'while'}
_Debug.updateProposals = function(Table)
	local str = _Debug.Proposal_String
	local len = #str
	_Debug.Proposals = {}
	if Table == _G and str == '' then
		return
	end
	for k, v in pairs(Table) do
		if type(k) == 'string' and k:match '[_a-zA-Z][_a-zA-Z0-9]*' then
			if k:sub(1, len) == str then
				table.insert(_Debug.Proposals, k:sub(len + 1, #k))
			end
		end
	end
	if Table == _G then
		for i, kw in pairs(_kwList) do
			if kw:sub(1, len) == str then
				table.insert(_Debug.Proposals, kw:sub(len + 1, #kw))
			end
		end
	end
	_Debug.proposaltoenter = 2
	if #_Debug.Proposals < 2 then
		_Debug.proposaltoenter = 1
	end
end

_Debug.checkChars = function(str, chars)
	for i = 1, #str do
		local char = str:sub(i, i)
		local match = false
		for x = 1, #chars do
			local char2 = chars:sub(x, x)
			if char == char2 then
				match = true
			end
		end
		if match == false then
			return false
		end
	end
	return true
end

_Debug.findLocation = function(str)
	local name
	local path = {}
	local str, dot, lastname = str:match '(.-)%s*([.:]?)%s*([_a-zA-Z]?[_a-zA-Z0-9]*)$'

	while dot ~= '' do
		str, dot, name = str:match '(.-)%s*(%.?)%s*([_a-zA-Z][_a-zA-Z0-9]*)$'
		if not str then
			break
		end
		path[#path + 1] = name
	end

	local curTable = _G
	for i = #path, 1, -1 do
		curTable = rawget(curTable, path[i])
		if type(curTable) ~= 'table' then
			_Debug.ProposalLocation = _G
			_Debug.Proposal_String = ''
			return
		end
	end
	
	_Debug.ProposalLocation = curTable
	_Debug.Proposal_String = lastname
end

--Handle Keypresses
_Debug.handleKey = function(a,b)
	local activekey = _lovedebugpresskey or "`"
	if a == activekey then
		_Debug.drawOverlay = not _Debug.drawOverlay --Toggle
	elseif _Debug.drawOverlay and not b then
		_Debug.handleVirtualKey(a)
		if not _Debug.trackKeys[a] then
			_Debug.trackKeys[a] = { time = _Debug.keyRepeatInterval - _Debug.keyRepeatDelay}
		end
	end
end

--Handle Virtual Keypresses
_Debug.handleVirtualKey = function(a)
		_Debug.resetProposals = true
		local add = _Debug.keyConvert(a) or '' --Needed for backspace, do NOT optimize
		local suffix = _Debug.input:sub(_Debug.inputMarker, (#_Debug.input >= _Debug.inputMarker) and #_Debug.input or _Debug.inputMarker + 1)
		if _Debug.inputMarker == 0 then --Keep the input from copying itself
			suffix = ""
		end
		_Debug.input = _Debug.input:sub(0, _Debug.inputMarker - 1) .. add .. suffix
		if _Debug.resetProposals then
			if _Debug.inputMarker == 0 or _Debug.input:sub(_Debug.inputMarker + 1, _Debug.inputMarker + 1):find('[0-9a-zA-Z_]') then
				_Debug.ProposalLocation = _G
				_Debug.Proposal_String = ''
			else
				_Debug.findLocation(_Debug.input:sub(1, _Debug.inputMarker))
			end
			_Debug.updateProposals(_Debug.ProposalLocation)
		end
end

--Reloading the Code, update() and load()
_Debug.hotSwapUpdate = function(dt)
	--print('Starting HotSwap')
	local output, ok, err, loadok, updateok
	success, chunk = pcall(love.filesystem.load, _DebugSettings.LiveFile)
	if not success then
        print(tostring(chunk))
		output = chunk .. '\n'
    end
    ok,err = xpcall(chunk, _Debug.handleError)
	
	if ok then
		print("'".._DebugSettings.LiveFile.."' Reloaded.")
	end
	
	if _DebugSettings.LiveReset then
		loadok,err=xpcall(love.load,_Debug.handleError)
		if loadok then
			print("'love.run()' Reloaded.")
		end
	end
	
	updateok,err=pcall(love.update,dt)
end
--Reloading the code, draw(), I don't think this is needed..
_Debug.hotSwapDraw = function()
	local drawok,err
	drawok,err = xpcall(love.draw,_Debug.handleError)
end
	

--Modded version of original love.run
_G["love"].run = function()
	if love.math then
		love.math.setRandomSeed(os.time())
	end
	
	if love.event then
		love.event.pump()
	end

	if love.load then love.load(arg) end

	if love.timer then love.timer.step() end
	
	local dt = 0


	-- Main loop time.
	while true do

		-- Process events.
		if love.event then
			love.event.pump()
			for e,a,b,c,d in love.event.poll() do
				if e == "quit" then
					local quit = false
					if love.quit then
						xpcall(function() quit = love.quit() end, _Debug.handleError)
					end
					if not quit then
						if love.audio then
							love.audio.stop()
						end
						return
					end
				end
				local skipEvent = false
				if e == "textinput" then --Keypress
					skipEvent = true
					_Debug.handleKey(a)
					if not _Debug.drawOverlay then
						if love.textinput then love.textinput(a) end
					end
				end
				if e == "keypressed" then --Keypress
					skipEvent = true
					
					if string.len(a)>=2 then _Debug.handleKey(a, b) end
					if not _Debug.drawOverlay then
						if love.keypressed then love.keypressed(a,b) end
					end
				end
				if e == "keyreleased" then --Keyrelease
					skipEvent = true
					if not _Debug.drawOverlay then
						if love.keyreleased then love.keyreleased(a, b) end
					end
				end
				if e == "mousepressed" and _Debug.drawOverlay then --Mousepress
					skipEvent = true
					_Debug.handleMouse(a, b, c)
				end
				if not skipEvent then
					xpcall(function() love.handlers[e](a,b,c,d) end, _Debug.handleError)
				end
			end
		end
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
		end
		_Debug.tick = _Debug.tick - dt
		if _Debug.tick <= 0 then
			_Debug.tick = _Debug.tickTime + _Debug.tick
			_Debug.drawTick = not _Debug.drawTick
		end
		if _Debug.drawOverlay then
			for key, d in pairs(_Debug.trackKeys) do
				if love.keyboard.isDown(key) then
					d.time = d.time + dt
					if d.time >= _Debug.keyRepeatInterval then
						d.time = 0
						_Debug.handleVirtualKey(key, d.unicode)
					end
				else
					_Debug.trackKeys[key] = nil
				end
			end
		end
		
		if love.update and not _Debug.drawOverlay then
			if _DebugSettings.LiveAuto and _Debug.liveLastModified < love.filesystem.getLastModified(_DebugSettings.LiveFile) then
				_Debug.liveLastModified = _DebugSettings.LiveAuto and love.filesystem.getLastModified(_DebugSettings.LiveFile) or 0
				_Debug.hotSwapUpdate(dt) 
			else
				xpcall(function() love.update(dt) end, _Debug.handleError)
			end
		elseif love.update and (_Debug.liveDo or (_DebugSettings.LiveAuto and _Debug.liveLastModified < love.filesystem.getLastModified(_DebugSettings.LiveFile))) then 
			_Debug.liveLastModified = love.filesystem.getLastModified(_DebugSettings.LiveFile)
			_Debug.hotSwapUpdate(dt) 
		end -- will pass 0 if love.timer is disabled
		if love.window and love.graphics and love.window.isCreated() then
			love.graphics.clear()
			love.graphics.origin()
			if love.draw then if _Debug.liveDo then _Debug.hotSwapDraw() _Debug.liveDo=false else xpcall(love.draw, _Debug.handleError) end end
			if _Debug.drawOverlay then _Debug.overlay() end
			love.graphics.present()
		end



		if love.timer then love.timer.sleep(0.001) end

	end

end
