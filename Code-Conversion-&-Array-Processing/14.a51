;Write a program to find factorial of a number.

;here the program will find factorial of 3-bit number from 0 to 5
;since 5!=120 is the number that can be stored in 8-bits

org 0000h
	
	mov a,#03h
	
	acall factorial
	
	here: sjmp here
	
	factorial:
	
	jz skip ; check if accumulator is zero
	
	mov r2,a
	mov b,#01h
	
	loop:mul ab
	
	mov b,a ; store result in b
	
	dec r2
	mov a,r2 ; enter new multiplier in r2
	
	cjne r2,#01h,loop
	
	mov r0,b
	
	sjmp back
	
	skip: mov r0,#01h
	back:ret
end