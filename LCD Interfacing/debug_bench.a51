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
	
org 002bh
	
	;here register bank-0 is for all lcd operations
	
	main:
	
	mov sp,#20h ; initialze stack pointer to place other than register bank addresses
	
	lcall lcd_initialization
	
	lcall create_custom_char1 ;load custom character into CGRAM of LCD
	
	lcall display_title ;display title of project
	
	mov a,#01h ;clr display
	lcall cmdwrt
	
	lcall snake_game
	
	here: sjmp here
	
	org 100h ;space to write LCD Subroutines + Animation Subroutines
		
	cmdwrt:
	
		acall check_busy_flag; wait till lcd is ready to accept new instruction
		mov p1,a
		clr p3.3 ; select rs to write command
		clr p3.4 ; select r/w to write mode
		setb p3.5 ; set enable signal
		acall delay
		clr p3.5 ; give a high to low pulse
		
	ret ;for cmdwrt
	
	datawrt:
	
		acall check_busy_flag; wait till lcd is ready to accept new instruction
		mov p1,a
		setb p3.3 ; select rs to write data
		clr p3.4 ;select r/w to write mode
		setb p3.5 ; set enable signal
		acall delay
		clr p3.5 ; give a high to low pulse
		
	ret ;for datawrt
	
	check_busy_flag: ;subroutine that checks the status of busy flag based on above mentioned conditions
	
		clr p3.3 ; clr rs
		setb p3.4 ;set r/w to 1 for reading from LCD
		back:clr p3.5 ;clr enable for low to high pulse to be given
		acall delay ; delay to generate a low pulse
		setb p3.5 ; set enable so that busy flag is now made availabe for reading at D7 of lcd
		
		jb p1.7,back ; check
	ret ;for check_busy_flag
	
	dboun: ;delay subroutine for keypad
		mov r6,#10d 
		dloop2:mov r7,#250d
		dloop1:nop
		nop
		djnz r7,dloop1
		djnz r6,dloop2
	ret
	
	delay:;2ms delay assuming clk freq 12MHz
	
		mov r3,#50
		here2:mov r4,#255
		here1:djnz r4,here1
		djnz r3,here2
		
	ret ;for delay
	
	delay500ms: ;500msec delay generation assuming 12Mhz Clk
	
		mov r0,#10d ;50ms delay is to be repeated 10 times
		mov tmod,#01h ;set timer-0 mode-1
		
		repeat_500ms: mov th0,#3ch ;load the count into timers
		mov tl0,#0b0h
		setb tr0
		wait_500ms: jnb tf0,wait_500ms ;wait till timer overflows
		clr tr0
		clr tf0
		djnz r0,repeat_500ms ;repeat loop 40 times
		
	ret ;for delay500ms
	
	delay1s: ;1sec delay generation assuming 12Mhz Clk
	
		mov r0,#20d ;50ms delay is to be repeated 20 times
		mov tmod,#01h ;set timer-0 mode-1
		
		repeat_1s: mov th0,#3ch ;load the count into timers
		mov tl0,#0b0h
		setb tr0
		wait_1s: jnb tf0,wait_1s ;wait till timer overflows
		clr tr0
		clr tf0
		djnz r0,repeat_1s ;repeat loop 40 times
		
	ret ;for delay1s
	
	delay2s: ;2sec delay generation assuming 12Mhz Clk
	
		mov r0,#40d ;50ms delay is to be repeated 40 times
		mov tmod,#01h ;set timer-0 mode-1
		
		repeat_2s: mov th0,#3ch ;load the count into timers
		mov tl0,#0b0h
		setb tr0
		wait_2s: jnb tf0,wait_2s ;wait till timer overflows
		clr tr0
		clr tf0
		djnz r0,repeat_2s ;repeat loop 40 times
		
	ret ;for delay2s
	
	delay3s: ;3sec delay generation assuming 12Mhz Clk 
	
		mov r0,#60d ;50ms delay is to be repeated 60 times
		mov tmod,#01h ;set timer-0 mode-1
		
		repeat_3s: mov th0,#3ch ;load the count into timers
		mov tl0,#0b0h
		setb tr0
		wait_3s: jnb tf0,wait_3s ;wait till timer overflows
		clr tr0
		clr tf0
		djnz r0,repeat_3s ;repeat loop 60 times
		
	ret ;for delay3s
	
	delay5s: ;5sec delay generation assuming 12Mhz Clk 
	
		mov r0,#100d ;50ms delay is to be repeated 100 times
		mov tmod,#01h ;set timer-0 mode-1
		
		repeat_5s: mov th0,#3ch ;load the count into timers
		mov tl0,#0b0h
		setb tr0
		wait_5s: jnb tf0,wait_5s ;wait till timer overflows
		clr tr0
		clr tf0
		djnz r0,repeat_5s ;repeat loop 60 times
		
	ret ;for delay5s
		
	display_string: ;subroutine to display a string form lookup table
	
		mov r0,#00h	; Initialize index for looping through the string
		
		back2nxt:mov a,r0 ;mov cuurent index into a
		movc a, @a+dptr ; Load the character from the string
		
		lcall datawrt ; Call datawrt to display the character           
		
		inc r0 ;increment index to access next character
		mov a,r0 ;mov new index back into reg-a
		movc a, @a+dptr ;access then new character
		
		cjne a,#00h,back2nxt  ; If not end of string (null terminator), loop
	ret ;for display_string
	
	create_custom_char1:
		
		mov a,#40h ; Set CGRAM address for Custom Char 1
		lcall cmdwrt
		
		mov dptr,#cch1  ; Point to the start of the custom character table (cc=custom charcter)
		mov r0,#00h     ; Row counter (0-7)
		
		cc1:
		mov a,r0 ;load the index into reg-a       
		movc a,@a+dptr ; Get the row data for Custom Char 1
		lcall datawrt
		inc r0  ; Increment row counter to access the data for next row of c.c.
		mov a,r0
		cjne a,#08h,cc1 ; Repeat until 8 rows are stored
		
	ret ;for create_custom_char1
	
	lcd_initialization:
	
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
	
	ret ;for lcd_initilization
	
	display_title:
	
		mov a,#0fh ; dispaly on cursor blinking
		lcall cmdwrt

		mov a,#01h ;clr display
		lcall cmdwrt

		mov a,#84h; shift cursor to 5th Position of 1st line
		lcall cmdwrt

		mov dptr,#string1 ;"G-Yantra"

		lcall display_string

		mov a,#0c1h ;shift curosr to 2nd positon of 2nd line
		lcall cmdwrt

		mov dptr,#string2 ;"Gaming Yantra"

		lcall display_string

		mov a,#0ch ;set lcd to display on cursor off mode
		lcall cmdwrt

		lcall delay2s ; give user time to read the contents of screen
		
		mov a,#0fh ; dispaly on cursor blinking
		lcall cmdwrt
		
		mov a,#84h; shift cursor to 5th Position of 1st line now to display G in Hindi Script
		lcall cmdwrt
		
		mov a,#00h ;display 1st cc "g" in Hindi
		lcall datawrt
		
		mov a,#0ch ;set lcd to display on cursor off mode
		lcall cmdwrt
		
		lcall delay3s
	
	ret ;for display_title
	
	org 0003h ;keyboard logic is written here
		
		ljmp main_isr ;isr for external interrupt-0 starts here
		return: reti
	
	org 0400h
		
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
			mov b,a; *****Reg-B stores the value of direction control*****
			clr psw.3; reset the register bank for lcd display puropses
			clr psw.4
			ljmp return
			
			org 0500h ;Look-Up to store Strings
		
			;00h is used here to represent a null character indicating the termination of a string
			
			string1:db "G-Yantra",00h ; length of string-8 (Total Length=9 Including Null Character) 
			string2:db "Gaming-Yantra",00h ; length of string-13 (Total Length=14 Including Null Character)
				
			org 0600h ;Look-Up Table to Store Custom Characters Which Will be Loaded in CGRAM when needed
		
				cch1:db  1fh,05h,05h,05h,1dh,15h,19h,01h ;this is hindi character  "g"
			
			org 0650h ;Look-Up Table To Map Out LCD Cursor Positions Based on Coordinate Values
			
				y0:db 80h,81h,82h,83h,84h,85h,86h,87h,88h,88h,89h,8ah,8bh,8ch,8dh,8eh,8fh ;values if y=0
				y1:db 0c0h,0c1h,0c2h,0c3h,0c4h,0c5h,0c6h,0c7h,0c8h,0c9h,0cah,0cbh,0cch,0cdh,0ceh,0cfh ;values if y=1
					
			org 0675h ;Look-Up Table to Store Snake Characters
				
				head:db "x"
				body:db "o"
				tail:db "*"
			
			org 0700h ; Logic for Snake Game Starts Here
				
				snake_game:
		
;		before starting the main logic here are some things to help you get started with game logic development
;		_________________________________________________________________________________________________________________________________________________________________
;		
;		1. Game Grid and Snake Representation:
;		
;		Objective: Define a grid on the LCD where the snake and food can be represented and managed. 
;		Since the LCD is limited in size, we’ll treat it as an 16x2 grid on a 16x2 LCD.
;		
;		Details:

;		The game grid is a virtual 8x2 matrix, where each cell represents a position the snake can occupy.

;		Each cell can be stored as an 8-bit value, with the high nibble representing the Y-axis (rows) 
;		and the low nibble representing the X-axis (columns).
;		
;		for example:

;		(0, 0) would be 0x00, (1, 0) would be 0x10, (0, 1) would be 0x01, and so forth.
;		
;		Memory Representation: The snake’s body consists of a sequence of these positions stored in a register array or memory space, 
;		where the head of the snake is the first element, and the last element represents the tail. Each time the snake moves, 
;		the head’s position is updated in a direction dictated by the player’s input, and each body segment follows the one before it, 
;		creating the effect of movement.
;		
;		*****For Our Case to Store all these postions of different parts of snake we will you RAM Location form 30h to 7fh which are General Purpose Registers*****
;		
;		Tasks for the 8051:

;		Initialize Snake Position: The starting position of the snake (e.g., at the top-left of the screen) 
;		should be initialized in memory, such as 0x00.
;	
;		Length Management: A length counter should be maintained, incremented when the snake eats food, 
;		to track how many body segments are on the screen.
;		
;		The 8051 will handle reading these values, calculating new positions as the game progresses, 
;		and mapping each position on the grid to an addressable location on the LCD.
;		_________________________________________________________________________________________________________________________________________________________________
;		
;		2. Key Inputs and Direction Control
;		
;		Objective: Enable directional control of the snake via interfaced keys, allowing for 
;		up, down, left, and right movements.

;		Details:

;		Port Assignment: Assign specific pins on an 8051 port (e.g., Port 0) to represent the direction keys.
;		For example, P0.0 could be for "up," P0.1 for "down," P0.2 for "left," and P0.3 for "right."
;		
;		In our the action of keyboard is Interrupt Based which saves time since we don't have to regulary poll the keyboard
;		
;		*****For Our Case p0.0->Right, p0.1->Left, p0.2->Up, p0.3->Down*****
;		
;		Tasks for the 8051:

;		Direction Register Update: Store the direction in a register, 
;		with a specific bit pattern representing each direction.
;			
;		The 8051 will detect the direction changes by checking the port pins and updating the direction register accordingly. 
;		It will then use this register to compute the new head position in the grid.
;		_________________________________________________________________________________________________________________________________________________________________
;	    
;		3. Main Game Loop Structure

;		Objective: Organize the core functions of the game into a structured loop that continuously updates based on player input and game state.

;		Details:

;		Game Cycle: The game operates in a continuous loop, where each cycle includes:

;		Input Reading – Detect key presses and adjust the direction if necessary.
;		
;		Position Update – Calculate the new head position based on the current direction and shift all other segments.
;		
;		Collision Detection – Check if the snake’s head has hit the boundaries of the grid or any part of its body.
;		
;		Display Update – Refresh the LCD display to show the snake in its new position.
;		
;		Delay (Speed Control) – A small delay to control the speed of the game.
;		
;		Timer for Loop Speed: Use Timer 0 to trigger an interrupt at regular intervals, creating a fixed game loop speed.

;		Tasks for the 8051:

;		Execute Sequence in Interrupt: Configure Timer 0 to overflow and trigger an interrupt every few milliseconds. 
;		This interrupt will trigger the above sequence in each cycle.
;		
;		In each loop, the 8051 updates the game state based on inputs and ensures consistent gameplay.
;		_________________________________________________________________________________________________________________________________________________________________
;		
;		4. Snake Movement Logic
;		
;		Objective: Move the snake in the direction specified by the player, shifting all body segments appropriately.

;		Details:

;		Direction-based Head Position Calculation: Depending on the current direction, 
;		the 8051 calculates the new head position by adjusting either the X or Y component of the coordinate.

;		If moving right, increase the X value, 
;		if down, increase Y
;		if left, decrease X 
;		if up, decrease Y.
;		
;		Shift Body Segments: The rest of the snake’s body follows the head. 
;		This is achieved by copying the position of each segment to the next one in the sequence, 
;		starting from the tail.
;		
;		Tasks for the 8051:

;		Coordinate Update: Calculate the head’s new (x, y) value 
;		and update the memory location holding the head’s position.
;		
;		Shift Operation: Copy each body segment’s position to the one after it, 
;		effectively “moving” the snake.
;		
;		This process creates the illusion of the snake moving forward, 
;		with the tail trailing the head.
;		_________________________________________________________________________________________________________________________________________________________________
;		
;		5. Collision Detection Mechanism
;		
;		Objective: Detect if the snake’s head has collided with a boundary or with itself, 
;		which would end the game.

;		Details:

;		Boundary Check: The snake must stay within the defined grid. 
;		The head position is checked against the grid’s bounds after each move.
;		
;		If the head’s X or Y value exceeds the limits, it indicates a boundary collision.
;		
;		Self-collision Check: Compare the head position with each body segment’s position 
;		to determine if it has intersected with itself.
;			
;		Tasks for the 8051:

;		Boundary Condition: Use conditional checks to see if the head’s 
;		(x, y) value is within the grid’s limits.
;			
;		Self-check Loop: Implement a loop to compare the head’s position 
;		with every segment in the body list.
;		
;		If a collision is detected, the 8051 initiates a game-over sequence by halting the game loop 
;		and displaying an end message on the LCD.
;		_________________________________________________________________________________________________________________________________________________________________
;		
;		6. Food Generation and Snake Growth
;		
;		Objective: Randomly place a food item on the grid, which the snake can "eat" to grow in length.

;		Details:

;		Random Food Position: Use a pseudo-random function based on the timer 
;		to generate food coordinates that don’t overlap with the snake’s body.
;		
;		Snake Growth: Increase the snake’s length by one segment 
;		when the head reaches the food position.
;		
;		Tasks for the 8051:

;		Random Positioning: Use the timer’s value as a seed to generate food coordinates.
;		
;		Growth Mechanism: Increment the snake’s length register when food is eaten, 
;		enabling a new segment to appear on the next update.
;		
;		After consuming food, the 8051 will recalculate the snake’s length,
;		making the game progressively harder.
;		_________________________________________________________________________________________________________________________________________________________________
;		
;		7. LCD Display Updates
;		
;		Objective: Visually update the LCD screen to reflect 
;		the game’s current state by showing the snake and food.

;		Details:

;		Coordinate to LCD Mapping: Convert the grid’s (x, y) positions to LCD addresses.
;		
;		LCD Writing: Use the LCD’s character addresses to display the snake and food.
;		
;		Clear Old Positions: Clear the previous tail position and refresh 
;		the display with each new position update.
;		
;		Tasks for the 8051:

;		Cursor Positioning: Use specific commands to set the LCD cursor based on the grid coordinates.
;			
;		Writing Snake and Food: Display the snake segments 
;		by sending unique characters (e.g., solid blocks) to the LCD.
;		
;		Each loop update rewrites the snake’s new head position and clears the tail, 
;		ensuring that only the necessary parts of the LCD are updated.
;		_________________________________________________________________________________________________________________________________________________________________
;		
;		8. Game Over and Reset Sequence
;		
;		Objective: End the game if a collision is detected, 
;		display a game-over message, and allow the player to restart.

;		Details:

;		Collision-triggered Message: Stop the game and display "Game Over" 
;		on the LCD if a collision is detected.
;		
;		Reset Mechanism: Wait for a specific input to reinitialize 
;		the game’s variables and restart the game loop.
;		
;		Tasks for the 8051:

;		Display Message: Clear the LCD and write a game-over message.
;		
;		Reset Condition Check: Monitor a reset key to restart the game, 
;		reinitialize variables, and return to the initial state.
;		
;		The 8051 will halt all game updates and wait for the reset 
;		input to reinitialize the game.
;		_________________________________________________________________________________________________________________________________________________________________
;		
;		9. Speed Control Using Timer
;		Objective: Adjust the game speed based on the snake’s length or score.

;		Details:

;		Dynamic Timer Adjustment: Decrease the delay interval in the timer as the snake grows, 
;		making the game more challenging.
;		
;		Tasks for the 8051:

;		Timer Reload Value Update: As the snake grows, reduce the Timer 0 reload value, 
;		increasing the frequency of game loop executions.
;		
;		This speed control makes the game more dynamic, 
;		challenging the player to keep up with the faster pace.
;		_________________________________________________________________________________________________________________________________________________________________

			clr psw.3 ;set Reg-Bank-2 For Game Operations
			setb psw.4
		
		;lets clear what each register of this register bank represents:
		;r0->stores the value of ram location 30h from where the coordinates of snakes body position can be accessed
		;r1->stores the coordinates of head of snake
		;r2->stores the coordinates of tail of snake
		;r3->stores the direction in which the snake is supposed to move currently acts as direction register
		;r4->stores the length of the midlle body section of snake
		;r5->stores the score of snake
		;r6,r7->these are kept free for any copying use in any game related operation
		
			mov r0,#30h ;store the value of ram locations that will be used to store body coordinates
			
			;set the intial coordinates of snake: head->(y,x)=>0,2, body->0,1, tail->0,0
			mov r1,#02h
			mov @r0,#01h
			mov r2,#00h
			
			mov r3,#00h;initially start moving towards right
			mov r4,#1d;length at start contains only one middle section
			mov r5,#00d; set the initial score to 00
			
			test:
			lcall update_lcd
			lcall calc_pos
			lcall update_pos
			lcall delay1s
			sjmp test
			
		
		
		ret
		
		org 0900h ;use this location to store subroutines assocaited with game logics
			
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
				anl a,#0fh ;set upper nibble to zero i.e. y=0
				mov r1,a
				sjmp ext
				
				nxt_03:
				
				mov a,r1
				orl a,#10h; set the upper nibble to 1 i.e. y=1
			
			ext:
			ret ;for calc_pos subroutine
			
			update_pos: ;this subroutine updates the coordinates of snakes body exluding head
				
				setb psw.4 ;reg-bank-2
				clr psw.3
				
				mov b,r2 ;store the previous tail location in b to later clear it
				
				mov a,r4 ;store length of middle body in reg-a
				
				cjne a,#01h,len_nt_1 ;check for default movment till the length is not increased to more than 1
				
				mov a,@r0 ;mov the coordinates of middle position to tail 
				mov r2,a
				
				mov a,r6; store the old snake heads position to middle segment
				mov @r0,a
				
				sjmp ext_1
				
				len_nt_1:
				
				mov a,r4 ;store the actual length temporary in r7 
				mov r7,a
	
				dec r4 ;length decremented here to make array processing easy
				
				mov a,r0 ;store the last element address by adding the index value to r0
				add a,r4
				mov r0,a
				
				dec r0
				
				mov a,r0; store the address of higher in reg-1 of reg-bank-3 
				
				setb psw.3 ;change to Reg-Bank-3 For Accessing other arrays
				setb psw.4
				
				mov r1,a ;use r1 of reg-bank-3 as pointer in this case I know its Awfull But Theres Nothing I can Do Every other Register Is Occupied At This Pt
				
				clr psw.3 ;change to reg-bank-2 for other operations
				setb psw.4
				
				inc r0 ;set r0 to original indexed value
				
				mov a,@r0 ;store the position of segment after tail to tail
				mov r2,a
				
				iterate:setb psw.3 ;change to Reg-Bank-3 For Accessing other arrays
				setb psw.4
				
				mov a,@r1 ;bring the upper body seg coordinated to reg-a
				dec r1 ;to point to coordinates of next segment
				
				clr psw.3
				setb psw.4
				
				mov @r0,a ;shifting of upper coordinates to lower ones
				
				dec r0
				
				cjne r0,#30h,iterate ;shift all upper elements to lower ones till r0 becomes 30h
				
				mov a,r6 ;load old coordinates of snakes head to last segment closest to head
				mov @r0,a
				
				mov a,r7 ;fill r4 with body's original length
				mov r4,a
				
			ext_1:
			ret ;for update_pos
			
			update_lcd: ;this function converts the coordinates to lcd values and displays the same
				;lcd clr and cursor off yet to be given
				mov a,b
				
				anl a,#0f0h
				swap a
				
				jnz y_1
				
				mov a,b
				mov dptr,#y0
				
				movc a,@a+dptr; set the curosr at tails old coordinates
				lcall cmdwrt
				
				mov a,#' ' ;clr the previous tail position with empty space
				lcall datawrt
				
				sjmp go1
				
				y_1: ;if tail is at y=1 and x=something then
				
				mov a,b
				mov dptr,#y1
				mov a,#0fh
				movc a,@a+dptr; set the curosr at tails old coordinates
				lcall cmdwrt
				
				mov a,#' ' ;clr the previous tail position with empty space
				lcall datawrt
				
				go1:
				
				;update new coordinates of snake
				
				;update tail
				clr a ;store the tails character in reg-6
				mov dptr,#tail
				movc a,@a+dptr
				mov r6,a
				 
				
				mov a,r2 ;store the new coordinates of tail in a
				anl a,#0f0h
				swap a
				
				jnz tail_updt_y1
				
				mov dptr,#y0 ;point to values of y0
				mov a,r2
				movc a,@a+dptr ;load lcd postion from L.U.T.
				
				lcall cmdwrt ;set cursor to this position
				
				mov a,r6
				lcall datawrt ; display the new position
				
				sjmp body_updt
				
				tail_updt_y1:
				
				mov dptr,#y1; point to values of y1
				mov a,r2
				anl a,#0fh
				
				movc a,@a+dptr
				
				lcall cmdwrt
				
				mov a,r6
				lcall datawrt
				
				;update body
				body_updt:
				
				mov a,r4;copy body length in r7 for looping purposes
				mov r7,a
				
				clr a ;store the value of body character in reg-6
				mov dptr,#body
				movc a,@a+dptr
				mov r6,a
				
				bd_updt_loop:
				
				mov a,@r0
				anl a,#0f0h
				swap a
				
				jnz bd_updt_y1
				
				mov dptr,#y0
				mov a,@r0 ;fetch the coordinates form value pointed by r0
				movc a,@a+dptr
				lcall cmdwrt ;set cursor to new position
				
				mov a,r6
				lcall datawrt ;update lcd with body char
				
				sjmp bd_loop
				
				bd_updt_y1:
				
				mov dptr,#y1
				mov a,@r0 ;fetch the coordinates form value pointed by r0
				anl a,#0fh
				movc a,@a+dptr
				lcall cmdwrt ;set cursor to new position
				
				mov a,r6
				lcall datawrt ;update lcd with body char
				
				bd_loop:inc r0
				
				djnz r7,bd_updt_loop
				
				mov r0,#30h; load r0 original value back to r0
				
				;update head
				
				clr a ;store the head character in r6
				mov dptr,#head
				movc a,@a+dptr
				mov r6,a
				
				mov a,r1 ;load the coordinates of head in reg-a
				anl a,#0f0h
				swap a
				
				jnz head_updt_y1 
				
				mov dptr,#y0
				mov a,r1 ;set cursor to new head location
				movc a,@a+dptr
				lcall cmdwrt
				
				mov a,r6 ;update head on new location 
				lcall datawrt
				
				sjmp ext_2
				
				head_updt_y1:
				
				mov dptr,#y1
				
				mov a,r1 ;set cursor to new head location
				anl a,#0fh
				movc a,@a+dptr
				lcall cmdwrt
				
				mov a,r6 ;update head on new location 
				lcall datawrt
				
			ext_2:	
			ret ;for update_lcd
			
end