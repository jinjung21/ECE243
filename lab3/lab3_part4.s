.global _start

.equ KEY_BASE, 0xFF200050
.equ HEX_BASE, 0xFF200020
.equ EDGE_BASE, 0xFF20005C
.equ TIMER_BASE, 0xFFFEC600


_start:
	MOV R7, #0 
    LDR R4, =KEY_BASE // R4 = KEY address
    LDR R5, =HEX_BASE // R5 = HEX address
    MOV R6, #BIT_CODES
    LDR R8, =EDGE_BASE
    MOV R10, #0b1111
    LDR R11, =TIMER_BASE
    LDR R12, =6000 
    
	
MAIN:
	MOV R0, R7
	BL DIVIDE
    PUSH {R0}
    MOV R0, R2 
    BL DIVIDE
    PUSH {R0} 
    MOV R0, R2
    BL DIVIDE
    MOV R3, R2 // Now R3 has thousands digit
    MOV R2, R0 // Now R2 has hundreds digit
	POP {R1} // Now R1 has tens digit
    POP {R0} // Now R0 has ones digit
	BL DISPLAY    
    BL DELAY
    ADD R7, #1
    CMP R7, R12
    MOVEQ R7, #0 
    LDR R9, [R8]
    AND R9, R9, R10
    STR R9, [R8]
    CMP R9, #0
    BLNE POLL
    B MAIN


POLL:
	LDR R1, [R8] 
    AND R1, R1, R10
    STR R1, [R8] // Reset the edge captures
    CMP R1, #0
    BNE POLL_END
    B POLL 
POLL_END: 
	MOV PC, LR


/* 0.01 seconds delay */
DELAY:
	LDR R1, =2000000 
    STR R1, [R11]
    MOV R1, #1 
    STR R1, [R11, #8] // Now the E bit is set to 1
    MOV R3, #1
SUB_LOOP:
	LDR R2, [R11, #12] 
    CMP R2, #1 
    STREQ R3, [R11, #12] 
    BEQ LOOP_END
    BNE SUB_LOOP
LOOP_END:
	MOV PC, LR


DIVIDE:     MOV    R2, #0
CONT:       CMP    R0, #10 	
            BLT    DIV_END
            SUB    R0, #10	 
            ADD    R2, #1
            B      CONT
DIV_END:    MOV    PC, LR


DISPLAY:
	LDRB R3, [R6, R3]
    LSL R3, #24
	LDRB R2, [R6, R2]
    LSL R2, #16
    LDRB R1, [R6, R1]
    LSL R1, #8
    LDRB R0, [R6, R0]
    
    ORR R3, R2
    ORR R3, R1
    ORR R3, R0

    STR R3, [R5]
	MOV PC, LR
    

BIT_CODES: .byte 0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
    .byte 0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111


