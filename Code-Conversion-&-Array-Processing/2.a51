;Write a program to convert an 8-bit BCD number 
;to its equivalent binary number.

;First, each digit should be unpacked. Then, the hundred’s (100’s) digit is multiplied with 100, the ten’s digit is multiplied with 10 and the one’s
;digit is multiplied with 1. Results of all operations (multiplications) are added to get the result in the binary. In general, 10N’s digit is multiplied
;with 10N, 10N–1’s digit is multiplied 10N–1 and so on up to 100’s (one’s) digit. And all results are added.
;For example, consider the two-digit BCD number 29, for simplicity.
;29 is unpacked and stored as 02 and 09.
;02 is multiplied with 0AH and 09 is multiplied with 1H.
;02 x 0AH = 14H, 09 x 1 = 09H
;These two results are added
;14H + 09H = 1D H= 00011101B which is the binary equivalent of 29 BCD.
;(Multiply by 1 operation may be skipped.)

org 0000h
	
	mov r0,#99h
	
	mov a,r0
	anl a,#0f0h
	swap a
	mov b,#10d
	mul ab
	mov b,a
	mov a,r0
	anl a,#0fh
	add a,b
	mov r1,a

end