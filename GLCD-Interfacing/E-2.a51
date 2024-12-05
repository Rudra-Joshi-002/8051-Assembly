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
	
	acall delay ;some delay is introduced purposefully
	acall delay
	acall delay
	acall delay
	acall delay
	acall delay
	
	mov a,#3fh
	acall cmdwrt
	acall delay
	
	acall clrscreen
	
	mov a,#0
	acall set_pg
	acall delay
	
	mov a,#0
	acall set_column
	acall delay
	
	mov dptr,#array0
	acall display_character
	acall delay
	
	mov a,#1
	acall set_pg
	acall delay
	
	mov a,#0
	acall set_column
	acall delay
	
	mov dptr,#array1
	acall display_character
	acall delay
	
	mov a,#2
	acall set_pg
	acall delay
	
	mov a,#0
	acall set_column
	acall delay
	
	mov dptr,#array2
	acall display_character
	acall delay
	
	mov a,#3
	acall set_pg
	acall delay
	
	mov a,#0
	acall set_column
	acall delay
	
	mov dptr,#array3
	acall display_character
	acall delay
	
	mov a,#4
	acall set_pg
	acall delay
	
	mov a,#0
	acall set_column
	acall delay
	
	mov dptr,#array4
	acall display_character
	acall delay
	
	mov a,#5
	acall set_pg
	acall delay
	
	mov a,#0
	acall set_column
	acall delay
	
	mov dptr,#array5
	acall display_character
	acall delay
	
	mov a,#6
	acall set_pg
	acall delay
	
	mov a,#0
	acall set_column
	acall delay
	
	mov dptr,#array6
	acall display_character
	acall delay
	
	mov a,#7
	acall set_pg
	acall delay
	
	mov a,#0
	acall set_column
	acall delay
	
	mov dptr,#array7
	acall display_character
	acall delay
	
	mov a,#0
	acall set_pg
	acall delay
	
	mov a,#64
	acall set_column
	acall delay
	
	mov dptr,#array8
	acall display_character
	acall delay
	
	mov a,#1
	acall set_pg
	acall delay
	
	mov a,#64
	acall set_column
	acall delay
	
	mov dptr,#array9
	acall display_character
	acall delay
	
	mov a,#2
	acall set_pg
	acall delay
	
	mov a,#64
	acall set_column
	acall delay
	
	mov dptr,#array10
	acall display_character
	acall delay
	
	mov a,#3
	acall set_pg
	acall delay
	
	mov a,#64
	acall set_column
	acall delay
	
	mov dptr,#array11
	acall display_character
	acall delay
	
	mov a,#4
	acall set_pg
	acall delay
	
	mov a,#64
	acall set_column
	acall delay
	
	mov dptr,#array12
	acall display_character
	acall delay
	
	mov a,#5
	acall set_pg
	acall delay
	
	mov a,#64
	acall set_column
	acall delay
	
	mov dptr,#array13
	acall display_character
	acall delay
	
	mov a,#6
	acall set_pg
	acall delay
	
	mov a,#64
	acall set_column
	acall delay
	
	mov dptr,#array14
	acall display_character
	acall delay
	
	mov a,#7
	acall set_pg
	acall delay
	
	mov a,#64
	acall set_column
	acall delay
	
	mov dptr,#array15
	acall display_character
	acall delay
	
	here: sjmp here
	
	org 200h ;all new glcd subroutines starts from here
		
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
		
		display_character: ;subroutine to display a charcter form lookup table
	
		mov r0,#00h	; Initialize index for looping through the string
		
		back2nxt:mov a,r0 ;mov cuurent index into a
		movc a, @a+dptr ; Load the character from the string
		
		lcall datawrt ; Call datawrt to display the character 
		acall delay
		
		inc r0 ;increment index to access next character
		mov a,r0 ;mov new index back into reg-a
		movc a, @a+dptr ;access then new character
		
		cjne a,#'/',back2nxt  ; If not end of string (null terminator), loop
		ret ;for display_character
		
		clrscreen:
		
		mov r0,#00h ;page counter
		mov r5,#8d
		
		loop2:mov a,r0
		acall set_pg
		acall delay
		
		mov a,#00h
		acall set_column
		acall delay
		
		mov r2,#64d
		inc r0
		loop1:mov a,#00h ;fill all all the columns with light
		acall datawrt
		acall delay
		djnz r2,loop1
		
		mov a,#64d
		acall set_column
		acall delay
		
		mov r2,#64d
		
		loop3:mov a,#00h ;fill all all the columns with light
		acall datawrt
		acall delay
		djnz r2,loop3
		
		djnz r5,loop2
		
		ret ;for clear screen
		
		delay:;2ms delay assuming clk freq 12MHz
		mov r3,#50
		here2:mov r4,#255
		here1:djnz r4,here1
		djnz r3,here2
		ret ;for delay
		
		set_column: ;selects a particular column form where to write data for a given selected page
		
		clr c
		mov b,a ;copy a in b for book-keeping
		subb a,#40h ;check if the number in accumulator is greater than 64 in decimal to take decision
		jnc right_half ;jump to right half if number is >=64 in decimal
		
		;logic for selecting on left half of screen
		
		clr p2.4 ;set cs1 to select first half of glcd (actullay inverted logic is used for proteus simulation hence a bit change in these and rst instructions is seen)
		setb p2.5
		
		mov a,b ;reload a with original number
		add a,#40h ;add the number plus the 40h which is command for slecting 0th column in glcd
		
		acall cmdwrt ;call command function to select a particular column
		acall delay
		
		sjmp column_set
		
		right_half: ;logic for right of screen
		
		setb p2.4 ;selecting right half of screen
		clr p2.5
		
		add a,#40h ;since for right half values we'll add to 40h
		
		acall cmdwrt ;call command function to select a particular column
		acall delay
		
		column_set: 
		
		ret ;for set_column
		
		set_pg: ;Selects one of 8 vertical pages, each representing 8 rows of pixels.
		
		clr p2.4 ;enable both displays to set same page on both
		clr p2.5
		
		add a,#0b8h ;add numbers form 0 to 7 to b8h to select any pg out of the available 8 pgs
		acall cmdwrt
		
		ret ;for set_pg
		
		org 500h ; values for look-up tabels
			
			array0: db 124,126,19,19,126,124,0,0,'/';    //A,8x8
			array1: db 65,127,127,73,127,54,0,0,'/';	  //B,8x8
			array2: db 28,62,99,65,65,99,34,0,'/';	      //C,8x8
			array3: db 65,127,127,65,99,62,28,0,'/';     //D,8x8
			array4: db 65,127,127,73,93,65,99,0,'/';    //E,8x8
			array5: db 65,127,127,73,29,1,3,0,'/';       //F,8x8
			array6: db 28,62,99,65,81,115,114,0,'/';     //G,8x8
			array7: db 127,127,8,8,127,127,0,0,'/';      //H,8x8
				
			array8: db 126,17,17,17,126,'/'; 		//A,5x7
			array9: db 127,73,73,73,54,'/';		//B,5x7
			array10: db 62,65,65,65,34,'/';		//C,5x7
			array11: db 127,65,65,34,28,'/';		//D,5x7
			array12: db 127,73,73,73,65,'/';		//E,5x7
			array13: db 127,9,9,1,1,'/';			//F,5x7
			array14: db 62,65,65,81,50,'/';		//G,5x7
			array15: db 127,8,8,8,127,'/';			//H,5x7
		
		
end