.global _start

.equ KEY_BASE, 0xFF200050
.equ HEX_BASE, 0xFF200020

_start:
	MOV R0, #0 
    LDR R4, =KEY_BASE // R4 = KEY address
    LDR R5, =HEX_BASE // R5 = HEX address
    MOV R7, #BIT_CODES
    
MAIN:
	LDR R6, [R4] // Check for KEY0
    CMP R6, #1
    BEQ KEY_0
    LDR R6, [R4] // Check for KEY1
    CMP R6, #2
    BEQ KEY_1
    LDR R6, [R4] // Check for KEY2
    CMP R6, #4
    BEQ KEY_2
    LDR R6, [R4] // Check for KEY3
    CMP R6, #8
    BEQ KEY_3
    
    LDRB R8, [R7, R0] 
    STR R8, [R5] 
    
    B MAIN // When none of the keys is pressed
    
KEY_0:
	MOV R0, #0
LOOP_0:
	LDR R1, [R4]
    CMP R1, #1
    BEQ LOOP_0 
    
    LDRB R2, [R7, R0] 
	STR R2, [R5]
    B MAIN

KEY_1:
    ADD R0, #1
    CMP R0, #10 // if r0 is 10 after increment
    MOVEQ R0, #9 // Remain at 9
LOOP_1:
	LDR R1, [R4]
    CMP R1, #2
    BEQ LOOP_1 
	
    LDRB R2, [R7, R0]
	STR R2, [R5]
    B MAIN

KEY_2:
	SUBS R0, #1
    MOVLT R0, #0 // if r0 is a negative number, set R0 to 0
LOOP_2:
	LDR R1, [R4]
    CMP R1, #4
    BEQ LOOP_2 
	
    LDRB R2, [R7, R0] 
	STR R2, [R5]
    B MAIN

KEY_3:
 	LDR R1, [R4] 
    CMP R1, #8
    BEQ KEY_3
    MOV R0, #0
    STR R0, [R5] // Blank the HEX0
LOOP_3:
	LDR R1, [R4] // Check for KEY0
    CMP R1, #1
    BLEQ DISPLAY
    BEQ MAIN
    
    LDR R1, [R4] // Check for KEY1
    CMP R1, #2
    BLEQ DISPLAY
    BEQ MAIN
    
    LDR R1, [R4] // Check for KEY2
    CMP R1, #4
    BLEQ DISPLAY
    BEQ MAIN
    
    LDR R1, [R4] // Check for KEY3
    CMP R1, #8
    BLEQ DISPLAY
    BEQ MAIN

    BNE LOOP_3

DISPLAY:
	LDRB R2, [R7]
    STR R2, [R5]
    MOV PC, LR
   

BIT_CODES: .byte 0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
    .byte 0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111



	