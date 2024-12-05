;the following is the code for interfacing and testing 128x64 GLCD Display with 8051
;our code focues on developing basic commands for LCD in assembly so that they can be used effectively in future.
;now the following is the pin descripition that we'll follow:
;P1->D0-D7
;P2.0->RS (Reg. Select)
;P2.1->R/W'
;P2.2->E
;P2.3->RST (RESET)
;P2.4->CS1
;P2.5->CS2

;the following are steps that we'll follow:
;1. Initialize GLCD
;2. Select GLCD Half
;3. Select Page
;4. Display Text

org 0000h
	
	setb p2.3 ;set rest pin to 1 i.e. inactive mode
	clr p2.4 ;set cs1 to select first half of glcd (actullay inverted logic is used for proteus simulation hence a bit change in these and rst instructions is seen)
	setb p2.5 ;clr cs2 to select first half of glcd
	
	mov a,#3fh ;command to turn on glcd for normal operations
	acall cmdwrt ;call cmdwrt subroutine
	acall delay ; give glcd some time to execute the command
	
	mov a,#40h ;set y-address here it means column-0 is selected
	acall cmdwrt ;call cmdwrt subroutine
	acall delay ; give lcd some time to execute the command
	
	mov a,#0bbh ;set x-address here page-3 is selected
	acall cmdwrt ;call cmdwrt subroutine
	acall delay ; give lcd some time to execute the command
	
	mov a,#0c0h ;set z-address or start line
	acall cmdwrt ;call cmdwrt subroutine
	acall delay ; give lcd some time to execute the command
	
	acall delay ;some delay is introduced purposefully
	acall delay
	acall delay
	acall delay
	acall delay
	acall delay
	
	mov dptr,#M ;display character 'M'
	acall display_character
	
	mov dptr,#i
	acall display_character
	
	mov dptr,#c_ascii
	acall display_character
	
	mov dptr,#r
	acall display_character
	
	mov dptr,#o
	acall display_character
	
	mov dptr,#c_ascii
	acall display_character
	
	mov dptr,#o
	acall display_character
	
	mov dptr,#n
	acall display_character
	
	mov dptr,#t
	acall display_character
	
	mov dptr,#r
	acall display_character
	
	mov dptr,#o
	acall display_character
	
	mov dptr,#l
	acall display_character
		
	mov dptr,#l
	acall display_character
	
	mov dptr,#e1
	acall display_character
	
	setb p2.4 ;clr cs1 to select 2nd half of glcd
	clr p2.5 ;set cs2 to select 2nd half of glcd
	
	mov a,#3fh ;command to turn on glcd for normal operations
	acall cmdwrt ;call cmdwrt subroutine
	acall delay ; give glcd some time to execute the command
	
	mov a,#40h ;set y-address here it means column-0 is selected
	acall cmdwrt ;call cmdwrt subroutine
	acall delay ; give lcd some time to execute the command
	
	mov a,#0bbh ;set x-address here page-3 is selected
	acall cmdwrt ;call cmdwrt subroutine
	acall delay ; give lcd some time to execute the command
	
	mov a,#0c0h ;set z-address or start line
	acall cmdwrt ;call cmdwrt subroutine
	acall delay ; give lcd some time to execute the command
	
	mov dptr,#e2
	acall display_character
	
	mov dptr,#r
	acall display_character
	
	mov dptr,#dash
	acall display_character

	mov dptr,#p_ascii
	acall display_character
		
	mov dptr,#r
	acall display_character
	
	mov dptr,#o
	acall display_character
	
	mov dptr,#j
	acall display_character
	
	mov dptr,#e
	acall display_character
	
	mov dptr,#c_ascii
	acall display_character
	
	mov dptr,#t
	acall display_character
	
	mov dptr,#dot
	acall display_character
	
	mov dptr,#c_ascii
	acall display_character
	
	mov dptr,#o
	acall display_character
	
	mov dptr,#M
	acall display_character
	
	here: sjmp here
	
	
	org 100h
		
		;here we'll write lcd commands to read and write data
		
		cmdwrt:
		
		mov p1,a ;move command in accumulator to p1
		
		clr p2.0 ;select command register (rs-pin)
		
		clr p2.1 ;set lcd to write mode (r/w'-pin)
		setb p2.2 ;set enable signal (e-pin)
		acall delay ;call delay subroutine
		clr p2.2 ;give a high to low pulse
		
		ret ;for cmdwrt
		
		datawrt:
		
		mov p1,a ;move data in accumulator to p1
		
		setb p2.0 ;select data register (rs-pin)
		
		clr p2.1 ;set lcd to write mode (r/w'-pin)
		setb p2.2 ;set enable signal (e-pin)
		acall delay ;call delay subroutine
		clr p2.2 ;give a high to low pulse
		
		ret ;for datawrt
		
		delay:;2ms delay assuming clk freq 12MHz
		mov r3,#50
		here2:mov r4,#255
		here1:djnz r4,here1
		djnz r3,here2
		ret ;for delay
		
		display_character: ;subroutine to display a charcter form lookup table
	
		mov r0,#00h	; Initialize index for looping through the string
		
		back2nxt:mov a,r0 ;mov cuurent index into a
		movc a, @a+dptr ; Load the character from the string
		
		lcall datawrt ; Call datawrt to display the character           
		lcall delay ;call delay 
		
		
		inc r0 ;increment index to access next character
		mov a,r0 ;mov new index back into reg-a
		movc a, @a+dptr ;access then new character
		
		cjne a,#'/',back2nxt  ; If not end of string (null terminator), loop
		ret ;for display_character
		
		org 200h
		;look up table for printing text here charcter '/' is used to display null or end of character code
		
		M: db 00h,0FDh,0FBh,0F7h,0FBh,0FDh,00h,0FFh,'/'
		i: db 0dh,0ffh,'/'
		c_ascii: db 0C7h,0bbh,7dh,7dh,0ffh,'/'
		r: db 01h,0f7h,0fbh,0fdh,0ffh,'/'
		o: db 0C3h,3Dh,3Dh,0C3h,0FFh,'/'
		n: db 01h,0F7h,0F7h,07h,0FFh,'/'
		t: db 0F7h,01h,67h,7Fh,0FFh,'/'
		l: db 01h,01h,0FFh,'/'
		e1: db 0C7h,0ABh,75h,'/' ;for 1st half of screen
		e2: db 79h,0FFh,'/' ;for 2nd half of screen
		e: db 0C7h,0ABh,75h,79h,0FFh,'/'
		dash: db 0F7h,0F7h,0F7h,0FFh,'/' ;for displaying dash character '-'
		p_ascii: db 01h,0EDh,0EDh,0F3h,0FFh,'/'
		j: db 0BFh,7Fh,05h,0FFh,'/'
		dot: db 9Fh,9Fh,0FFh,'/' ;for displaying dot character '.' 
			
			
end
		
		