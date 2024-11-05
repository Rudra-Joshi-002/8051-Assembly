;LCD Codes with Time Delays

;p1.0 - p1.7 used as data pins
;	
;p2.0-> rs of lcd
;p2.1-> r/w of lcd
;p2.2-> e of lcd

org 0000h
	
	ljmp main
	
	cmdwrt:
	mov p1,a
	clr p2.0 ; select rs to write command
	clr p2.1 ; select r/w to write mode
	setb p2.2 ; set enable signal
	acall delay
	clr p2.2 ; give a high to low pulse
	ret
	
	datawrt:
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
	
	main:
	
	mov a,#38h ;lcd 2 lines 5x7 Matrix
	acall cmdwrt ;call cmdwrt subroutine
	acall delay ; give lcd some time to execute the command
	
	mov a,#0eh ; dispaly on cursor on
	acall cmdwrt
	acall delay
	
	mov a,#01h ;clr display
	acall cmdwrt
	acall delay
	
	mov a,#06h ;shift cursor to right
	acall cmdwrt
	acall delay
	
	mov a,#84h; shift cursor to position 4 of 1st line
	acall cmdwrt
	acall delay
	
	mov a,#'N';send ascii character 'N' to lcd to dispaly
	acall datawrt ; call datawrt subroutine for displaying on lcd
	acall delay
	
	mov a,#'o';send ascii character 'o' to lcd to dispaly
	acall datawrt
	acall delay
	
	here: sjmp here
end