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
printformat: .asciz "%s\n"

.balign 4
printnum: .asciz "%d\n"

.balign 4
printerr: .asciz "%s\n"

.balign 4
opgt3: .asciz "Error: Number of arithmetic operators is greater than 3"

.balign 4
noop: .asciz "Error: No operators entered"

.balign 4
noarg: .asciz "Error: Enter one argument"

.balign 4
divzero: .aciz "Error: Divide by zero"

.balign 4
return: .word 0

.balign 4
result: .space 100

.global main
.global printf
.global strtok
.global atoi
.global strtof
.global pow

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
    ldr r0, [r1, #4]
    ldr r1, =return
    str lr, [r1]
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
    beq final
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

final:
    cmp r1, #0
    beq terminate
    ldrb r6, [sp], #4
    strb r6, [r2]
    add r2, r2, #1
    sub r1, r1, #1
    b final

terminate:
   ldr r0, =prefix
   ldr r1, =result

last:
   ldrb r2, [r0]
   cmp r2, #0
   beq evaluate 
   ldr r3, =operations

ultimate:
   ldrb r4, [r3]
   cmp r4, #0
   beq finisher
   cmp r2, r4
   beq conclusion
   add r3, r3, #1
   b ultimate

conclusion:
   sub r0, r0, #1
   ldrb r5, [r0]
   add r0, r0, #1
   cmp r5, #32
   beq forrelasies
   ldr r5, =spa
   ldrb r5, [r5]
   strb r5, [r1]
   add r1, r1, #1
   strb r2, [r1]
   add r1, r1, #1
   add r0, r0, #1
   b last

forrelasies:
   strb r2, [r1]
   add r1, r1, #1
   ldr r5, =spa
   ldrb r5, [r5]
   strb r5, [r1]
   add r1, r1, #1
   add r0, r0, #1
   b last

finisher:
   strb r2, [r1]
   add r1, r1, #1
   add r0, r0, #1
   b last

evaluate:
   
   ldr r0, =result /*remove when done*/
   bl printf

   ldr r0, =result
   ldr r1, =delimitor
   bl strtok
   mov r1, r0
   bl atoi
   push {r0}    	/*this line disallows -x+5*/

evalloop:
   
   mov r0, #0
   ldr r1, =delimitor
   bl strtok

   mov r1, r0
   cmp r0, #0
   beq end

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
   mov r4, r1
   ldr r0, =printnum
   bl printf
   push {r4}

   b evalloop

subtract:

   pop {r2,r3}
   sub r1, r3, r2
   mov r4, r1
   ldr r0, =printnum
   bl printf
   push {r4}
  
   b evalloop

multiply:
  
   pop {r2,r3}
   mul r1, r2, r3
   mov r4, r1
   ldr r0, =printnum
   bl printf
   push {r4}
   
   b evalloop

divide:

  pop {r2,r3}
  cmp r2, #0
  beq err_divzero
  mov r4, #0

divloop:

  sub r3, r3, r2
  add r4, r4, #1
  cmp r0, #0
  bge divloop
  
  mov r1, r4
  ldr r0, =printnum
  push {r4}
  
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
   ldr r0, =printnum
   bl printf

   b evalloop

powzero:

   mov r1, #1
   push {r1}
   ldr r0, =printnum
   bl printf
   
   b evalloop

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
                  
