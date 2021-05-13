
.data
.balign 4
operators: .asciz "+-o*/o()o^"

.balign 4
prefix: .space 100

.balign 4
spa: .asciz " "

.balign 4
infix: .space 100

.balign 4
operations: .asciz "+-*/^"

.balign 4
delimitor: .asciz " "

.balign 4
printnum: .asciz "%d\n"

.balign 4
printerr: .asciz "%s\n"

.balign 4
onearg: .asciz "Error: Enter one argument"

.balign 4
divzero: .asciz "Error: Divide by zero"

.balign 4
return: .word 0

.balign 4
result: .space 100

.balign 4
fixup: .space 100

.global main
.global printf
.global strtok
.global atoi

//r0 contains address of infix expression
//r1 contains length of stack
//r2 contains address of prefix
//r3 contains current character in infix expression
//r4 contains address of operators
//r5 contains precedence of infix in operators
//r7 contains bottom element of stack


//TEMPORARY REGISTERS
//r6 contains current character in operator string


main:

    mov r3, r0		/*store argc in r3*/ 
    ldr r0, [r1, #4]	/*store link register*/
    ldr r1, =return
    str lr, [r1]
    cmp r3, #2		/*error message if argc != 2*/
    bne err_onearg
    ldr r2, =infix
    ldr r3, =spa
    ldrb r3, [r3]

Parse:
    ldrb r7, [r0]
    cmp r7, #0 //check if reached end of input
    beq Converter //if so go to end
    ldr r1, =operations //load the address of  operations string in r1

Operator:
    ldrb r7, [r1]
    cmp r7, #0 //check if reached end of operation string
    beq Storage //means the current character in output isn't an operator
    ldrb r5, [r1] //else load value of r1 in r5, the current operator
    ldrb r6, [r0] //load current value in input string to r6
    cmp r5, r6 //compare the two values
    beq Op //if equal go to loop3
    add r1, r1, #1 //if not increment address of r1
    b Operator //start next iteration of loop2

Op:
    strb r3, [r2] //since current character is an operator, store space first
    add r2, r2, #1 //increment address of r2 by one to get to next slot in array
    b Storage //on output string. Then go to loop4

Storage:
    strb r6, [r2] //store the current character, stored in r6, in r2
    add r0, r0, #1 //increment address of r0 by 1 to get to next character
    add r2, r2, #1 //increment address of r2 by one to get to next slot in array
    b Parse //start next iteration of loop

Converter:
    ldr r0, =infix
    mov r1, #0 //length of stack
    ldr r2, =prefix

InfixParse:
    ldrb r3, [r0] //contains current character in infix expression
    cmp r3, #0
    beq PopOff
    ldr r4, =operators
    mov r5, #0 

InOperator:
    ldrb r6, [r4]
    cmp r6, #0 //check if end of operators string
    beq NotInOperator
    cmp r6, r3
    beq IsOperator
    add r4, r4, #1
    add r5, r5, #1
    b InOperator

NotInOperator:
    strb r3, [r2]
    add r2, r2, #1
    add r0, r0, #1
    b InfixParse

IsOperator:
    cmp r3, #40
    beq IsLeftParen
    cmp r3, #41
    beq IsRightParen
    b OtherOperator

IsLeftParen:
    push {r3}
    add r1, r1, #1
    add r0, r0, #1
    b InfixParse

IsRightParen:
    cmp r1, #0
    popne {r7}
    sub r6, r7, #40
    mul r8, r6, r1
    cmp r1, #0
    pushne {r7}
    cmp r8, #0
    beq EndOfParen
    ldrb r8, [sp], #4
    strb r8, [r2]
    add r2, r2, #1
    sub r1, r1, #1
    b IsRightParen

EndOfParen:
    pop {r6}
    sub r1, r1, #1
    add r0, r0, #1
    b InfixParse

OtherOperator:
    cmp r1, #0
    popne {r7}
    sub r6, r7, #40
    mul r8, r6, r1
    cmp r1, #0
    pushne {r7}
    mov r9, r8
    mov r6, #0
    ldr r4, =operators

PrecedenceCheck:
    ldrb r8, [r4]
    cmp r8, #0
    beq Popping
    cmp r8, r7
    beq Popping
    add r6, r6, #1
    add r4, r4, #1
    b PrecedenceCheck

Popping:
    cmp r6, #9
    moveq r6, #6
    cmp r8, #0
    moveq r6, #12
    sub r6, r5, r6
    cmp r6, #1
    bgt Pushing
    cmp r9, #0
    beq Pushing
    ldrb r6, [sp], #4
    strb r6, [r2]
    add r2, r2, #1
    sub r1, r1, #1
    b OtherOperator

Pushing:
    push {r3}
    add r1, r1, #1
    cmp r1, #1
    add r0, r0, #1
    b InfixParse

PopOff:
    cmp r1, #0 
    beq terminate
    ldrb r6, [sp], #4
    strb r6, [r2]
    add r2, r2, #1
    sub r1, r1, #1
    b PopOff

terminate:
   ldr r0, =prefix
   ldr r5, =result
   mov r7, #0

CheckEnd:
    ldrb r4, [r0]
    cmp r4, #0 //check if reached end of string
    beq Edit //if so branch to end
    ldr r1, =operators //parse operator

OperatorMatch:
    ldrb r3, [r1] //load current character in operators to r3
    cmp r3, #0
    beq NoMatch //branch out if no match found
    ldrb r2, [r0] //load character onto r2
    cmp r2, r3 //if match found branch cout
    beq MatchFound
    add r1, r1, #1 //increment address of operator string
    b OperatorMatch //loop back

NoMatch:
    ldrb r2, [r0] //get current character of prefix expression
    strb r2, [r5] //store it in current position in result array
    add r5, r5, #1 //increment array
    add r0, r0, #1 //increment address of postfix expression
    add r7, r7, #1
    b CheckEnd //loop back to CheckEnd

MatchFound:
    add r7, r7, #2
    sub r0, r0, #1 //get previous character in postfix expression
    ldrb r2, [r0]
    cmp r2, #32 //check if previous character is space
    add r0, r0, #1
    bne SpaceBefore //branch here
    b SpaceAfter //else branch here

SpaceBefore:
    ldr r3, =spa //load space
    ldrb r3, [r3]
    strb r3, [r5] //add space to array
    add r5, r5, #1 //increment address of array
    ldrb r2, [r0] //load current character in postfix
    strb r2, [r5] //store it in r5
    add r5, r5, #1 //increment address of array
    add r0, r0, #1 //increment address of postfix
    b CheckEnd //loop back to CheckEnd

SpaceAfter:
    ldrb r2, [r0] //load current character of postfix
    strb r2, [r5] //store it onto the array
    add r5, r5, #1 //increment address of array
    add r0, r0, #1 //increment address of postfix string

    ldr r3, =spa
    ldrb r3, [r3]
    strb r3, [r5] //add space
    add r5, r5, #1
    b CheckEnd

Edit:
   ldr r0, =result
   ldr r5, =fixup
   mov r8, #0

Fix:
   ldrb r1, [r0]
   cmp r1, #0
   beq evaluate
   ldr r2, =operations
   add r8, r8, #1

CheckIn:
   ldrb r3, [r2]
   cmp r3, #0
   beq NotEqual
   cmp r1, r3
   beq Equal
   add r2, r2, #1
   b CheckIn

NotEqual:
   strb r1, [r5]
   add r5, r5, #1
   add r0, r0, #1
   b Fix

Equal:
   cmp r8, r7
   beq NotEqual
   add r0, r0, #1
   ldrb r6, [r0]
   sub r0, r0, #1
   cmp r6, #32
   beq NotEqual
   strb r1, [r5]
   add r5, r5, #1
   ldr r9, =spa
   ldrb r9, [r9]
   strb r9, [r5]
   add r5, r5, #1
   add r0, r0, #1
   b Fix

evaluate:

   ldr r0, =fixup
   ldr r1, =delimitor
   bl strtok
   mov r1, r0
   bl atoi
   push {r0}    	

evalloop:

   mov r0, #0
   ldr r1, =delimitor
   bl strtok

   mov r1, r0
   cmp r0, #0
   beq answer

   ldrb r0, [r0] 	/*checks for '+'*/
   cmp r0, #43
   beq add 

   cmp r0, #45  	/*checks for '-'*/
   beq subtract

   cmp r0, #42 		/*checks for '*'*/ 
   beq multiply

   cmp r0, #47 		/*checks for '/'*/
   beq divide

   cmp r0, #94 		/*checks for '^'*/
   beq power

   mov r0, r1
   bl atoi
   push {r0}

   b evalloop 

add:

   pop {r2,r3}
   add r1, r2, r3
   push {r1}

   b evalloop

subtract:

   pop {r2,r3}
   sub r1, r3, r2
   push {r1}

   b evalloop

multiply:

   pop {r2,r3}
   mul r1, r2, r3
   push {r1}

   b evalloop

divide:

  pop {r2,r3}
  cmp r2, #0
  beq err_divzero
  mov r1, #0

divloop:

  sub r3, r3, r2
  add r1, r1, #1
  cmp r3, #0
  bge divloop
  sub r1, r1, #1
  push {r1} 

  b evalloop 

power:

   pop {r2, r3} 
   cmp r2, #0
   beq powzero 
   mov r4, r3

powloop:

   mul r1, r3, r4
   mov r3, r1
   sub r2, r2, #1
   cmp r2, #1   
   bgt powloop
   push {r1}

   b evalloop

powzero:

   mov r1, #1
   push {r1}

   b evalloop

answer:

    pop {r1}
    ldr r0, =printnum
    bl printf

end:

    ldr lr, =return
    ldr lr, [lr]
    bx lr

/*------------Errors-----------*/
err_divzero:

    ldr r0, =printerr
    ldr r1, =divzero
    bl printf

    b end

err_onearg:

    ldr r0, =printerr
    ldr r1, =onearg
    bl printf

    b end 
