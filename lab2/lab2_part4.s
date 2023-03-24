/* Program that converts a binary number to decimal */
           .text               
           .global _start
_start:
	      MOV	  R5, #0		      
          MOV	  R6, #0		  
          MOV	  R7, #0		     
                                                                                                                                      
          MOV     R4, #TEST_NUM  
MAIN:  	  LDR     R1, [R4], #4    
          CMP	  R1, #0		  
          BEQ	  DISPLAY		 
          BL	  ONES			 
          CMP	  R5, R0		  
          MOVLT	  R5, R0		  
          BL	  ZEROES		  
          CMP	  R6, R0		 
          MOVLT	  R6, R0		 
          BL	  ALTERNATE      
          CMP	  R7, R0		  
          MOVLT	  R7, R0		  
          B		  MAIN	      

/* Display R5 on HEX1-0, R6 on HEX3-2 and R7 on HEX5-4 */
DISPLAY:    LDR     R8, =0xFF200020 // base address of HEX3-HEX0
            MOV     R0, R5          // display R5 on HEX1-0
            BL      DIVIDE          // ones digit will be in R0; tens
                                    // digit in R1
            MOV     R9, R1          // save the tens digit
            BL      SEG7_CODE     
            MOV     R4, R0          // save bit code 
            MOV     R0, R9          // retrieve the tens digit, get bit code
            BL      SEG7_CODE       
            LSL     R0, #8
            ORR     R4, R0			
            
            MOV		R0, R6
            BL		DIVIDE
            MOV		R9, R1			
            BL		SEG7_CODE	
            MOV		R11, R0			
            MOV		R0, R9			
            BL		SEG7_CODE		
            LSL		R0, #8
            ORR		R11, R0			
            LSL		R11, #16
            ORR		R4, R11		
            
            STR     R4, [R8]        // display the numbers from R6 and R5
            
            LDR     R8, =0xFF200030 // base address of HEX5-HEX4
            MOV		R0, R7
            BL		DIVIDE
            MOV		R9, R1			
            BL		SEG7_CODE
            MOV		R4, R0
            MOV		R0, R9
            BL		SEG7_CODE
            LSL		R0, #8
            ORR		R4, R0
            STR     R4, [R8]        // display the number from R7
            
END:      	B      END
            
/* Subroutine to convert the digits from 0 to 9 to be shown on a HEX display.
 *    Parameters: R0 = the decimal value of the digit to be displayed
 *    Returns: R0 = bit patterm to be written to the HEX display
 */

SEG7_CODE:  MOV     R1, #BIT_CODES  
            ADD     R1, R0         // index into the BIT_CODES "array"
            LDRB    R0, [R1]       // load the bit pattern (to be returned)
            MOV     PC, LR          
            
                                    
/* Returns: quotient in R1, and remainder in R0 */
DIVIDE:     MOV    R1, #0
CONT:       CMP    R0, #10 	 
            BLT    DIV_END
            SUB    R0, #10	  
            ADD    R1, #1
            B      CONT
DIV_END:    MOV    PC, LR

ONES:	  MOV     R0, #0          
          MOV 	  R3, R1		  
LOOP_ONE: CMP     R3, #0         
          BEQ     END2             
          LSR     R2, R3, #1      
          AND     R3, R3, R2      
          ADD     R0, #1          
          B       LOOP_ONE  
END2:	  MOV 	  PC, LR         


ZEROES:   MOV     R0, #0          
          MVN 	  R3, R1		  
LOOP_ZERO:CMP     R3, #0          
          BEQ     END3             
          LSR     R2, R3, #1      
          AND     R3, R3, R2      
          ADD     R0, #1         
          B       LOOP_ZERO   
END3:	  MOV 	  PC, LR     


ALTERNATE:MOV 	  R0, #0
	 	  MOV 	  R3, R1
LOOP_ALT: LDR 	  R2, =0xaaaaaaaa
		  EOR 	  R1, R3, R2
		  PUSH    {LR}
		  BL 	  ONES
		  MOV 	  R8, R0
		  BL 	  ZEROES
		  MOV     R9, R0
		  POP 	  {LR}
		  CMP     R8, R9
		  BLE     LESS
		  MOV 	  R0, R8
		  MOV 	  PC, LR
LESS:     MOV 	  R0, R9
		  MOV 	  PC, LR
    

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment


TEST_NUM: .word   0x103fe00f	  // 0001 0000 0011 1111 1110 0000 0000 1111 : 9, 9
		  .word	  0x5078562d	  // 0101 0000 0111 1000 0101 0110 0010 1101 : 4, 5
		  .word	  0x000095e8	  // 0000 0000 0000 0000 1001 0101 1110 1000 : 4, 16
		  .word   0x0655ee3d	  // 0000 0110 0101 0101 1110 1110 0011 1101 : 4, 5
		  .word   0x09e36901	  // 0000 1001 1110 0011 0110 1001 0000 0001 : 4, 7
		  .word   0x377af784	  // 0011 0111 0111 1010 1111 0111 1000 0100 : 4, 3
		  .word   0xee3ae31c	  // 1110 1110 0011 1010 1110 0011 0001 1100 : 3, 3
  		  .word   0x1f799fe4	  // 0001 1111 0111 1001 1001 1111 1110 0100 : 8, 3
		  .word   0x05c5b88d	  // 0000 0101 1100 0101 1011 1000 1000 1101 : 3, 5
		  .word   0x0f1dc48b	  // 0000 1111 0001 1101 1100 0100 1000 1011 : 4, 4
		  .word   0xffffffff	  // 1111 1111 1111 1111 1111 1111 1111 1111 : 32, 0
          .word   0x0aaaaaa0 	  // 0000 1010 1010 1010 1010 1010 1010 0000 : 1, 4
          .word   0x00000000
          .end
