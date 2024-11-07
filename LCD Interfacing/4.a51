;For Keyboard :
;p0 is used to Interface Buttons for 8x1 Board
;Rgeister bank-1 is Used for Keyboard Operations

;For LCD:

;LCD Codes with checking busy flags to reduce the time
;wasted by the controller
;p1.0 - p1.7 used as data pins
;	
;p3.3-> rs of lcd
;p3.4-> r/w of lcd
;p3.5-> e of lcd

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

org 0000h
	
	sjmp main

org 002bh ;leaving space for all isr's
	
	main:
	;here register bank-0 is for all lcd operations
	
	mov sp,#20h ; initialze stack pointer to place other than register bank addresses
	
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
	
	mov ie,#81h ; active external interrupt-0 pin
	mov ip,#01h ; give external interrupt-0 higghest priority
	setb tcon.0 ;set the external interrupt pin as edge triggred
	
	mov p0,#0ffh ;initialize input port
	mov dptr,#keypad ;initialize dptr with address of keypad
	
	here:sjmp here
	
	org 0500h ;space to store Strings
		
		screen:
		db "LCD + Keypad"
		db "Press any Key"
			
	org 0600h ;LOOK_UP table to store keypad characters
		
		keypad:
		db '0','1','2','3'
		db '4','5','6','7'
			
	org 100h ;space to write LCD Subroutines
		
	cmdwrt:
	acall check_busy_flag; wait till lcd is ready to accept new instruction
	mov p1,a
	clr p3.3 ; select rs to write command
	clr p3.4 ; select r/w to write mode
	setb p3.5 ; set enable signal
	acall delay
	clr p3.5 ; give a high to low pulse
	ret
	
	datawrt:
	acall check_busy_flag; wait till lcd is ready to accept new instruction
	mov p1,a
	setb p3.3 ; select rs to write data
	clr p3.4 ;select r/w to write mode
	setb p3.5 ; set enable signal
	acall delay
	clr p3.5 ; give a high to low pulse
	ret
	
	delay:;2ms delay assuming clk freq 12MHz
	mov r3,#50
	here2:mov r4,#255
	here1:djnz r4,here1
	djnz r3,here2
	ret
	
	check_busy_flag: ;subroutine that checks the status of busy flag based on above mentioned conditions
	clr p3.3 ; clr rs
	setb p3.4 ;set r/w to 1 for reading from LCD
	back:clr p3.5 ;clr enable for low to high pulse to be given
	acall delay ; delay to generate a low pulse
	setb p3.5 ; set enable so that busy flag is now made availabe for reading at D7 of lcd
	
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
	
	dboun: mov r6,#10d ;delay subroutine for keypad
	dloop2:mov r7,#250d
	dloop1:nop
	nop
	djnz r7,dloop1
	djnz r6,dloop2
	ret
	
	org 0003h
		
		ljmp main_isr ;isr for external interrupt-0 starts here
		return: reti
	org 0700h
		
		main_isr:
		
		lcall dboun
		mov a,p0
		cjne a,#0ffh,identify
		ljmp return
		identify:lcall dboun ;now the program serves to check 
		mov a,p0 ;which key is pressed
		
		setb psw.3 ; set register bank-1 for keyboard operations
		clr psw.4
		mov r0,#00h
		mov r1,#08h
		
		again: rrc  a ;key indentification logic starts here
		jc next_key
		sjmp found
		
		next_key: inc r0
		djnz r1,again
		mov r1,#0ffh
		
		found: mov a,r0; reg where key code is stored
		movc a,@a+dptr
		mov b,a
		lcall display_character
		clr psw.3; reset the register bank for lcd display puropses
		clr psw.4
		ljmp return
		
end