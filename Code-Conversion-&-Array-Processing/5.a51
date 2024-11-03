;Write a program to convert an 8-bit binary number 
;into its equivalent ASCII number.

;This conversion is required when we need to display numbers 
;in decimal number system on standard output devices like 
;the LCD or monitor of a PC.
;First, the binary number is converted into a BCD number and 
;then the BCD number is converted into ASCII.

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
	
	mov r0,#65h
	mov a,r0
	
	acall bin2ascii
	
	here: sjmp here
	
	bin2ascii:
	
	mov b,#100d
	div ab
	orl a,#30h
	mov r1,a
	mov a,b
	mov b,#10d
	div ab
	orl a,#30h
	mov r2,a
	orl b,#30h
	mov r3,b

	ret

end	
	