;For Keyboard :
;Register Bank-1 is Used Here
;R0 Stores the Binary Code Of Key Pressed
;R2 Acts as Row Counter
;R3 Acts as Column Counter
;R4 Used to Ground One Row At Time
;B-Reg Used to Store the Value of Key Pressed that Is to Be Displayed On LCD
;P2 (Columns) AND P0(Rows) are used to interface Keyboard

;For LCD:

;LCD Codes with checking busy flags to reduce the time
;wasted by the controller
;p1.0 - p1.7 used as data pins
;	
;p3.0-> rs of lcd
;p3.1-> r/w of lcd
;p3.2-> e of lcd

;Notes:

;Busy flag is provided at D7 of LCD
;when this flag=1 lcd is busy
;when this flag=0 lcd is ready to accept new commands
;and to Read the flag necessary conditions are
;rs->0
;r/w->1
;e-> is given a low to high pulse for reading the flag otherwise its given a high to low pulse for latching the data to be written 

;also apart from that a delay is introduced when enable signal is given
;thus we do need a delay subroutine

;but the advantage of this method is that it reduces the number of times this delay is
;called and thus reduces the program execution time since instead of waiting
;for a fixed amount of duration to let lcd complete a instruction each time we are now continuosly
;checking if the lcd has completed the execution of pervious task that was given to it.
;that too within the datawrt and cmdwrt subroutines themselves

;here the code segment is divded into various subroutine blocks such that
;we first Initialize LCD and then call a graphics subroutine which displays
;some basic graphics based on look-up table values at 500h then keypad scanning
;function is called which looks for a key press and then based on the key pressed its
;equivalent value is displayed on the lcd using character_display subroutine
;where values are stored in a keypad named look-up table starting from 600h onwards
;going through this program one should be able to appreciate the beauty of subroutines
;along with appropriate changes in register bank to avoid confusion and how writing basic subroutines
;can helps us prevent wrting long form of codes

org 0000h
	
	;here register bank-0 is for all lcd operations
	
	mov sp,#20h
	lcall delay ;give lcd some time to Initialize
	lcall delay
	
	mov a,#38h
	lcall cmdwrt
	lcall delay
	
	mov a,#38h
	lcall cmdwrt
	lcall delay
	
	mov a,#38h ;repeat the same command a several times so that Power Supply Reset Timings are met
	lcall cmdwrt
	lcall delay
	
	lcall initial_graphics
	
	lcall key_pad
	
	here:sjmp here
	
	org 500h ;space to store Strings
		
		screen:
		db "LCD + Keypad"
		db "Press any Key"
			
	org 600h ;LOOK_UP table to store keypad characters
		
		keypad:
		db '0','1','2','3'
		db '4','5','6','7'
		db '8','9','A','B'
		db 'C','D','E','F'
			
	org 100h ;space to write LCD Subroutines
		
	cmdwrt:
	acall check_busy_flag; wait till lcd is ready to accept new instruction
	mov p1,a
	clr p3.0 ; select rs to write command
	clr p3.1 ; select r/w to write mode
	setb p3.2 ; set enable signal
	acall delay
	clr p3.2 ; give a high to low pulse
	ret
	
	datawrt:
	acall check_busy_flag; wait till lcd is ready to accept new instruction
	mov p1,a
	setb p3.0 ; select rs to write data
	clr p3.1 ;select r/w to write mode
	setb p3.2 ; set enable signal
	acall delay
	clr p3.2 ; give a high to low pulse
	ret
	
	delay:;2ms delay assuming clk freq 12MHz
	mov r3,#50
	here2:mov r4,#255
	here1:djnz r4,here1
	djnz r3,here2
	ret
	
	check_busy_flag: ;subroutine that checks the status of busy flag based on above mentioned conditions
	clr p3.0 ; clr rs
	setb p3.1 ;set r/w to 1 for reading from LCD
	back:clr p3.2 ;clr enable for low to high pulse to be given
	acall delay ; delay to generate a low pulse
	setb p3.2 ; set enable so that busy flag is now made availabe for reading at D7 of lcd
	
	jb p1.7,back ; check
	ret
	
	initial_graphics: ;making a graphics subroutine that displays basic GUI Graphics
	
	mov a,#0fh ; dispaly on cursor blinking
	lcall cmdwrt
	
	mov a,#01h ;clr display
	lcall cmdwrt
	
	mov a,#82h; shift cursor to 2nd Position of 1st line
	lcall cmdwrt
	
	mov dptr,#screen ;initialize dptr for String Display
	mov r1,#12d ;number of characters in 1st String
	mov r2,#00h
	
	loop1:mov a,r2 ;display first string
	movc a,@a+dptr
	lcall datawrt
	inc r2
	djnz r1,loop1
	
	mov a,#0c2h; shift cursor to centere of 2nd line
	lcall cmdwrt
	
	mov r1,#13d ;number of characters in 1st String
	
	loop2:mov a,r2 ;display 2nd string
	movc a,@a+dptr
	lcall datawrt
	inc r2
	djnz r1,loop2
	
	ret
	
	key_pad:
	
	mov dptr,#keypad
	
	START:setb psw.3 ;all book-keeping done in Register-Bank-1
	clr psw.4
	MOV R0, #00 // binary code for the pressed key will be stored in R0
	MOV P2, #0FFH // configure P2 as I/P port
	MOV P0, #00H // ground all the rows
	
	NO_REL: MOV A, P2
	ANL A, #0FH // mask the upper nibble which is not used for keyboard
	
	CJNE A, #0FH, NO_REL
	// if all the keys are not high previous key is not released
	
	LCALL DBOUN // debounce for the key release
	
	WAIT: MOV A, P2 // check for any key press and wait until key is pressed
	ANL A, #0FH
	CJNE A, #0FH, K_IDEN // key identify
	SJMP WAIT
	
	K_IDEN: LCALL DBOUN 
	MOV R4, #7FH // only one row is made 0 at a time
	MOV R2, #04 // row counter
	MOV A, R4
	
	NXT_ROW: RL A
	MOV R4, A // save data to ground the next row
	MOV P0, A // ground one row
	MOV A, P2
	ANL A, #0FH // mask the upper nibble
	MOV R3, #04 // column counter
	
	NXT_COLM: RRC A // move A0 bit in carry
	JNC KY_FND
	INC R0
	DJNZ R3, NXT_COLM
	MOV A, R4
	DJNZ R2, NXT_ROW
	SJMP WAIT // no key closure found, go back and check again
	
	KY_FND: MOV A, R0
	movc a,@a+dptr
	mov b,a
	lcall display_character
	SJMP START // go for detecting the next key press and identification
	
	
	DBOUN: MOV R6, #10 // debounce delay for 10ms (Xtal=12MHz)
	THR2: MOV R7, #250
	THR1: NOP
	NOP
	DJNZ R7, THR1
	DJNZ R6, THR2
	RET
	
	ret
	
	display_character:; making character display subroutine
	
	clr psw.3;resort back to Register-Bank-0 for LCD Operations
	clr psw.4
	
	mov a,#0fh ; dispaly on cursor blinking
	lcall cmdwrt
	
	mov a,#01h ;clr display
	lcall cmdwrt
	
	mov a,#87h; shift cursor to centre of 1st line
	lcall cmdwrt
	
	mov a,b; mov the character stored in Reg-b to Reg-a to display it on LCD
	lcall datawrt
	
	ret
	
end