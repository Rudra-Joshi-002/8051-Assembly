;Write a look-up table that converts the hex number in A (0-F) to
;its ASCII equivalent

org 0100h
		
	ascii:
	db 30h,31h,32h,33h,34h,35h,36h,37h,38h,39h
	db 41h,42h,43h,44h,45h

org 0000h
	
	mov dptr,#ascii
	mov a,#0a2h
	mov r2,a
	
	anl a,#0fh
	movc a,@a+dptr
	mov r0,a
	
	mov a,r2
	anl a,#0f0h
	swap a
	movc a,@a+dptr
	mov r1,a
	
end
