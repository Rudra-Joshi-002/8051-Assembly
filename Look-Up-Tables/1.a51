//Write a lookup table, using the DPTR as the base, 
//that finds a two-byte square root of the number in A. 
//The first byte is the integer value of the root, 
//and the second byte is the fractional value. 
//For example, the square root of 02 is 01.6Ah.
//Calculate four first and last table values

//the following are values to be put for square roots
//of 1st four and last four numbers

//Square Root of 0x00 (approx. 0.00):
;Integer part = 0x00
;Fractional part = 0x00

;Square Root of 0x01 (approx. 1.00):
;Integer part = 0x01
;Fractional part = 0x00

;Square Root of 0x02 (approx. 1.6A):
;Integer part = 0x01
;Fractional part ˜ 0x6A

;Square Root of 0x03 (approx. 1.C4):
;Integer part = 0x01
;Fractional part ˜ 0xC4

;For the last four values of the table:

;Square Root of 0xFC (approx. 15.874):
;Integer part = 0x0F
;Fractional part ˜ 0xDE

;Square Root of 0xFD (approx. 15.936):
;Integer part = 0x0F
;Fractional part ˜ 0xEF

;Square Root of 0xFE (approx. 15.97):
;Integer part = 0x0F
;Fractional part ˜ 0xF9

;Square Root of 0xFF (approx. 16.00):
;Integer part = 0x10
;Fractional part = 0x00

org 0100h
	
	sqrt:
	
	db 00h,00h,01h,00h,01h,6ah,01h,0c4h
	db 0fh,0deh,0fh,0efh,0fh,0f9h,10h,00h
	
org 0000h
	
mov dptr,#sqrt
mov b,#02h
mov a,#03h
mov r2,a

cjne a,#0fh,here

here: jnc greater

mul ab

mov r2,a

movc a,@a+dptr

mov r0,a

inc r2

mov a,r2

movc a,@a+dptr

mov r1,a

here1: sjmp here1

greater:

mov dptr,#0108h

subb a,#0fch

mul ab

mov r2,a

movc a,@a+dptr

mov r0,a

inc r2

mov a,r2

movc a,@a+dptr

mov r1,a

here2: sjmp here2

end
