.data

.balign 4
printformat: .asciz "%d\n"

.balign 4
delimitor: .asciz "+,-"

.balign 4
return: .word 0

.text
.global printf
.global scanf
.global strtok
.global atoi
.global main

main:

	ldr r2, [r1, #4] /*loads argv[1] into r2 */ 	

	ldr r1, =return
	str lr, [r1] 

	mov r0, r2
	ldr r1, =delimitor
	bl strtok /*stores pointer to token in r0*/    

	bl atoi /* converts string token to int */


	mov r1, r0
	ldr r0, =printformat
	bl printf

	ldr lr, =return
	ldr lr, [lr]
	bx lr
