.global _start

.equ KEY_BASE, 0xFF200050
.equ HEX_BASE, 0xFF200020
.equ EDGE_BASE, 0xFF20005C

_start:
	MOV R7, #0 
    LDR R4, =KEY_BASE // R4 = KEY address
    LDR R5, =HEX_BASE // R5 = HEX address
    MOV R6, #BIT_CODES
    LDR R8, =EDGE_BASE
    MOV R10, #0b1111
    
	
MAIN:
	MOV R0, R7
	BL DIVIDE
	BL DISPLAY    
    BL DELAY
    ADD R7, #1
    CMP R7, #100
    MOVEQ R7, #0 
    LDR R9, [R8] 
    AND R9, R10
    STR R9, [R8] 
    CMP R9, #0
    BLNE POLL
    B MAIN


POLL:
	LDR R1, [R8] 
    AND R1, R10
    STR R1, [R8] // Reset edge captures
    CMP R1, #0
    BNE POLL_END
    B POLL 
POLL_END: 
	MOV PC, LR


/* 0.25 seconds delay */
DELAY:
	LDR R1, =50000000
SUB_LOOP:s
	SUBS R1, R1, #1
    BNE SUB_LOOP
    MOV PC, LR


DIVIDE:     MOV    R2, #0
CONT:       CMP    R0, #10 	
            BLT    DIV_END
            SUB    R0, #10	 
            ADD    R2, #1
            B      CONT
DIV_END:    MOV    PC, LR
    
	
DISPLAY:
	LDRB R2, [R6, R2]
    LDRB R1, [R6, R0]
    LSL R2, #8
    ORR R2, R2, R1
    STR R2, [R5]
    MOV PC, LR
    

BIT_CODES: .byte 0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
    .byte 0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111


