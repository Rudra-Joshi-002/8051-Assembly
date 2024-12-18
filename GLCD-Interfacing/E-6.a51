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
;also on this display move a snake as per the user inputs

;---also the follwing register banks have been used for varoius operations---
; reg-0->LCD Operations
; reg-1->Keyboard Operations
; reg-2->Snake Game Operations
; reg-3->Random Use

org 0000h
	
		mov p0,#0ffh ;set p0 as input port
		
		setb p2.3 ;set rest pin to 1 i.e. inactive mode
		
		mov sp,#30h ;move sp to ram loaction 20h
		
		mov tmod,#02h
		mov th0,#00h
		setb tr0
		
		lcall delay ;some delay is introduced purposefully
		lcall delay
		lcall delay
		lcall delay
		lcall delay
		lcall delay
		
		mov a,#3fh
		
		lcall cmdwrt
		
		lcall clrscreen
		
		lcall snake_game
	
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
		
		display_char: ;subroutine to display a charcter form lookup table
			  ;r5,r0 of reg bak 1 used
				push psw
				
				mov psw ,#08h //reg bank 1
				mov r5,#00h	; Initialize index for looping through the string
				mov r0,#08
				back2nxt:
				mov a,r5 ;mov cuurent index into a
				movc a, @a+dptr ; Load the character from the string
				lcall datawrt ; Call datawrt to display the character           
				lcall delay ;call delay 
				inc r5 ;increment index to access next character
				djnz r0,back2nxt
				
				pop psw
		
		ret ;for display_character
		
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
		
		delay1s:;1sec delay generation assuming 12Mhz Clk
		;r7 and r6 of reg bank 0 used
		
			push psw
			
			mov psw ,#08h //reg bank 1
			mov r7,#04
			here0:mov r6,#250
			here10:mov r5,#250
			here20:
			nop
			nop
			djnz r5,here20
			djnz r6,here10
			djnz r7,here0
			
			pop psw
		
		ret ;for delay1s		
		
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
			
		ret ;for dboun
		
		set_column: ;selects a particular column form where to write data for a given selected page
			
			push b
			
			mov b,#08d ;to set the starting column address to the one meant by pixel grid value 
			mul ab
			mov b,a ;copy a in b for book-keeping
			
			subb a,#40h ;check if the number in accumulator is greater than 64 in decimal to take decision
			jnc right_half ;jump to right half if number is >=64 in decimal
			
			;logic for selecting on left half of screen
			
			mov 1ah,#00h ; r2 of reg-bank-3
			
			clr p2.4 ;set cs1 to select first half of glcd (actullay inverted logic is used for proteus simulation hence a bit change in these and rst instructions is seen)
			setb p2.5
			
			
			mov a,b ;reload a with original number
			add a,#40h ;add the number plus the 40h which is command for slecting 0th column in glcd
			
			acall cmdwrt ;call command function to select a particular column
			
			sjmp column_set
			
			right_half: ;logic for right of screen
			
			mov 1ah,#01h ; r2 of reg-bank-3
			
			setb p2.4 ;selecting right half of screen
			clr p2.5
			
			add a,#40h ;since for right half values we'll add to 40h
			acall cmdwrt ;call command function to select a particular column
				
		column_set: 
		
			pop b
			clr c
		ret ;for set_column
		
		set_pg_cntrl: ;Selects one of 8 vertical pages, each representing 8 rows of pixels.
			
			push b
			
			mov b,a ;copy a in reg-b temporarily
			
			mov a,1ah 
			
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
			
			pop b
			
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
		
org 500h;lookup tables	for char ; black=1 ;upper nibble =lower 4 bits of 8 bits of col
	
		clear:  db 00h,00h,00h,00h,00h,00h,00h,00h
		food: db 0ch, 12h, 22h, 44h, 44h, 22h, 12h, 0ch

		body_horizontal:db 18h,3ch,3ch,3ch,3ch,3ch,3ch,3ch,18h
		head_horizontal: db 18h,3ch,7eh,7eh,7eh,7eh,3ch,18h
		
		body_vertical:db 00h, 00h, 7eh, 0ffh, 0ffh, 7eh, 00h,00h
		head_vertical:db  00h, 3ch, 7eh, 0ffh, 0ffh, 7eh, 3ch, 00h
			
		body_right_head_down: db 18h,3ch,7ch,7ch,0fch,7ch,00h,00h		
		body_right_head_up:db 18h,3ch,3eh,3fh,3fh,3eh,00h,00h
		
		body_left_head_up: db 00h,00h,3eh,3fh,3fh,3eh,3ch,18h
		body_left_head_down:db 00h,00h,7ch,0fch,0fch,7ch,3ch,1ch
			
org 600h; snake game 
	
	snake_game:

			setb psw.4
			clr psw.3 ;set Reg-Bank-2 For Game Operations
			
			;lets clear what each register of this register bank represents:
			;r0->stores the value of ram location 30h from where the coordinates of snakes body position can be accessed
			;r1->stores the coordinates of head of snake
			;r2->stores the coordinates of tail of snake
			;r3->stores the direction in which the snake is supposed to move currently acts as direction register
			;r4->stores the length of the midlle body section of snake
			;not yet decided->stores the score of snake
			;r6,r7->these are kept free for any copying use in any game related operation
			;r5->food position
			
			;*-*-*-*-*Here Coordinates follow (y,x) System where y=rows= page number of glcd (0-7) and x=columns= 8x8 grid columns of glcd (0-fh)*-*-*-*-*
			
			mov r0,#30h ;store the value of ram locations that will be used to store body coordinates
			;set the intial coordinates of snake: head->(y,x)=>0,3, body->0,1, tail->0,1
			
			mov r1,#03h ;set initial head coordinates
			mov @r0,#02h ;set initial body coordinates
			mov r2,#01h	;set initial tail coordinates 
			
			mov r3,#00h ;initially start moving towards left
			mov r4,#00h ;length at start contains only one middle section
			mov r5,#54h ; set the initial food position 
			
			mov 19h,@r0 ;19h (r1 of reg-bank-3) for old body coord
			mov b,r2 ;b for old tail 
			
			mov a,r1
			mov r6,a ; r6 for old head
			mov 18h,r1 ;18h (r0 of reg-bank-3) for head
			
			mov a,r5 ; load a with initial food coordinates
			lcall choose_coord ;these instructions are concerned with displaying food at location present in r5
			mov dptr,#food
			lcall display_char
			
			lcall calc_pos
			lcall update_pos
			lcall update_lcd

			
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
				mov 13h,a; 13h (reg-3 of reg-bank-2) stores the direction coordinates
				lcall calc_pos
				lcall update_pos
				lcall update_lcd

				pop psw
				
				sjmp here
			
			choose_coord: ;this subroutine sets the cursor value to the coordinates contained in reg-a
			
					push acc
					
					mov r7,a ;a will contain coordinates which we would like to set as page and column
					
					anl a,#0fh
					lcall set_column
					
					mov a,r7 ;copy the coordinates saved temporarily back to reg-a
					anl a,#0f0h
					swap a
					lcall set_pg_cntrl
					
					
					pop acc
					
			ret ;for choose_coord
			
			calc_pos: ;subroutine to calculate position of head
				
				setb psw.4 ;reg-bank-2
				clr psw.3
	;		*****For Our Case p0.0->Right, p0.1->Left, p0.2->Up, p0.3->Down*****
				mov a,r1 ;store the old snake heads coordinates temporary in r6
				mov r6,a
					
				mov a,r3 ;mov direction info to reg-a
					
				cjne a,#00h,nxt_01
				inc r1 ;mov snake's head in +-ve x direction
				sjmp ext
					
				nxt_01:
					
				cjne a,#01h,nxt_02
				dec r1 ;mov snake's head in -ve x direction
				sjmp ext
					
				nxt_02:
					
				cjne a,#02h,nxt_03
				mov a,r1
				subb a,#10h ;set upper nibble to zero i.e. y=0
				mov r1,a
				sjmp ext
					
				nxt_03:
					
				mov a,r1
				add a,#10h ;set upper nibble to zero i.e. y=0
				mov r1,a
			
			ext:
			ret ;for calc_pos subroutine

			update_pos: ;this subroutine updates the coordinates of snakes body exluding head
				
				setb psw.4 ;reg-bank-2
				clr psw.3
				
				mov b,r2 ;store the previous tail location in b to later clear it
					
				mov a,@r0 ;mov the coordinates of middle position to tail 
				mov r2,a
				
				mov 19h,@r0
				
				mov a,r6; store the old snake heads position to middle segment
				mov @r0,a
				
				mov 18h,r6
				
				sjmp ext_1
				
			ext_1:
			ret ;for update_pos

			update_lcd: ;this function converts the coordinates to lcd values and displays the same
				;lcd clr and cursor off yet to be given
			
				setb psw.4 ;reg-bank-2
				clr psw.3
				
				acall clear_tail
				
				;remember that old tail coordinate after executing above subroutine still remains in reg-b
				
				acall update_tail_position
				
				acall update_body_position

				acall update_head_position
					
				mov a,r1 ; store new head position in r1
				cjne a,15h,exit_update_lcd ; compare head position 
				
				lcall food_pos ; update food_pos if it merge with head 
				
				exit_update_lcd:
				
			ret ;for update_lcd


			food_pos:
				
				clr psw.3 ;reg bank 2 selected
				setb psw.4
				push b
				mov 1fh,r5 ; r7 of reg bank 3
				mov r5,#09h ;timer instantaneous value in r5
				//mov a,r5
				
				mov a,r1      	;r1=05
				anl a,#0f0h   	;a=00
				mov b,a			;b=00
				mov a,r5		;a=08
				anl a,#0f0h;	;a=00
				subb a,b
				jnz jump	
				swap a			;a=00
				inc a			;a=01
				swap a			;a=10
				add a,r5		;a=18
				mov r5,a		;r5=18
				jump:
				mov a,1fh ;old food position in 1fh, replace with space
				;lcall choose_coord
				;mov dptr,#clear
				;lcall display_char
				mov a,r5			; mov food to location stored in r5
				lcall choose_coord
				mov dptr,#food
				lcall display_char
				pop b
				
			ret ;ret from food_pos
				
			clear_tail:
				
				mov a,b	; old tail in b
				lcall choose_coord 
				mov dptr,#clear
				lcall display_char
			
			ret;for clear tail
			
			update_tail_position:
				
				clr c
				mov a,r2 ;move current tail pos in a
				lcall choose_coord ;set coordinates based on current position on GLCD
				mov a,@r0 ;copy current body position in a
				subb a,19h ;compare current position with old body position by subtracting to know if a page is changed to detect vertical motion
				anl a,#0f0h	;mask the upper nibble and check for zero value. (reason after subtraction and masking, if a=0 then body movement is horizontal else its vertical)
				
				jz horizontal_tail ;if a is zero update tail to be horizontal else check other conditions (if not same body moving up r3=02 or down r3=03)
				
				clr c
				mov a,r2 ;if body is moving up or down (this was decided based on non-zero value of a in above instruction) then check tail coordinates  
				subb a,b ;if tail new and old pos same then tail is still horizontal
				anl a,#0f0h	;else tail vertical (mask upper nibble and check if tail is still on same page while body moving up or down)
				
				jz bented_tail	;here if a=0 then we need to show a bented animation for screen i.e. tail is seen changing horizontal towards vertical type chracter animation
				mov dptr,#body_vertical	;if a!=0 then both tail and body are moving vertically in this case we show vertical tail image on current tail position
				sjmp exit_tail ;thus after loading a vertical tail jump to display it
				
				bented_tail:
				
				clr c
				mov a,r3 ;(we come to this label when we want to dispay bented character on current tail position and for that we 1st move the direction coordinates in reg-a 
				subb a,#02h ;here subtarction from immdeiate value 02h helps determine direction of advance which is up or down 
				
				jz vertical_tail ;i.e. here if result of operation is zero then a=0 and we are moving upwards else we are moving downwards
				
				clr c ;clear c for subtarction purposes
				mov a,r2
				anl a,#0fh ;lower nibble is masked because left or right movement is associated with column
				mov 1bh,b ;temporarily copy old tail coordinate in 1bh r3 of reg-bank-3
				anl 1bh,#0fh
				subb a,1bh
				
				jnc brhd ;(body right head down) if carry is not set then situation is that body was moving right while head was moving down
				
				mov dptr,#body_left_head_down ;bented down charcter is loaded if condition of above instruction is not met
				sjmp exit_tail ;thus after loading bented tail jump to display it
				
				brhd:mov dptr,#body_right_head_down
				sjmp exit_tail
				
				vertical_tail:clr c ;clear c for subtarction purposes
				mov a,r2
				anl a,#0fh ;lower nibble is masked because left or right movement is associated with column
				mov 1bh,b ;temporarily copy old tail coordinate in 1bh r3 of reg-bank-3
				anl 1bh,#0fh
				subb a,1bh
				
				jnc brhu ;(body right head up) if carry is not set then situation is that body was moving right while head was moving up 
				
				mov dptr,#body_left_head_up ;but if we are moving up and carry is set then update the tail character accordingly
				sjmp exit_tail ;after doing it jump to display the same
				
				brhu: mov dptr,#body_right_head_up
				sjmp exit_tail
				
				horizontal_tail:mov dptr,#body_horizontal	;none in vertical
				
				exit_tail:lcall display_char
			
			ret ;for update_tail_position
			
			update_body_position:
				
				clr c
				mov a,@r0 ;load body position in reg-a
				lcall choose_coord ;set coordinates on glcd
				mov a,r1 ;load head pos in reg-a for comaprison purposes to determine direction of advance
				subb a,18h ;compare with old head position by subtarcting to see if any vertical movement is detected
				anl a,#0f0h	;mask the upper nibble and reg-a=0 then horizontal movement is there else head is moving vertically
				
				jz horizontal_body ;if new and old page is not same then head is moving either up r3=02 or down r3=03
				
				clr c
				mov a,@r0 ;if head is moving up or down then check body conditions  
				subb a,19h ;if body's new and old pos same then body is still horizontal but a bented animation requires to be shown on glcd
				anl a,#0f0h	;else body vertical
				
				jz bented_body ;if not zero then a vertical body requires to be shown				
				
				mov dptr,#body_vertical	;if both body and head moving vertically
				
				sjmp exit_body
				
				bented_body:clr c
				mov a,r3 ;load the direction information in reg-a
				subb a,#02h ;subtract it form a immediate value of #02h to know if body is moving up or down
				
				jz vertical_body ;if zero then body is moving upwards else it's moving downwards
				
				clr c ;clear c for subtarction purposes
				mov a,@r0
				anl a,#0fh ;lower nibble is masked because left or right movement is associated with column
				mov 1bh,19h ;temporarily copy body coordinate in 1bh r3 of reg-bank-3
				anl 1bh,#0fh
				subb a,1bh
				
				jnc brhd_1 ; head is moving down but body was moving right if carry is not set
				
				mov dptr,#body_left_head_down	;if only body vertical
				sjmp exit_body
				
				brhd_1:mov dptr,#body_right_head_down
				sjmp exit_body
				
				vertical_body:clr c ;clear c for subtarction purposes
				mov a,@r0
				anl a,#0fh ;lower nibble is masked because left or right movement is associated with column
				mov 1bh,19h ;temporarily copy body coordinate in 1bh r3 of reg-bank-3
				anl 1bh,#0fh
				subb a,1bh
				
				jnc brhu_1 ;body moving right while head was moving up
				
				mov dptr,#body_left_head_up
				sjmp exit_body
				
				brhu_1:mov dptr,#body_right_head_up
				sjmp exit_body
				
				horizontal_body:mov dptr,#body_horizontal	;none in vertical
				
				exit_body:lcall display_char
			
			ret ;for update_body_position
			
			update_head_position:
				
				clr c
				mov a,r1 ;load the current head coordinates in reg-a
				lcall choose_coord ;set the coordinates on GLCD
				subb a,18h ;subtract new coordinates form old ones
				anl a,#0f0h ;mask the upper nibble of the result to see new movement is in vertical direction
				
				jnz vertical_head ;if zero then head is moving horizontally else it is moving vertically
				
				mov dptr,#head_horizontal
				sjmp exit_head
				
				vertical_head:mov dptr,#head_vertical
				
				exit_head:lcall display_char
			
			ret ;for update_head_position
			
end