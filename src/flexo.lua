--[[ Flexo Alpha 0.0.1
TODO: Everything.
--]]

local curses = require "curses"

local function main ()
	local stdscr = curses.initscr ()

	curses.cbreak ()
	curses.echo (false)	-- not noecho !
	curses.nl (false)	-- not nonl !

	stdscr:clear ()
	
	local quitting = false;
	local escaped = false;
	local returning = 0;
	local width = curses.cols()
	local height = curses.lines()
	local pageX = width / 2
	local pageY = height / 4
	local posX = 1
	local posY = 1


	local page = curses.newwin(10, 10, pageX, pageY)
	page:move(pageY, pageX)
	print("ffff")
	stdscr:refresh ()
	all_lines = {}
	line = 0
	max_row_length = posX
	currline = ""
	while not quitting do	
		stdscr:mvaddstr (height - 1, 0, "FLEXO ALPHA 0.0.1")
		width = curses.cols()
		height = curses.lines()
		pageX = width / 2
		pageY = height / 4
		local car = ""
		page:move(pageY, pageX)
		local c = page:getch ()
		stdscr:mvaddstr (height - 1, width / 2, "char: "..c.." ")
		stdscr:mvaddstr (height - 1, width / 4, "lines: "..line+1)		
		if c < 256 and c > 30 then 
			car = string.char (c) 
			currline = currline..car
			posX = posX + 1
		end
		if c == 27 then				--ESC
			escaped = not escaped
		end
		if c == 113 and escaped then --q
			quitting = true 
		end
		if escaped then 
			stdscr:mvaddstr (height - 1, width - 5, " ESC")
		else
			stdscr:mvaddstr (height - 1, width - 5, "    ")
			if c == 13 then --newline
				posY = posY + 1
				pageY = pageY - 1
				posX = 1
				returning = true
				line = line + 1
				all_lines[line] = currline
				currline = ""
				stdscr:erase()				
			end
			if c == 127 then --backspace
				posX = posX - 2
				currline = string.sub(currline, 0, #currline - 2)
			end
			--page:move(pageX, pageY)
			--print(car)
			--pageX = pageX - 1
			--page:mvaddch (pageX, pageY, c)
			--pageX = pageX + 1
			page:erase()			
			stdscr:erase ()
			stdscr:mvaddstr (height - 1, 0, "FLEXO ALPHA 0.0.1")
			stdscr:mvaddstr (height - 1, width / 2, "char: "..c.." ")
			stdscr:mvaddstr (height - 1, width / 4, "lines: "..line+1)
			page:move_window(pageY, pageX - string.len(currline))	
			page:resize(line + 10, max_row_length + 1)
			stdscr:clearok(true)
			--page:move_window(line, 1)
			page:erase()
			stdscr:refresh ()
			--page:redrawwin()	
			--page:move(pageY +line, pageX)	
			stdscr:refresh ()
			for i,v in ipairs(all_lines) do
				page:move(i, 1)--string.len(v))		
				page:leaveok(true)
				page:winsstr(v)		
				page:leaveok(true)
				stdscr:refresh ()
			end
			page:move(posY, 1)		
			page:leaveok(true)		
			page:winsstr(currline)		
			page:border()	
			stdscr:refresh ()	
		end
		if posX > max_row_length - 1 then
			max_row_length = posX + 1
		end
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

xpcall (main, err)