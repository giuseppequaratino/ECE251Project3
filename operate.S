.data
.balign 4
        enterFirst:  .asciz "Enter the first number: "
.balign 4
        enterSecond: .asciz "Enter the second number: "
.balign 4
        inputFormat: .asciz "%f"
.balign 4
        addition:      .asciz "The result of adding is: %f\n"
.balign 4
        subtraction:      .asciz "The result of subtracting is: %f\n"
.balign 4
        multiply:      .asciz "The result of multiplying is: %f\n"
.balign 4
        division:      .asciz "The result of diviving is: %f\n"

.text
.global main
.global printf
.global scanf

main:
        PUSH {R0, LR}
        LDR R0, =enterFirst
        BL printf

        SUB SP, SP, #8
        LDR R0, =inputFormat
        MOV R1, SP
        BL scanf
        VLDR S1, [SP]
        VCVT.F64.F32 D1, S1

        LDR R0, =enterSecond
        BL printf

        SUB SP, SP, #8
        LDR R0, =inputFormat
        MOV R1, SP
        BL scanf
        VLDR S2, [SP]
        VCVT.F64.F32 D2, S2

	VADD.F64 D0, D1, D2
        VMOV R2, R3, D0
        LDR R0, =addition
        BL printf

        VSUB.F64 D0, D1, D2
        VMOV R2, R3, D0
        LDR R0, =subtraction
        BL printf

        VMUL.F64 D0, D1, D2
        VMOV R2, R3, D0
        LDR R0, =multiply
        BL printf

        VDIV.F64 D0, D1, D2
        VMOV R2, R3, D0
        LDR R0, =division
        BL printf

        ADD SP, SP, #16
        POP {R0, LR}
        BX LR
