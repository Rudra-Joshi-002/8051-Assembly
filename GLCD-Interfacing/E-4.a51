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

;following changes have been made in the code to make the display faster
;check busy flag method has been introduced which checks the busy flag of GLCD in read mode and waits for appropriate
;time to give it next set of instructions this helps as we now no longer has to use fixed delay method

;the following is the change in procedure for checking the busy flag which is slightly different compared to standard
;charcter LCD's which is:
;here a high to low pulse is given to enable
;instead of a low to high pulse for conventional displays rest of the code remains the same
;also standard delay subroutine is reduced to 1ms to be more faster
;and pulse duration for high to low transition is also reduced to 1 microsecond instead of 20ms that was used earlier

;For Keyboard :
;p0 is used to Interface Buttons for 8x1 Board

;---The Purpose of this experiment is as follows---
;to divide the screen into grid of 128 pixel grid which contains 8x8 pixel array which can be controlled individually
;also on this display move a dot as per the user inputs

;---also the follwing register banks have been used for varoius operations---
; reg-0->LCD Operations
; reg-1->Keyboard Operations
; reg-2->For Control And Informations Sotrage of The Control Element which is a square dot in this case

org 0000h
	
	sjmp main
	
org 002bh
	
	main:
	
		mov p0,#0ffh ;set p0 as input port
		
		setb p2.3 ;set rest pin to 1 i.e. inactive mode
		
		mov sp,#30h ;move sp to ram loaction 20h
		
		lcall delay ;some delay is introduced purposefully
		lcall delay
		lcall delay
		lcall delay
		lcall delay
		lcall delay
		
		mov a,#3fh
		lcall cmdwrt
		
		lcall clrscreen
		
		mov a,#0d
		lcall set_column
		
		mov a,#0d
		lcall set_pg_cntrl
		
		lcall display_dot
		
		setb psw.4 ;reg-bank-2
		clr psw.3
		mov r1,#00h ;provide r1 of reg-bank-2 with initial coordinates of dot
		mov r2,#00h
		clr psw.3
		clr psw.4
		
		; keyboard logic starts here
		
		here:push psw
			setb psw.3 ;select reg-1 for Keyboard Opreations
			clr psw.4
			
			no_rel:mov a,p0
			cjne a,#0ffh,no_rel
			lcall dboun
			
			wait:mov a,p0
			cjne a,#0ffh,identify
			sjmp wait
			
			identify:lcall dboun ;now the program serves to check 
			mov a,p0 ;which key is pressed
			
			mov r0,#00h
			mov r1,#08h
			
			again: rrc  a ;key indentification logic starts here
			jc next_key
			sjmp found
			
			next_key: inc r0
			djnz r1,again
			sjmp no_rel
			
			found: mov a,r0; reg where key code is stored
			mov b,a; *****Reg-B stores the value of direction control*****
			lcall calc_pos
			lcall display_dot
			
			pop psw
		
		sjmp here
		
org 0100h ;here lies the codes for GLCD Operations
	
		cmdwrt:
			
			push psw
			clr psw.3
			clr psw.4
			
			;acall check_busy_flag; wait till lcd is ready to accept new instruction
			acall delay
			mov p1,a ;move command in accumulator to p1
			
			clr p2.0 ;select command register (rs-pin)
			
			clr p2.1 ;set lcd to write mode (r/w'-pin)
			setb p2.2 ;set enable signal (e-pin)
			acall delay ;call delay subroutine
			clr p2.2 ;give a high to low pulse
			acall delay
			
			pop psw
			
		ret ;for cmdwrt
		
		datawrt:
		
			push psw
			clr psw.3
			clr psw.4
		
			;acall check_busy_flag; wait till lcd is ready to accept new instruction
			acall delay
			mov p1,a ;move data in accumulator to p1
			
			setb p2.0 ;select data register (rs-pin)
			
			clr p2.1 ;set lcd to write mode (r/w'-pin)
			setb p2.2 ;set enable signal (e-pin)
			acall delay ;call delay subroutine
			clr p2.2 ;give a high to low pulse
			acall delay
			
			pop psw
		ret ;for datawrt
		
;		check_busy_flag: ;subroutine that checks the status of busy flag based on above mentioned conditions
;		
;			clr p2.0 ; clr rs
;			setb p2.1 ;set r/w to 1 for reading from LCD
;			back:setb p2.2 ;set enable for high to low pulse to be given
;			nop	; delay to generate a low pulse
;			nop
;			nop
;			nop
;			nop
;			nop
;			nop
;			nop
;			nop
;			nop
;			
;			clr p2.2 ; clr enable so that busy flag is now made availabe for reading at D7 of lcd

;			jb p1.7,back ; check
;		
;		ret ;for check busy flag
		
		delay:;1ms delay assuming clk freq 12MHz
			
			push psw
			clr psw.3
			clr psw.4
			
			mov r2,#2
			here2:mov r3,#255
			here1:djnz r3,here1
			djnz r2,here2
			
			pop psw
			
		ret ;for delay
		
		dboun: ;delay subroutine for keypad
			
			push psw
			setb psw.3 ;select reg-1 for Keyboard Opreations
			clr psw.4
			
			mov r4,#10d 
			dloop2:mov r5,#250d
			dloop1:nop
			nop
			djnz r5,dloop1
			djnz r4,dloop2
			
			pop psw
		ret
		
		set_column: ;selects a particular column form where to write data for a given selected page
		
		
			mov b,#08d ;to set the starting column address to the one meant by pixel grid value 
			mul ab
			mov b,a ;copy a in b for book-keeping
			
			subb a,#40h ;check if the number in accumulator is greater than 64 in decimal to take decision
			jnc right_half ;jump to right half if number is >=64 in decimal
			
			;logic for selecting on left half of screen
			
			mov 18h,#00h
			
			clr p2.4 ;set cs1 to select first half of glcd (actullay inverted logic is used for proteus simulation hence a bit change in these and rst instructions is seen)
			setb p2.5
			
			
			mov a,b ;reload a with original number
			add a,#40h ;add the number plus the 40h which is command for slecting 0th column in glcd
			
			acall cmdwrt ;call command function to select a particular column
			
			sjmp column_set
			
			right_half: ;logic for right of screen
			
			mov 18h,#01h
			
			setb p2.4 ;selecting right half of screen
			clr p2.5
			
			add a,#40h ;since for right half values we'll add to 40h
			acall cmdwrt ;call command function to select a particular column
				
		column_set: 
		ret ;for set_column
		
		set_pg_cntrl: ;Selects one of 8 vertical pages, each representing 8 rows of pixels.
			
			
			mov b,a ;copy a in reg-b temporarily
			
			mov a,18h 
			
			jnz rhalf
			
			clr p2.4 ;select left half
			setb p2.5
			
			sjmp done
			
			rhalf: ;if carry isn't 1 set screen to left half
			
			setb p2.4
			clr p2.5
			
			done:mov a,b
			add a,#0b8h ;add numbers form 0 to 7 to b8h to select any pg out of the available 8 pgs
			acall cmdwrt
			
			
		ret ;for set_pg_cntrl
		
		set_pg: ;Selects one of 8 vertical pages, each representing 8 rows of pixels.
			
			clr p2.5
			clr p2.4
			
			add a,#0b8h ;add numbers form 0 to 7 to b8h to select any pg out of the available 8 pgs
			acall cmdwrt
			
		ret ;for set_pg
		
		clrscreen:
		
				push psw
				clr psw.3
				clr psw.4
				mov r0,#00h ;page transversing index element
				mov r1,#00h ;column counter
				mov r4,#8d ;page counter
				loop3:mov a,r0
				acall set_pg
				inc r0
				
				mov r6,#16d ;for transversing across 16 grid pixels
				

				loop2:mov a,r1
				acall set_column
				inc r1
				
				clr a
				mov r7,#8d ;loop counter clearing individual columns of a grid pixel
				loop1:acall datawrt
				djnz r7,loop1
				
				djnz r6,loop2
				
				mov r1,#00h ;column counter

				djnz r4,loop3
				
				pop psw
		
		ret ;for clear screen
		
		display_dot:
		
			push psw
			clr psw.3
			clr psw.4
			
			mov r0,#8d ;individual column counter
			mov a,#0ffh
			dot_loop:acall datawrt
			djnz r0,dot_loop
			
			pop psw
		
		ret ;for display_dot
		
		calc_pos: ;subroutine to calculate position of head
		
				push psw
				setb psw.4 ;reg-bank-2
				clr psw.3
				
;		*****For Our Case p0.0->Right, p0.1->Left, p0.2->Up, p0.3->Down*****
				
				mov a,b
				
				cjne a,#00h,nxt_01
				inc r1 ;mov snake's head in +-ve x direction
				mov a,r1
				
				anl a,#0fh
				acall set_column
				
				mov a,r2 ;to maintain the page appropriately
				anl a,#0fh
				acall set_pg_cntrl
				
				sjmp ext
				
				nxt_01:
				
				cjne a,#01h,nxt_02
				dec r1 ;mov snake's head in -ve x direction
				mov a,r1
				anl a,#0fh
				acall set_column
				
				mov a,r2 ;to maintain the page appropriately
				anl a,#0fh
				acall set_pg_cntrl
				
				sjmp ext
				
				nxt_02:
				
				cjne a,#02h,nxt_03
				dec r2
				mov a,r2 ;dec y coordinate; y--
				anl a,#0fh
				acall set_pg_cntrl
				
				mov a,r1 ;to maintain the column appropriately
				anl a,#0fh
				acall set_column
				
				sjmp ext
				
				nxt_03:
				
				inc r2
				mov a,r2
				anl a,#0fh
				acall set_pg_cntrl
				
				mov a,r1 ;to maintain the column appropriately
				anl a,#0fh
				acall set_column
		ext:
				pop psw
				
		ret ;for calc_pos subroutine
		
end