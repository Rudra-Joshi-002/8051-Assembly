;Write a program to find 1’s and 2’s 
;complement of a given number.

;Assume that the number is stored at the internal RAM address 10H. 
;Result of 1’s complement is stored at the address r1 and that of 2’s
;complement is stored at r2.
;also 2's complement is found by adding 1 to 1's complement of given
;number

org 0000h
	
	mov 10h,#03h
	mov a,10h
	cpl a
	mov r1,a
	add a,#01h
	mov r2,a
	
end