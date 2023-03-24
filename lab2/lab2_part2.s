/* Program that counts consecutive 1's */

          .text                   // executable code follows
          .global _start                  
_start:                             
          MOV     R5, #0
		  
		  MOV     R4, #TEST_NUM   // load the data word ...
MAIN:     LDR     R1, [R4]        // into R1
		  ADD 	  R4, #4
		  CMP 	  R1, #0
		  BEQ	  END 	  
		  BL	  ONES
		  CMP	  R5, R0
		  MOVLT   R5, R0
		  B 	  MAIN
		  
END:      B       END             
	  
ONES:     MOV     R0, #0          // R0 will hold the result
LOOP:     CMP     R1, #0          // loop until the data contains no more 1's
          BEQ 	  END2             
          LSR     R2, R1, #1      // perform SHIFT, followed by AND
          AND     R1, R1, R2      
          ADD     R0, #1          // count the string length so far
          B       LOOP
END2: 	  MOV 	  PC, LR

TEST_NUM: .word   0x103fe00f	  // 9
		  .word	  0x30885a2d	  // 2
		  .word	  0x09e36901	  // 4
		  .word   0x1653e43f	  // 6
		  .word   0x000095e8	  // 4 
		  .word   0x127a3784	  // 4
		  .word   0xee3ae31c	  // 3
  		  .word   0xee729ee4	  // 4
		  .word   0x05c52883	  // 3
		  .word   0x041dc47b	  // 4
		  .word   0xffffffff	  // 32
          .word   0x00000000
		  
          .end                           
