--[[ Flexo Alpha 0.0.1
TODO: Everything.
--]]

local curses = require "curses"
local quitting = false;
local escaped = false;
local returning = 0;
local width = curses.cols()
local height = curses.lines()
local pageX = width / 2
local pageY = height / 4
local posX = 1
local posY = 1
local allLines = {}
local maxPageWidth = posX
local currLine = 1
local currChar = 1
local stdscr
local page
local text = ""

local function main ()
	stdscr = curses.initscr ()
	curses.cbreak ()
	curses.echo (false)	-- not noecho !
	curses.nl (false)	-- not nonl !
	stdscr:clear ()
	
	page = curses.newwin(10, 10, pageX, pageY)
	page:move(pageY, pageX)
	stdscr:refresh ()
	allLines[currLine] = ""
	while not quitting do	
		width = curses.cols()
		height = curses.lines()
		pageX = width / 2
		pageY = height / 4
		stdscr:mvaddstr (height - 1, 0, "FLEXO ALPHA 0.0.1")
		stdscr:mvaddstr (height - 1, width / 2, "char: # ")
		stdscr:mvaddstr (height - 1, width / 4, "line: "..currLine)	
		local car = ""
		page:move(pageY, pageX)
		local key = page:getch ()
		stdscr:move(height / 4 + 1, width / 2)		
		processKey(key)		
		stdscr:mvaddstr (height - 1, 0, "FLEXO ALPHA 0.0.1")
		stdscr:mvaddstr (height - 1, width / 2, "char: "..key.." ")
		stdscr:mvaddstr (height - 1, width / 4, "line: "..currLine)
		stdscr:move(height / 4 + 1, width / 2)
		stdscr:refresh ()
	end
	curses.endwin ()
end

-- To display Lua errors, we must close curses to return to
-- normal terminal mode, and then write the error to stdout.
local function err (err)
  curses.endwin ()
  print "Caught an error:"
  print (debug.traceback (err, 2))
  os.exit (2)
end

function processKey(key)
	if not allLines[currLine] then
		allLines[currLine] = ""
	end
	if key == 27 then				--ESC
		escaped = not escaped
	end
	if key == 113 and escaped then --q
		quitting = true 
	end
	if escaped then 
		stdscr:mvaddstr (height - 1, width - 5, " ESC")
	else
		stdscr:mvaddstr (height - 1, width - 5, "    ")
		if key == 13 then --newline
			moveLine(1)
			setCol(1)	
		elseif key == 65 then -- up
			moveLine(-1)
		elseif key == 66 then -- down
			moveLine(1)
		elseif key == 67 then -- right
			moveCol(1)
		elseif key == 68 then -- left
			moveCol(-1)
		elseif key == 127 then --backspace
			moveCol(-1)
			allLines[currLine] = string.sub(allLines[currLine], 0, posX - 1)..string.sub(allLines[currLine], posX + 1)
		elseif key < 256 and key > 30 then 
			car = string.char (key) 
			allLines[currLine] = string.sub(allLines[currLine], 0, posX)..car..string.sub(allLines[currLine], posX + 1)
			posX = posX + #car
		end
		page:erase()			
		stdscr:erase ()
		page:move_window(pageY, pageX - string.len(allLines[currLine]))	
		page:resize(currLine + 10, maxPageWidth + 1)
		stdscr:clearok(true)
		page:erase()
		stdscr:refresh ()
		stdscr:refresh ()
		for i,v in ipairs(allLines) do
			page:move(i, 1)	
			page:leaveok(true)
			page:winsstr(v)		
			page:leaveok(true)
			stdscr:refresh ()
		end
		page:move(posY, posX)	
		page:leaveok(true)		
		--page:winsstr(allLines[currLine])		
		page:border()	
		stdscr:refresh ()	
	end
	if posX > maxPageWidth - 1 then
		maxPageWidth = posX + 1
	end
end

function moveLine(amount)
	if currLine + amount < 1 then
		curses.beep()
		return
	end
	posY = posY + amount
	pageY = pageY - amount
	--allLines[line] = currLine
	currLine = currLine + amount
	if not allLines[currLine] then
		allLines[currLine] = ""
	end
	stdscr:erase()			
end

function moveCol(amount)
	if posX + amount < 1 then
		curses.beep()
		return
	end
	posX = posX + amount
end

function setCol(pos)
	posX = pos
end

function getLine(i)
	line = ""
	checked = 0;
	newLines = 0;
	newLinePos = 0;
	lastNewLine = 0
	while checked < #text and newLines ~= i do
		checked = checked + 1
		if string.sub(text, checked, 1).equals(string.char(10)) then
			lastNewLine = newLinePos
			newLinePos = checked
			newLines = newLines + 1
		end
		if newLines == i do
			line = string.sub(text, lastNewLine, checked)
		end
	end
	return line
end

xpcall (main, err)