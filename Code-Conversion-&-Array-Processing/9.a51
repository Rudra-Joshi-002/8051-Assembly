;Write a program to find the smallest number from a given array.

org 0000h
	
	;initializtion of arrray
	
	mov dptr, #0100h   ; Initialize DPTR to start address 0100h
    
	mov a, #55h        ; 85(10) Load A with the first random value
    movx @dptr, a      ; Store the value in external RAM at DPTR
    inc dptr           ; Increment DPTR to next address
    
	mov a, #64h        ; 100(10) Load A with the next random value
    movx @dptr, a
    inc dptr

    mov a, #0A3h        ; 163(10) Next random value
    movx @dptr, a
    inc dptr

    mov a, #4Bh        ; 75(10) Next random value
    movx @dptr, a
    inc dptr

    mov a, #2Fh        ; 47(10) Next random value
    movx @dptr, a
    inc dptr

    mov a, #0D8h        ; 216(10) Next random value
    movx @dptr, a
    inc dptr

    mov a, #7Ch        ; 124(10) Next random value
    movx @dptr, a
    inc dptr

    mov a, #0ffh        ; 255(10) Next random value
    movx @dptr, a
    inc dptr

    mov a, #9Eh        ; 158(10) Next random value
    movx @dptr, a
    inc dptr

    mov a, #3Ah        ; 58(10) Last random value for array of size 10
    movx @dptr, a

	;main code segment
	clr a
	mov r0,#0ffh ;where smallest number will be stored
	mov r1,#10d
	mov dptr,#0100h
	
	repeat: movx a,@dptr
	
	cjne a,00h,next //00h address of r0 in internal ram
	
	sjmp ahead
	
	found: mov r0,a
	sjmp ahead
	
	next: jc found
	ahead:inc dptr
	djnz r1,repeat
	
	here: sjmp here
	
end