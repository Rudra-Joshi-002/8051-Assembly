;Write a program to convert an 8-bit binary number 
;to its equivalent packed BCD number.

mov a,#65h

mov b,#100d
div ab
mov r0,a

mov a,b
mov b,#10d
div ab
swap a
orl a,#0fh
orl b,#0f0h
anl a,b
mov r1,a

end



