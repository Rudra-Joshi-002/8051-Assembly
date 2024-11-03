;Write a program to convert given 8-bit binary number 
;into its equivalent Gray number.

;To find the equivalent Gray number, the following operations are to be performed. Copy MSB of the binary number, G7=B7, G6=B7 EX-OR
;B6, G5= B6 EX-OR B5… G0= B1 EX-OR B0. 
;To perform EX-OR operation between two adjacent bits, the number is copied into other register
;and shifted to left by one position through carry. 
;Now, the original number and shifted number are EX-ORed (bit wise) with each other and the
;result is right shifted by one bit through carry.

org 0000h
	
	mov r0,#25h
	mov a,r0
	
	rrc a
	xrl a,r0
	
	mov r1,a
	
end