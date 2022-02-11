# Name: Adam Pena
# Date: 11/30/2021
# Description: Include file for snake subroutines like drawing border, writing prompts, and flashing for effect

.eqv WHITE 0x00ffffff
.eqv ORANGE 0x00ff9900
.eqv GREEN 0x0000c60d

# Macro to sleep
.macro load
   li $a0, 15
   li $v0, 32
   syscall
.end_macro

# Collection of macros for writing with bitmap pointer and moving bitmap pointer w/o writing
.macro upRow
   addi $t0, $t0, -128
   sw $t1, 0($t0)
.end_macro

.macro downRow
   addi $t0, $t0, 128
   sw $t1, 0($t0)
.end_macro

.macro rightColumn
   addi $t0, $t0, 4
   sw $t1, 0($t0)
.end_macro

.macro leftColumn
   addi $t0, $t0, -4
   sw $t1, 0($t0)
.end_macro

.macro diagUpR
   addi $t0, $t0, -124
   sw $t1, 0($t0)
.end_macro

.macro diagUpL
   addi $t0, $t0, -132
   sw $t1, 0($t0)
.end_macro

.macro diagDownR
   addi $t0, $t0, 132
   sw $t1, 0($t0)
.end_macro

.macro diagDownL
   addi $t0, $t0, 124
   sw $t1, 0($t0)
.end_macro

.macro upRowC
   addi $t0, $t0, -128
.end_macro

.macro downRowC
   addi $t0, $t0, 128
.end_macro

.macro rightColumnC
   addi $t0, $t0, 4
.end_macro

.macro leftColumnC
   addi $t0, $t0, -4
.end_macro

.macro diagUpRC
   addi $t0, $t0, -124
.end_macro

.macro diagUpLC
   addi $t0, $t0, -132
.end_macro

.macro diagDownRC
   addi $t0, $t0, 132
.end_macro

.macro diagDownLC
   addi $t0, $t0, 124
.end_macro

.macro lilPause
   li $a0, 15
   li $v0, 32
   syscall
.end_macro

# Subroutine to draw orange and white border
drawBorder:
   addi $sp, $sp, -4
   sw $ra, 0($sp)

   li $t1, 0x10040000	# bitmap base
   li $t0, 0				# initialize counter
	topRow:
	   beq $t0, 31, endTopRow
	
	   jal drawDot
	   
	   lilPause
		
           addi $t1, $t1, 4
	   addi $t0, $t0, 1
	   b topRow
	endTopRow:

	li $t0, 0
		
	rightColumn:
	   beq $t0, 31, endRightColumn
	
	   jal drawDot
	   
	   lilPause
		
           addi $t1, $t1, 128
	   addi $t0, $t0, 1
	   b rightColumn
	endRightColumn:
	
	li $t0, 0
	
	bottomRow:
	   beq $t0, 31, endBottomRow
	
	   jal drawDot
	   
	   
	   lilPause
		
           addi $t1, $t1, -4
	   addi $t0, $t0, 1
	   b bottomRow
	endBottomRow:
	
	li $t0, 0
	
	leftColumn:
	   beq $t0, 31, endLeftColumn
	
	   jal drawDot
	   
	   lilPause
		
           addi $t1, $t1, -128
	   addi $t0, $t0, 1
	   b leftColumn
	endLeftColumn:
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
	drawDot:
	   beqz $t4, orangeDot
	   bnez $t4, whiteDot
	   
	   orangeDot:
	      li $t3, ORANGE
	      sw $t3, 0($t1)
	      li $t4, 1
	   
	      jr $ra
	   
	   whiteDot:
	      li $t3, WHITE
	      sw $t3, 0($t1)
	      li $t4, 0
	   
	      jr $ra

# Subroutine to flash the border some color if the players wins/loses
     
   flashBorder:			#a0 is color to flash border
      addi $sp, $sp, -4
      sw $ra, 0($sp)
      
      move $t1, $a0
       
      li $t0, 0x10040000 
      li $t4, 0
      
      topBord:
         beq $t4, 16, endTopBord
         
         sw $t1, 0($t0)
         addi $t0, $t0, 8
         addi $t4, $t4, 1
         b topBord
      
      endTopBord:
   	
      li $t4, 0
      addi $t0, $t0, 124
   	
      rightBord:
         beq $t4, 16, endRightBord
         
         sw $t1, 0($t0)
         addi $t0, $t0, 256
         addi $t4, $t4, 1
         b rightBord
      endRightBord:
      
      li $t4, 0
      addi $t0, $t0, -264
      
      bottomBord:
         beq $t4, 15, endBottomBord
         
         sw $t1, 0($t0)
         addi $t0, $t0, -8
         addi $t4, $t4, 1
         b bottomBord
      endBottomBord:
      
      li $t4, 0
      addi $t0, $t0, -124
   
      leftBord:
         beq $t4, 16, endLeftBord
         
         sw $t1, 0($t0)
         addi $t0, $t0, -256
         addi $t4, $t4, 1
         b leftBord
      
      endLeftBord:
    endFlashBorder:
    
      lw $ra, 0($sp)
      addi $sp, $sp, 4
      jr $ra
 
      
# Subroutines to write "game over" and "you win!" prompts on screen     
writeGameOver:
   li $t0, 0x10040000
   li $t1, 0x00ff0000
   
   # Game
      G:
         sw $t1, 676($t0)
         load
         sw $t1, 544($t0)
         load
         sw $t1, 540($t0)
         load
         sw $t1, 536($t0)
         load
         sw $t1, 660($t0)
         load
         sw $t1, 788($t0)
         load
         sw $t1, 916($t0)
         load
         sw $t1, 1044($t0)
         load
         sw $t1, 1172($t0)
         load
         sw $t1, 1300($t0)
         load
         sw $t1, 1428($t0)
         load
         sw $t1, 1556($t0)
         load
         sw $t1, 1688($t0)
         load
         sw $t1, 1692($t0)
         load
         sw $t1, 1696($t0)
         load
         sw $t1, 1696($t0)
         load
         sw $t1, 1572($t0)
         load
         sw $t1, 1572($t0)
         load
         sw $t1, 1444($t0)
         load
         sw $t1, 1316($t0)
         load
         sw $t1, 1312($t0)
         load
      endG:
      li $t0, 0x10040000
      addi $t0, $t0, 1708

      A:
      sw $t1, 0($t0)
         upRow
         load
         upRow
         load
         upRow
         load
         upRow
         load
         upRow
         load
         rightColumn
         load
         leftColumnC
         upRow
         load
         upRow
         load
         upRow
         load
         diagUpR
         load
         rightColumn
         load
         rightColumn
         load
         diagDownR
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         addi $t0, $t0, -12
         addi $t0, $t0, -640
         rightColumn
         load
         rightColumn
         load
      endA:
         rightColumnC
      M:
         
         downRowC
         downRowC
         downRowC
         downRowC
         downRowC

         rightColumnC
         rightColumn
         load
         upRow
         load
         upRow
         load
         upRow
         load
         upRow
         load
         upRow
         load
         upRow
         load
         upRow
         load
         upRow
         load
         upRow
         load
         diagDownR
         load
         diagDownR
         load
         diagUpR
         load
         diagUpR
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow 
         load
      endM:
      
         upRowC
         upRowC
         upRowC
         upRowC
         upRowC
         upRowC
         upRowC
         upRowC
         upRowC
         rightColumnC
      
      E:
         rightColumn
         load
         rightColumn
         load
         rightColumn
         load
         rightColumn
         load
         rightColumn
         load
         leftColumnC
         leftColumnC
         leftColumnC
         leftColumnC
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         rightColumn
         load
         rightColumn
         load
         rightColumn
         load
         rightColumn
         load
         leftColumnC
         leftColumnC
         leftColumnC
         leftColumnC
         upRowC
         upRowC
         upRowC
         upRowC
         upRowC
         rightColumn
         load
         rightColumn
         load
      endE:
      
      li $t0, 0x10040000
      rightColumnC
      rightColumnC
      rightColumnC
      rightColumnC
      rightColumnC
      downRowC
      downRowC
      downRowC
      downRowC
      downRowC
      downRowC
      downRowC
      downRowC
      downRowC
      downRowC
      downRowC
      downRowC
      downRowC
      downRowC
      downRowC
      downRowC
      downRowC
      
      #Over
      O:
         downRow
         load
         diagUpR
         load
         rightColumn
         load
         rightColumn
         load
         diagDownR
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         diagDownL
         load
         leftColumn
         load
         leftColumn
         load
         diagUpL
         load
         upRow
         load
         upRow
         load
         upRow
         load
         upRow
         load
         upRow
         load
         upRow
         load
      endO:
      
         rightColumnC
         rightColumnC
         rightColumnC
         rightColumnC
         rightColumnC
         rightColumnC
         upRowC
      
      V:
         upRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         diagDownR
         load
         diagDownR
         load
         diagUpR
         load
         diagUpR
         load
         upRow
         load
         upRow
         load
         upRow
         load
         upRow
         load
         upRow
         load
         upRow
         load
         upRow
         load
        
      endV:
         rightColumnC
      E2:
         rightColumn
         load
         rightColumn
         load
         rightColumn
         load
         rightColumn
         load
         rightColumn
         load
         leftColumnC
         leftColumnC
         leftColumnC
         leftColumnC
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         rightColumn
         load
         rightColumn
         load
         rightColumn
         load
         rightColumn
         load
         leftColumnC
         leftColumnC
         leftColumnC
         leftColumnC
         upRowC
         load
         upRowC
         load
         upRowC
         load
         upRowC
         load
         upRowC
         load
         rightColumn
         load
         rightColumn
         load
         
      endE2:
      
         rightColumnC
         rightColumnC
         rightColumnC
         rightColumnC
         upRowC
         upRowC
         upRowC

      R:
         upRow
         load
         rightColumn
         load
         rightColumn
         load
         rightColumn
         load
         diagDownR
         load
         downRow
         load
         downRow
         load
         diagDownL
         load
         leftColumn
         load
         leftColumn
         load
         leftColumn
         load
         upRow
         load
         upRow
         load
         upRow
         load
         downRowC
         downRowC
         downRowC
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
  	 upRowC
  	 upRowC
  	 upRowC
  	 upRowC
  	 rightColumn
         load
  	 rightColumn
         load
  	 downRow
         load
  	 rightColumn
         load
  	 downRow
         load
  	 rightColumn
         load
  	 downRow
         load
  	 downRow
      endR:
      
      jr  $ra
      
writeYouWin:

   li $t0, 0x10040000
   li $t1, GREEN
   
   rightColumnC
   rightColumnC
   rightColumnC
   rightColumnC

   downRowC
   downRowC
   downRowC
   downRowC

   Y:
      rightColumn
      load
      downRow
      load
      downRow
      load
      downRow
      load
      diagDownR
      load
      diagDownR
      load
      downRow
      load
      downRow
      load
      downRow
      load
      downRow
      load
      upRowC
      upRowC
      upRowC
      upRowC
      diagUpR
      load
      diagUpR
      load
      upRow
      load
      upRow
      load
      upRow
      
   endY:
   
   rightColumnC
   rightColumnC
   rightColumnC
   rightColumnC
   
   O2:
         load
         downRow
         load
         diagUpR
         load
         rightColumn
         load
         rightColumn
         load
         diagDownR
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         downRow
         load
         diagDownL
         load
         leftColumn
         load
         leftColumn
         load
         diagUpL
         load
         upRow
         load
         upRow
         load
         upRow
         load
         upRow
         load
         upRow
         load
         upRow
   endO2:
   
   rightColumnC
   rightColumnC
   rightColumnC
   rightColumnC
   rightColumnC
   rightColumnC
   rightColumnC
   upRowC
   upRowC
   
   U:
      load
      rightColumn
      load
      downRow
      load
      downRow
      load
      downRow
      load
      downRow
      load
      downRow
      load
      downRow
      load
      downRow
      load
      downRow
      load
      diagDownR
      load
      rightColumn
      load
      rightColumn
      load
      diagUpR
      load
      upRow
      load
      upRow
      load
      upRow
      load
      upRow
      load
      upRow
      load
      upRow
      load
      upRow
      load
      upRow
   endU2:
   
   downRowC
   downRowC
   downRowC
   downRowC
   downRowC
   downRowC
   downRowC
   downRowC
   downRowC
   downRowC
   downRowC
   downRowC
   downRowC
   leftColumnC
   leftColumnC
   leftColumnC
   leftColumnC
   leftColumnC
   leftColumnC
   leftColumnC
   leftColumnC
   leftColumnC
   leftColumnC
   leftColumnC
   leftColumnC
   leftColumnC
   leftColumnC
   leftColumnC
   leftColumnC
   leftColumnC
   leftColumnC
   leftColumnC
   
   W:
      load
      leftColumn
      load
      downRow
      load
      downRow
      load
      downRow
      load
      downRow
      load
      downRow
      load
      downRow
      load
      downRow
      load
      downRow
      load
      downRow
      load
      diagUpR
      load
      diagUpR
      load
      diagDownR
      load
      diagDownR
      load
      upRow
      load
      upRow
      load
      upRow
      load
      upRow
      load
      upRow
      load
      upRow
      load
      upRow
      load
      upRow
      load
      upRow
   endW:
   
   rightColumnC
   
   I:
      rightColumn
      load
      rightColumn
      load
      rightColumn
      load
      rightColumn
      load
      rightColumn
      leftColumnC
      leftColumnC
      load
      downRow
      load
      downRow
      load
      downRow
      load
      downRow
      load
      downRow
      load
      downRow
      load
      downRow
      load
      downRow
      load
      downRow
      leftColumnC
      load
      leftColumn
      load
      rightColumn
      load
      rightColumn
      load
      rightColumn
      load
      rightColumn
     
   endI:
   
   rightColumnC
   
   N:
      load
      rightColumn
      load
      upRow
      load
      upRow
      load
      upRow
      load
      upRow
      load
      upRow
      load
      upRow
      load
      upRow
      load
      upRow
      load
      upRow
      load
      diagDownR
      load
      diagDownR
      load
      downRow
      load
      downRow
      load
      downRow
      load
      downRow
      load
      downRow
      load
      diagDownR
      load
      diagDownR
      load
      upRow
      load
      upRow
      load
      upRow
      load
      upRow
      load
      upRow
      load
      upRow
      load
      upRow
      load
      upRow
      load
      upRow
   endN:
   
   rightColumnC
   rightColumnC

   exclam:
      load
      rightColumn
      load
      rightColumn
      load
      downRow
      load
      leftColumn
      load
      downRow
      load
      rightColumn
      load
      downRow
      load
      leftColumn
      load
      downRow
      load
      rightColumn
      load
      downRow
      load
      leftColumn
      load
      downRow
      load
      rightColumn
      load
      downRowC
      leftColumnC
      downRow
      load
      rightColumn
      load
      downRow
      load
      leftColumn
   endExclam:
   
   jr $ra
      

		
