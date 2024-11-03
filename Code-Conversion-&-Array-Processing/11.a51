;Write a program to arrange a given array of 10 elements in descending order.

;In the first iteration, the array pointer is initialized with the address of the first element, the first element of array is compared with second,
;bigger of these two will be placed at the first location, this way first element is compared with all elements one by one and thus, the biggest
;number is brought to the first location of the array. In the next iteration, the pointer is initialized with the address of the second element; now,
;this element is compared with rest of the array elements and in this way, the next biggest element is brought to the second element. This
;process is repeated until the pointer is moved across all the elements of the array.


org 0000h
	
	;initializtion of arrray
	
	mov dptr, #0010h   ; Initialize DPTR to start address 0010h
    
	mov a, #55h        ; 85(10) Load A with the first random value
    movx @dptr, a      ; Store the value in external RAM at DPTR
    inc dptr           ; Increment DPTR to next address
    
	mov a, #64h        ; 100(10) Load A with the next random value	`
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
	
	mov r0,#10h ;ptr
	mov r1,#11h ;another ptr which will be compared
	mov r2,#9d ;inner loop iterator
	mov r3,#9d ;outer loop iterator
	mov r5,#9d ;to keep decreasing the comaprision size after each iteration
	mov r6,#12h ;to keep proper addressing of r1
	
	loop2: mov dpl,r0 ;this shit was done beacuse my simulator didn't support movx @ri,a type instruction sets & I don't know why
	movx a,@dptr
	mov r4,a ;stores first element and temp data
	
	loop1: mov dpl,r1
	movx a,@ dptr
	cjne a,04h,next
	
	sjmp skip
	
	greater_thn:
	mov dpl,r0
	movx @dptr,a
	
	mov b,a ; copy smaller in b
	
	mov a,r4 ;copy value which was used for comaprision
	mov dpl,r1
	movx @dptr,a
	
	mov r4,b ;update smaller value
	
	sjmp skip
	
	next:jnc greater_thn
	
	skip:inc r1 ;increment inner loop pointer for transversing array
	
	djnz r2,loop1
	
	mov a,r6 ;copy new address to be updated
	mov r1,a ; for next iteration
	
	inc r6 ; increase for iteration after that
	
	dec r5 ; decrement counts upto which one has to transverse array
	mov a,r5 ; these things are done for that
	mov r2,a ; yes...!!! this too
	
	inc r0 ; increment the for further addressing
	
	djnz r3,loop2
	
	here: sjmp here
	
	
end