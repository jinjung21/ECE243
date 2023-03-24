/* Program that converts a binary number to decimal */
           
           .text               // executable code follows
           .global _start
_start:
            MOV    R4, #N
            MOV    R5, #Digits  // R5 points to the decimal digits storage location
            LDR    R4, [R4]     // R4 holds N
            MOV    R0, R4       // parameter for DIVIDE goes in R0
            BL     DIVIDE
            STRB   R1, [R5, #3] // Thousandth digit is now in R1
            STRB   R3, [R5, #2] // Hundredth digit is now in R3
            STRB   R6, [R5, #1] // Tens digit is now in R6
            STRB   R0, [R5]     // Ones digit is in R0
END:        B      END

/* Subroutine to perform the integer division R0 / 10.
 * Returns: quotient in R1, and remainder in R0 */
DIVIDE:     MOV    R2, #0
CONT:       CMP    R0, #1000
            BLT    BREAK
            SUB    R0, #1000
            ADD    R2, #1
            B      CONT
BREAK:		MOV    R1, R2     // quotient in R1 (1000's)
			MOV    R2, #0
CONT2:      CMP	   R0, #100
			BLT	   BREAK2
			SUB	   R0, #100
			ADD	   R2, #1
			B  	   CONT2
BREAK2:		MOV    R3, R2     // quotient in R3 (100's)
			MOV    R2, #0
CONT3:      CMP	   R0, #10
			BLT	   DIV_END
			SUB	   R0, #10
			ADD	   R2, #1
			B  	   CONT3	
DIV_END:	MOV    R6, R2
			MOV    PC, LR

N:          .word  9876         // the decimal number to be converted
Digits:     .space 8          // storage space for the decimal digits

            .end
