;Write a program to convert two bytes in ASCII 
;to the equivalent 2-digit (packed) BCD number.

;BCD digit 	Binary 		ASCII (HEX)
;0 			0000 		0011 0000 = 30
;1 			0001 		0011 0001 = 31
;2 			0010 		0011 0010 = 32
;3 			0011 		0011 0011 = 33
;4 			0100 		0011 0100 = 34
;5 			0101 		0011 0101 = 35
;6 			0110 		0011 0110 = 36
;7 			0111 		0011 0111 = 37
;8 			1000 		0011 1000 = 38
;9 			1001 		0011 1001 = 39

org 0000h
	
	mov r2,#35h
	mov r3,#36h
	
	mov a,r2
	anl a,#0fh
	swap a
	mov r0,a
	
	mov a,r3
	anl a,#0fh
	orl a,r0
	mov r0,a
	
end