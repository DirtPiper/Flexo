# ROUGH DESIGN SPECS
To be written in lua, with lcurses(?) and, maybe, a LISP-like macro system for lua. Some people have [already made this](https://github.com/differentprogramming/lua-macro).

Keyboard -> Code Selector(s) -> (Tapes ->) Writer -> Text

## VIEWING TEXT
When flexo is displaying text, two modes may be used (toggleable via the Scroll Lock key):
	**Flexo mode**: the cursor remains static, and the text moves around it as you type (as on a Flexowriter, or any other typewriter/teleprinter where the platen is on the carriage)
	**TTY mode**: the text remains static, and the cursor moves around it as you type (as on a Teletype, or any other typewriter/teleprinter where the type element(s) is/are on the carriage)
	
Flexo mode is the default. 

## ENTERING TEXT

### CODE SELECTOR
Whenever a key is pressed, the keypress is interpreted by a *Code Selector*. The default Code Selector directly feeds the keypresses into the *Writer*, which actually inputs the corresponding characters into the text being edited.

Alternative Code Selectors may be created, used, and piped together. If, for instance, we wanted to interpret every time the user presses the 'caps lock' key as 'ctrl' instead, then the Code Selector would detect the 'caps lock' input code, translate it to the 'ctrl' input code, and then feed it to either the next Code Selector in the chain or the Writer.

Code Selectors are not limited to translating from one input code to another, though - they may also translate a single input code into multiple input codes (say, interpreting '1' as 'one', '2' as 'two', etc.), spooling/punching/typing tapes, loading/unloading other Code Selectors, perhaps outright running Lua code itself, etc.

Code Selectors are saved as **.fcs** files (short for Friden Code Selector) - the format spec is in /docs/CODESELECTOR.MD.

### TAPES
Whenever the 'load tape' input is given to the Writer (by default, the 'ctrl' key), Flexo brings up the 'Selectadata' - and the fun begins.

#### SELECTADATA
Aside from preparing a pipeline of Code Selectors, one can also prepare *Tape Libraries*. A Tape Library (saved as a **.ftl** file, format spec in /docs/TAPELIBRARY.MD ) contains a list of Tapes (saved as **.ft** files, format spec in /docs/TAPEFILE.MD ) and, optionally, other Tape Libraries. 

If only one Tape Library is loaded, then the Selectadata will show a list of the names of all the Tapes in that Tape Library in the order they are listed in the Tape Library file. As the user types, the Selectadata narrows the listing to only show Tapes with names matching what the user has typed thus far - multiple matching tapes may be selected from by using the Up/Down arrow keys (rebindable via Code Selector, of course). 

If specified in the Tape Library File, a 'preview' of the currently selected Tape may be displayed inserted to the text at the current cursor position. Pressing the 'read tape' input will read from the selected tape and insert it into the text at the cursor's position and close the Selectadata. Pressing the 'load tape' input again will close the Selectadata without reading the tape. 

If multiple Tape Libraries are loaded, or if a Tape Library contains nested sub-libraries, then 'reading' a selected Tape Library in the Selectadata will show the listing of all Tapes/Tape Libaries contained within it - entering '..' and 'reading' will load the parent Tape Library.

#### CONTROL CODES
Tapes may contain special control codes. Among these are:

$${\color{RED},}$$ STOP: stops Writing the Tape and waits for input from the user.

$${\color{RED}:[\*.ft]}$$ READ: reads from a specified Tape and writes it beginning at that location.

$${\color{RED}?[\*]}$$ QUERY: gets a value stored in a variable.

$${\color{RED}+[\*, \*]}$$ SET: sets a value stored in a variable, or creates the variable if it doesn't exist already.

$${\color{RED}<[\*, ,\\# \*]}$$ IFLESS: if a value stored in a variable is less than a value, do something

$${\color{RED}>[\*, ,\\# \*]}$$ IFMORE: if a value stored in a variable is more than a value, do something

$${\color{RED}=[\*, ,\\# \*]}$$ IFSAME: if a value stored in a variable is equal to a value, do something
