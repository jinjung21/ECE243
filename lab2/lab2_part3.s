          .text                   
          .global _start
_start:
	      MOV	  R5, #0		   
          MOV	  R6, #0	
          MOV	  R7, #0		     
                                                                                                                                      
          MOV     R4, #TEST_NUM   
MAIN:     LDR     R1, [R4], #4    
          CMP	  R1, #0		  
          BEQ	  END		
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
          
END:      B       END    	


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
			
							 
TEST_NUM: .word   0x0aaaaaaf	 
		  .word	  0x00000000

          .end             
	