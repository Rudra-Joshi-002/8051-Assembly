;LCD Codes with checking busy flags to reduce the time
;wasted by the controller
;p1.0 - p1.7 used as data pins
;	
;p2.0-> rs of lcd
;p2.1-> r/w of lcd
;p2.2-> e of lcd

;Notes:

;Busy flag is provided at D7 of LCD
;when this flag=1 lcd is busy
;when this flag=0 lcd is ready to accept new commands
;and to Read the flag necessary conditions are
;rs->0
;r/w->1
;e-> is given a low to high pulse for reading the flag

;also apart from that a delay is introduced when enable signal is given
;thus we do need a delay subroutine

;but the advantage of this method is that it reduces the number of times this delay is
;called and thus reduces the program execution time since instead of waiting
;for a fixed amount of duration to let lcd complete a instruction each time we are now continuosly
;checking if the lcd has completed the execution of pervious task that was given to it.
;that too within the datawrt and cmdwrt subroutines themselves


org 0000h
	
	ljmp main
	
	cmdwrt:
	acall check_busy_flag; wait till lcd is ready to accept new instruction
	mov p1,a
	clr p2.0 ; select rs to write command
	clr p2.1 ; select r/w to write mode
	setb p2.2 ; set enable signal
	acall delay
	clr p2.2 ; give a high to low pulse
	ret
	
	datawrt:
	acall check_busy_flag; wait till lcd is ready to accept new instruction
	mov p1,a
	setb p2.0 ; select rs to write data
	clr p2.1 ;select r/w to write mode
	setb p2.2 ; set enable signal
	acall delay
	clr p2.2 ; give a high to low pulse
	ret
	
	delay:;2ms delay assuming clk freq 12MHz
	mov r3,#50
	here2:mov r4,#255
	here1:djnz r4,here1
	djnz r3,here2
	ret
	
	check_busy_flag: ;subroutine that checks the status of busy flag based on above mentioned conditions
	clr p2.0 ; clr rs
	setb p2.1 ;set r/w to 1 for reading from LCD
	back:clr p2.2 ;clr enable for low to high pulse to be given
	acall delay ; delay to generate a low pulse
	setb p2.2 ; set enable so that busy flag is now made availabe for reading at D7 of lcd
	
	jb p1.7,back ; check
	ret
	
	main:
	
	mov a,#38h ;lcd 2 lines 5x7 Matrix
	acall cmdwrt ;call cmdwrt subroutine
	;acall delay ; give lcd some time to execute the command
	
	mov a,#0fh ; dispaly on cursor blinking
	acall cmdwrt
	;acall delay
	
	mov a,#01h ;clr display
	acall cmdwrt
	;acall delay
	
	mov a,#06h ;shift cursor to right
	acall cmdwrt
	;acall delay
	
	mov a,#86h; shift cursor to position 6 of 1st line
	acall cmdwrt																																																							
	;acall delay
	
	mov a,#'N';send ascii character 'N' to lcd to dispaly
	acall datawrt ; call datawrt subroutine for displaying on lcd
	;acall delay
	
	mov a,#'o';send ascii character 'o' to lcd to dispaly
	acall datawrt
	;acall delay
	
	here: sjmp here
end;