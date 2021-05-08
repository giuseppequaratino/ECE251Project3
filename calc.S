.data

.balign 4
printnum: .asciz "%d\n"

.balign 4
printops: .asciz "%s\n"

.balign 4
printerr: .asciz "%s\n"

.balign 4
delimitor: .asciz "+,-,*,/,^" /*add delimitors for each operation "+,-,*,/,^" worry about parentheses later*/

.balign 4
operator: .asciz "0,1,2,3,4,5,6,7,8,9,." /*delimitors for operands to find operators*/

.balign 4
opgt3: .asciz "Error: Number of arithmetic operators is greater than 3"

.balign 4
noop: .asciz "Error: No operators entered"

.balign 4 
noarg: .asciz "Error: Enter one argument"

.balign 4
input: .space 1024

.balign 4
input2: .space 1024

.balign 4
return: .word 0

.text
.global printf
.global scanf
.global strtok
.global atoi
.global main

main:

	ldr r3, =return   	/*stores link register*/
	str lr, [r3] 
	
	cmp r0, #2		/*breaks out of program if argc != 2*/
	bne err_noarg  

	ldr r0, =input
	ldr r2, [r1, #4] 	/*loads argv[1] into r2*/ 	
	str r2, [r0] /*stores argv[1] into input label for future reference*/
	push {r2}
	#str r2, [sp, #-4]!
split:

	ldr r0, [r0] 		/*strtok(string, delimitors)*/
	ldr r1, =delimitor
	bl strtok 		/*stores pointer to token in r0*/    
	bl atoi 		/*converts string token to int */

	mov r10, #0

/*push operands onto the stack*/
operands:
	mov r1, r0
	ldr r0, =printnum
	bl printf

	mov r0, #0	
	ldr r1, =delimitor
	bl strtok 		/*stores pointer to token in r0*/    
	
	mov r1, r0 		/*breaks if token pointer is a NULL pointer*/	
	cmp r0, #0
	beq split2

	mov r0, r1
	bl atoi 		/* converts string token to int */

	add r10, r10, #1	/*increments scratch register that holds the token count */
	cmp r10, #3		/*breaks to error if gt 3 */
	bgt err_opgt3
	b operands

split2:

	pop {r0}
	#ldr r0, [r0] 		/*strtok(string, delimitors)*/
	ldr r1, =operator
	bl strtok 		/*stores pointer to token in r0*/    

	mov r10, #0

/*move operators to a string*/
operators:
	mov r1, r0
	ldr r0, =printops
	bl printf

	mov r0, #0	
	ldr r1, =operator
	bl strtok 		/*stores pointer to token in r0*/    
	
	mov r1, r0 		/*breaks if token pointer is a NULL pointer*/	
	cmp r0, #0
	beq end

	add r10, r10, #1	/*increments scratch register that holds the token count */
	cmp r10, #2		/*breaks to error if gt 2 */
	bgt err_opgt3
	b operators

end:
	ldr lr, =return
	ldr lr, [lr]
	bx lr

/*------------Errors-----------*/
err_noarg:

	ldr r0, =printerr
	ldr r1, =noarg
	bl printf

	b end

err_noop:

	ldr r0, =printerr
	ldr r1, =noop
	bl printf

	b end

err_opgt3:

	ldr r0, =printerr
	ldr r1, =opgt3
	bl printf

	b end
