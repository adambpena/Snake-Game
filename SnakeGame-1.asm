# Name: Adam Pena
# Date: 11/30/21
# Description: Program that plays snake

# RULES:
#	- Sleep time between moves lasts 500ms to start with
#	- Only one apple is on screen at a time
#	- 10 apples are required to win, number of apples indicated by bar at top of screen
#	- When an apple is collected, the snake becomes 1 unit longer and the sleep time reduces by 30ms (becomes faster)
#	- Running into self or border causes game over
#	- Snake cannot turn backwards on itself
#	- Presses other than W, A, S, or D will be ignored

# Brief macro for pauses
   .macro load
      li $a0, 100
      li $v0, 32
      syscall
   .end_macro
  
# MMIO eqv's
  .eqv THD 0xffff000c  # this is where we write data to...
  .eqv THR 0xffff0008  # This check is the device ready
  
  .eqv KC 0xffff0004   # MMMI  Address that we use to read data
  .eqv KR 0xffff0000   # Is it ok to write?  Key Write Request
  
  .eqv BMD 0x10040000
  
  
# Directions to the tail
  .eqv UP 0x01ffffff	# White colors encoded with different bits at the second MSB, used to draw tail from head
  .eqv LEFT 0x02ffffff
  .eqv DOWN 0x03ffffff
  .eqv RIGHT 0x04ffffff
  
  .eqv W_PRESS 119	# ASCII equivalents for wasd directions
  .eqv A_PRESS 97
  .eqv S_PRESS 115
  .eqv D_PRESS 100
  
  .eqv APPLE 0x00ff0000	# Color of snake apple
  
  .eqv RED 0x00ee0000	# Color used to write game over prompts/effects
  .eqv GREEN 0x0000c60d	# Color used to write winning prompts/effects
  
.macro WinnerFlash # A flashing effect when the player wins, flashes the border green and white
  
   li $a0, 0x00ffffff
   jal flashBorder
   
   li $a0, 50
   li $v0, 32
   syscall
  
   li $a0, GREEN
   jal flashBorder
   
   li $a0, 50
   li $v0, 32
   syscall 

.end_macro

.macro LoserFlash # A flashing effect when the player loses, flashes the border red and white
   li $a0, 0x00ffffff
   jal flashBorder
   
   li $a0, 50
   li $v0, 32
   syscall
  
   li $a0, RED
   jal flashBorder
   
   li $a0, 50
   li $v0, 32
   syscall 

.end_macro
  
.text
   .globl main
main:
   li $s1, KC    	# Make a note, these $t should probably be $s if we are calling other subs
   li $s2, KR    	# Key Ready?
   li $s3, THD   	# Destination
   li $s4, THR   	# Is device ready?
   li $s5, BMD   	# $s5 is our pointer into our bitmap
   li $s6, DOWN 	# Holds colors (w direction pointing to tail encoded)
   li $s7, 3         	#  This will be the length of the snake
   
   jal drawBorder	# Jumps to an include file to draw the orange and white border
   
   addi $s5, $s5, 2108   	# Pointer for bitmap ($s5) always points to the head of the snake
   sw $s6, 0($s5)		# Draws three segments of the snake near center of bitmap
   sw $s6, 128($s5)
   sw $s6, 256($s5)
   
   li $t0, 0x10040000		# Base of bitmap, using to draw progress bar up top
   li $t1, 0x00666666   	# Dark color showing empty progress bar, holds ten apples
   sw $t1, 44($t0)		# Ten empty spaces for the bar loaded onto the bitmap
   load
   sw $t1, 48($t0)
   load
   sw $t1, 52($t0)
   load
   sw $t1, 56($t0)
   load
   sw $t1, 60($t0)
   load
   sw $t1, 64($t0)
   load
   sw $t1, 68($t0)
   load
   sw $t1, 72($t0)
   load
   sw $t1, 76($t0)
   load
   sw $t1, 80($t0)
   load
   
   li $s6, 0x00ffffff
   
   li $t9, 500		# Sleep time, initially
   
   # Setup to handle interrupts.  It sets a bit
     li $t5, 2		 # 2 is the bit that needs to be set in KR to enable interrupts 0x0010
     sb $t5, 0($s2) # Set bit 2 in KR 
   
   loop:
     move $a0, $t9		# Sleep for the length of time assgned to sleep time (at $t9)
     li $v0, 32			# code for a sleep syscall
     syscall
     jal generateApple		# Jump to code to generate an apple
     jal generateProgressBar	# Jump to code to update the progress bar
     beq $s7, 13, winner	# If the player gets 10 apples, they win the game
     jal handleKeyInput		# Check the key input
     b loop			# Continue looping these checks
   
   handleKeyInput:
   	# Code to handle disallowed presses
        sne $t0, $s0, W_PRESS	# If user didnt press W, set
        sne $t1, $s0, A_PRESS	# User didnt press A, set
        and $t0, $t0, $t1	# Not W and not A entered..
        sne $t1, $s0, S_PRESS	# Input != S
        sne $t2, $s0, D_PRESS	# Input != D
        and $t1, $t1, $t2	# Not S and not D entered..
        and $t0, $t0, $t1	# If user didn't enter W, A, S, or D..
        bnez $t0, invalidPress	# Branch to invalidPress
   
   	seq $t0, $s0, W_PRESS   # If W was pressed
        sne $t1, $s6, UP    	# And S wasn't pressed before
        and $t0, $t0, $t1
        bnez $t0, goUp		# Go up
        seq $t0, $s0, W_PRESS	# OTherwise, if W was pressed
        seq $t1, $s6, UP	# And the last color used was up
        and $t0, $t0, $t1	
        bnez $t0, goDown	# Ignore this key press and keep going up (No going backwards)
        			# Same logic for subsequent checks
        
        seq $t0, $s0, A_PRESS	# If A was pressed
        sne $t1, $s6, LEFT	# And D wasn't pressed before
        and $t0, $t0, $t1
        bnez $t0, goLeft	# Then turn left
        seq $t0, $s0, A_PRESS
        seq $t1, $s6, LEFT
        and $t0, $t0, $t1
        bnez $t0, goRight
        
        seq $t0, $s0, S_PRESS	# If S was pressed
        sne $t1, $s6, DOWN     	# And W wasn't pressed before
        and $t0, $t0, $t1
        bnez $t0, goDown	# Then go down
        seq $t0, $s0, S_PRESS
        seq $t1, $s6, DOWN
        and $t0, $t0, $t1
        bnez $t0, goUp
     
        seq $t0, $s0, D_PRESS	# If D was pressed
        sne $t1, $s6, RIGHT    	# And A wasn't pressed before
        and $t0, $t0, $t1
        bnez $t0, goRight	# Then go right
        seq $t0, $s0, D_PRESS
        seq $t1, $s6, RIGHT
        and $t0, $t0, $t1
        bnez $t0, goLeft
        
        j loop			# If the code has reached this point, return to the loop of checks
        
        invalidPress:			# If press was invalid execute the following:
        beqz $t6, handleKeyInput	# If nothing is in $t6, just keep checking key input without moving a 0 to $s0, potentially overwriting a valid press
        move $s0, $t6			# Put the former key press ($t6) in 
        j handleKeyInput		# Move snake according to former key press 
       
       goUp:			# Code executed if it is determined the snake will go up
	  addi $sp, $sp, -4
	  sw $ra, 0($sp)
	  
	  li $t6, W_PRESS	# Use $t6 as a sort of buffer, remembers this key press for next press (in case of invalid press)
          
          # Draws new head
          addi $s5, $s5, -128	# Set the head pointer in the immediate direction the snake head will go
          lw $t0, 0($s5)	# Store the new head data in $s5
          
          seq $t1, $t0, APPLE	# If there is a red dot there
          bnez $t1, growSnakeU	# Then grow the snake according to the logic of the snake traveling up
          
          seq $t1, $t0, $zero	# If there is nothing there
          bnez $t1, snakeMoveU	# Just move the snake and keep the length the same
         
          sne $t1, $t0, $zero	# If there is not nothing there and it was not the color of an apple
          bnez $t1, gameOverU	# Then end the game
          
          snakeMoveU:		# If the snake is moving up and not growing or getting a game over	
             li $s6, DOWN	# Load a DOWN color, this is meant to point towards the next segment and eventually to the tail
             sw $s6, 0($s5)
             move $a0, $s5	# Move the address of the head to $a0 to call find tail subroutine
             jal findTail
             move $t0, $v0 	# Address of tail moved to $t0
             sw $zero, 0($t0)	# At $t0 nothing is stored, effectively erasing the tail and "moving" the snake
             lw $ra 0($sp)
             addi $sp, $sp, 4
             jr $ra		# Return to the loop
            
          growSnakeU:		# If the snake ate an apple and needs to grow
             li $s6, DOWN
             sw $s6, 0($s5)
             jal growSnake
             lw $ra 0($sp)
             addi $sp, $sp, 4
             jr $ra
             
          gameOverU:
             j gameOver
          
          
       goLeft:
          addi $sp, $sp, -4
	  sw $ra, 0($sp)
	  
	  li $t6, A_PRESS	# Handle subsequent invalid press
          
          # Draws new head
          addi $s5, $s5, -4
          lw $t0, 0($s5)	# Store the head data in $s5, if its RED, its an apple and grow. Else, if not zero, game over.
          
          seq $t1, $t0, APPLE
          bnez $t1, growSnakeL
          
          seq $t1, $t0, $zero
          bnez $t1, snakeMoveL
          
          sne $t1, $t0, $zero
          bnez $t1, gameOverL
          
          snakeMoveL:
             li $s6, RIGHT
             sw $s6, 0($s5)
             move $a0, $s5
             jal findTail
             move $t0, $v0 
             sw $zero, 0($t0)
             lw $ra 0($sp)
             addi $sp, $sp, 4
             jr $ra
            
          growSnakeL:
             li $s6, RIGHT
             sw $s6, 0($s5)
             jal growSnake
             lw $ra 0($sp)
             addi $sp, $sp, 4
             jr $ra
             
          gameOverL:
             j gameOver
       
       goDown:
	  addi $sp, $sp, -4
	  sw $ra, 0($sp)
	  
	  li $t6, S_PRESS	# Handle subsequent invalid press
          
          # Draws new head
          addi $s5, $s5, 128
          lw $t0, 0($s5)	# Store the head data in $s5, if its RED, its an apple and grow. Else, if not zero, game over.
          
          seq $t1, $t0, APPLE
          bnez $t1, growSnakeD
          
          seq $t1, $t0, $zero
          bnez $t1, snakeMoveD
          
          sne $t1, $t0, $zero
          bnez $t1, gameOverD
          
          snakeMoveD:
             li $s6, UP
             sw $s6, 0($s5)
             move $a0, $s5
             jal findTail
             move $t0, $v0 
             sw $zero, 0($t0)
             lw $ra 0($sp)
             addi $sp, $sp, 4
             jr $ra
            
          growSnakeD:
             li $s6, UP
             sw $s6, 0($s5)
             jal growSnake
             lw $ra 0($sp)
             addi $sp, $sp, 4
             jr $ra
             
          gameOverD:
             j gameOver
       
       goRight:
	  addi $sp, $sp, -4
	  sw $ra, 0($sp)
	  
	  li $t6, D_PRESS	# Handle subsequent invalid press
          
          # Draws new head
          addi $s5, $s5, 4
          lw $t0, 0($s5)	# Store the head data in $s5, if its RED, its an apple and grow. Else, if not zero, game over.
          
          seq $t1, $t0, APPLE
          bnez $t1, growSnakeR
          
          seq $t1, $t0, $zero
          bnez $t1, snakeMoveR
          
          sne $t1, $t0, $zero
          bnez $t1, gameOverR
          
          snakeMoveR:
             li $s6, LEFT
             sw $s6, 0($s5)
             move $a0, $s5
             jal findTail
             move $t0, $v0 
             sw $zero, 0($t0)
             lw $ra 0($sp)
             addi $sp, $sp, 4
             jr $ra
            
          growSnakeR:
             li $s6, LEFT
             sw $s6, 0($s5)
             jal growSnake
             lw $ra 0($sp)
             addi $sp, $sp, 4
             jr $ra
             
          gameOverR:
             j gameOver
       
   findTail:		# Subroutine to return the address of the head, for moving the snake (namely by removing the tail after the new head has been drawn)
   
      move $t0, $a0	# Address of head
      li $t2, 0		# Counter along length of snake
   	
      tailChaseLoop:		# A loop to follow the color/directions of the snake, colors point in direction of tail
         lw $t1, 0($t0)
   	
         seq $t3, $t2, $s7
         bnez $t3, endTailChaseLoop
   		
         seq $t3, $t1, DOWN
         bnez $t3, tailDown
   		
         seq $t3, $t1, LEFT
         bnez $t3, tailLeft
   		
         seq $t3, $t1, RIGHT
         bnez $t3, tailRight
   		
         seq $t3, $t1, UP
         bnez $t3, tailUp
         
         tailDown:
            addi $t0, $t0, 128
            addi $t2, $t2, 1
            b tailChaseLoop
         
         tailLeft:
            addi $t0, $t0, -4
            addi $t2, $t2, 1
            b tailChaseLoop
         
         tailRight:
            addi $t0, $t0, 4
            addi $t2, $t2, 1
            b tailChaseLoop
         
         tailUp:
            addi $t0, $t0, -128
            addi $t2, $t2, 1
            b tailChaseLoop
   		
   	endTailChaseLoop:
   	  
   	  move $v0, $t0		# Address of tail placed in $v0
   	  jr $ra
   	  
   growSnake:			# Set of conditions to check if snake grows
      li $t8, 0			# No apple now
      addi $s7, $s7, 1		# Increase snake length
      addi $t9, $t9, -30	# Sleep time reduces, snake speeds up
   endGrowth:
   	jr $ra
   	
   generateApple:		# Subroutine to generate the apple
	     seq $t0, $t8, 1	# If there is an apple, don't gen
	     bnez $t0, noGen

             
          genApple:		
             li $a1, 1023	# Generate a random number to correspond to a square in the bitmap
             li $v0, 42
             syscall
             move $t0, $a0	# Move the randomly generated number to $t0
             mul $t0, $t0, 4	# multiple the number by 4, per offset
             addi $t0, $t0, BMD	# Add the offset to the bitmap base
             li $t1, APPLE	# Prime $t1 to write a red dot (apple) at this location
             lw $t2, 0($t0)	# Determine what is stored in this location
             bnez $t2, genFail	# If there is something there, the apple generation fails
             beqz $t2, genSuccess	# If nothing is there, generate an apple
                
          genFail:
             b genApple		# Apple tried to generate on written square and failed, retry gen
                   
          genSuccess:
             li $t8, 1		# Store that an apple has been generated
             sw $t1, 0($t0)	# Write an apple at the location
             jr $ra
                
          noGen:
             jr $ra		# Simply return to loop if an apple already exists
             
generateProgressBar:
   beq $s7, 3, endGenerateProgressBar	# If the length is three, no apples have been collected
   li $t0, 3				# Counter initialized at 3 (length of snake when no apples have been collected)
   li $t1, 0x10040000			# Counter for loop to draw progress bar
   addi $t1, $t1, 44			# Set $t0 pointer to address of first slot in progress bar
   drawBarLoop:
      beq $t0, $s7, endGenerateProgressBar	# If the number of apples written into the progress bar is equal to the length - 3, end loop
      li $t2, APPLE				# Prepare to store an apple color in the progress bar
      sw $t2, 0($t1) 				# Put a red dot in the progress bar
      addi $t1, $t1, 4				# Increment bar pointer to next slot in the bar
      addi $t0, $t0, 1				# Increment length counter
      
      b drawBarLoop				# Repeat loop
   endGenerateProgressBar:
   jr $ra
             
.include "SnakeInclude.asm"	# Include file with subroutines for drawing the border, flashes, and (by include file extension) win/lose prompts
   	   	
gameOver:		# Code to execute when player loses
   li $t0, 0x10040000	# Reset white dots so flash works appropriately
   li $t1, 0x00ffffff  
   sw $t1, 44($t0)
   load
   sw $t1, 52($t0)
   load
   sw $t1, 60($t0)
   load
   sw $t1, 68($t0)
   load
   sw $t1, 76($t0)
   load
   
   LoserFlash
   LoserFlash
   LoserFlash
   LoserFlash
   jal writeGameOver

   li $v0, 10		# End program
   syscall
   
winner:			# Code to execute when player wins
   li $t0, 0x10040000	# Reset white dots so flash works appropriately
   li $t1, 0x00ffffff  
   sw $t1, 44($t0)
   load
   sw $t1, 52($t0)
   load
   sw $t1, 60($t0)
   load
   sw $t1, 68($t0)
   load
   sw $t1, 76($t0)
   load
   
  WinnerFlash
  WinnerFlash
  WinnerFlash
  WinnerFlash
  jal writeYouWin
  
  li $v0, 10		# End program
  syscall 
   	  
 .ktext 0x80000180
     # If we are here, then a key was pressed. 
     lw $s0, 0($s1)	# Move key press to $s0
     eret		# Error return
