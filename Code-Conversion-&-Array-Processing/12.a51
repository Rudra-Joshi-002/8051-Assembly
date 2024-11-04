;Write a program to count the number of 1’s and 0’s in 
;a byte stored at internal RAM address 50H. Store count for 1’s in R0 and that
;for 0’s into R1.

ORG 0000H
	
	mov 50h,#0ffh ;initializing ram loaction with some value
	mov a,50h
	
	acall count
	
	here: sjmp here
	
	count:
	
	mov r3,#8d
	
	loop:rrc a
	
	jc one
	
	inc r1
	
	next:djnz r3,loop
	
	ret
	
	one:
	
	inc r0
	
	sjmp next
	
end