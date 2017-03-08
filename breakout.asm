# 	Bitmap Display Settings:                                  			     
#	Unit Width: 8						     
#	Unit Height: 8						     
#	Display Width: 512					     	     
#	Display Height: 512					     
#	Base Address for Display: 0x10008000 ($gp)	

.data
############ Screen and Physichal prop ##################
							#
	screenWidth: 	.word 64			#
	screenHeight: 	.word 64			#
	barX: 		.word 31			#
	barY:		.word 31			#
	#maxPixels:	.word 2944			#
	maxPixels:	.word 4096			#
########### Frame Properities  ##########################
							#
	backgroundColor:.word	0x000000   # black 	#
	borderColor:    .word	0xA9A9A9   # grey	#
	blockColor: 	.word	0x2bcc2e   # green 	#
	palletColor: 	.word	0xA9A9A9   # grey	#
							#
########## Multiple Brick colors#########################	
							#
	red: 	.word 0xFF0000 	# Red Brikcs		#
	yellow: .word 0xF3FF00 	# Yellow Bricks		#
	green: 	.word 0x44FF00 	# Green Bricks		#
	blue: 	.word 0x0095FF	# Blue Bricks		#
							#
########## BALL ATRIBUTES ###############################
							#
	ballColor: .word 0xFFFFFF # white		#
	iniPosition: .word 16000  # over the bar	#
	position: .word 16000 	  # change over time	#
	direction: .word 4	  # up			#
	upAndDown: .word 1				#
	paddleColision: .word 0				#							#
############   PADDLE ATRIBUTES     #####################

	l1Ini: .word 0
	l1End: .word 0
	l2Ini: .word 0
	l2End: .word 0
	
#########################################################
	

.text
	.globl main
	main:
	
############### Desenha o background ####################
	lw $a0, screenWidth #carrega a largura da tela
	lw $a1, backgroundColor #carrega a cor do fundo
	mul $a2, $a0, $a0 #faz o total do numero de pixels da tela 
	mul $a2, $a2, 4 #endereços 
	la $a2, ($gp) #add base of gp
	add $a0, $gp, $zero #contador do loop
FillBackgroundLoop:
	
	beq $a0, $a2, Init #end condition, se a largura da tela for igual 
	nop
	sw $a1, 0($a0) #salva cor no background
	addi $a0, $a0, 4 #incrementa contador

j FillBackgroundLoop
nop
	Init: #fim do desenho background
	nop

################ Bricks implementation ##############################
	
	la $a0, 0($gp) 
	lw $t0, palletColor  
	li $a1, 64  
	mul $a1, $a1, 4  
	add $a1, $a1, $a0
	jal redBricks
	nop
	
	
	la $a0, 0($gp)
	addi $a0, $a0, 256 
	lw $t0, red  
	li $a1, 192  
	mul $a1, $a1, 4  
	add $a1, $a1, $a0
	jal redBricks
	nop
	
	la $a0, 0($gp) 
	lw $t0, yellow  
	li $a1, 192 
	mul $a1, $a1, 4
	add $a0, $a0, $a1
	add $a1, $a1, $a0
	jal yellowBricks
	nop
	
	la $a0, 0($gp) 
	lw $t0, green  
	li $a1, 320  
	mul $a1, $a1, 4
	add $a0, $a0, $a1
	addi $a1, $a0, 576  
	jal greenBricks
	nop
	
	la $a0, 0($gp) 
	lw $t0, blue  
	li $a1, 448  
	mul $a1, $a1, 4
	add $a0, $a0, $a1
	addi $a1, $a0, 512  
	jal blueBricks
	nop
	
	#left bar
	la $a0, 0($gp) # used the same func to make the bars 
	lw $t0, palletColor  
	li $a1, 4032 # left last dot vertical 
	mul $a1, $a1, 4  
	add $a1, $a1, $a0
	jal barL
	nop
	
	#right bar
	la $a0, 0($gp) # used the same func to make the bars
	addi $a0, $a0, 252
	lw $t0, palletColor  
	li $a1, 4095 # left last dot vertical 
	mul $a1, $a1, 4  
	add $a1, $a1, $gp
	jal barR
	nop

################ Pallet implementation #########################################
	
	la $a0, 0($gp)
	lw $t1, maxPixels 
	sub $t1, $t1, 35   	     	
	mul $t1, $t1, 4	    
	add $a0, $a0, $t1 
	or $a1, $zero, $a0
	addi $a1, $a1, 20
	
	
	sw $a0, l2Ini
	sw $a1, l2End
	
	jal buildPallet	
	nop

##########initialize ball ############################
	lw $a0, iniPosition
	add $a0, $a0, $gp
	sw $a0, position
	lw $a1, position # out of display range
	jal drawBall
	nop
################ Main loop #########################################
	li $t5, 1 # keep 1 to be used as a infinite looping
	
	# $a0 to $a1 keep beggining and end of first paddle layer
	# $t8 to $t9 keep beggining and end of last paddle layer
	# $a0 ball position
	# $a1 ball direction
	
	loop:
	
	lw $a0, position
	lw $a1, direction
	
	jal altMvBall
	nop
		
	jal getDir
	nop
	
	lw $a0, l2Ini
	lw $a1, l2End
	
	jal movePallet
	nop
	
	sw $a0, l2Ini
	sw $a1, l2End
	
	
	
	sw $zero, 0xFFFF0004
	
	li $t5, 1 # keep 1 to be used as a infinite looping
	bne $zero, $t5, loop
	nop
	
	
	
########## Syscall to finish program before enter in the jal functions #########
									      #
	li $v0, 10							     #
	syscall								    #
									   #
###########################################################################






#------------------------------------------------------------------#

#              Functions used in the program                     #
 
#--------------------------------------------------------------#


  #####################################
 #  Function to print red bricks     #
#####################################
.globl redBricks
redBricks:
	beq $a0, $a1, fimr
	nop
	sw $t0, 0($a0) 
	addi $a0, $a0, 4 
	j redBricks
	nop
	fimr:
	jr $ra
	nop
	
  ######################################
 #  Function to print grey bars       #
######################################
.globl barL
barL:
	beq $a0, $a1, fimL
	nop
	sw $t0, 0($a0) 
	addi $a0, $a0, 256
	j barL
	nop
	fimL:
	jr $ra
	nop
	
.globl barR
barR:
	beq $a0, $a1, fimR
	nop
	sw $t0, 0($a0) 
	addi $a0, $a0, 256
	j barR
	nop
	fimR:
	jr $ra
	nop


	
  #####################################
 #  Function to print yellow bricks  #
#####################################	
.globl yellowBricks
yellowBricks:
	beq $a0, $a1, fimy
	nop
	sw $t0, 0($a0)
	addi $a0, $a0, 4 
	j yellowBricks
	nop
	fimy:
	jr $ra
	nop

  #####################################
 #  Function to print green bricks   #
#####################################	
.globl greenBricks
greenBricks:
	beq $a0, $a1, fimg
	nop
	sw $t0, 0($a0) 
	addi $a0, $a0, 4 
	j greenBricks
	nop
	fimg:
	jr $ra
	nop
	
  #####################################
 #  Function to print green bricks   #
#####################################	
.globl blueBricks
blueBricks:
	beq $a0, $a1, fimb
	nop
	sw $t0, 0($a0) 
	addi $a0, $a0, 4 
	j blueBricks
	nop
	fimb:
	jr $ra
	nop


  #####################################
 #  Function that draws the pallet   #
#####################################
.globl buildPallet
buildPallet:
	lw $t0, palletColor
	beq $a0, $a1, fimPallet
	nop
	sw $t0, 0($a0) 
	addi $a0, $a0, 4 
	j buildPallet
	nop
	fimPallet:
	jr $ra
	nop

  #####################################
 #  Function that moves the pallet   #
#####################################
.globl movePallet
movePallet:
	
	
	#  ----> ASCII 97 == a in $t3 |||| 100 == d  in $t4 <----  #
	li $t3, 97
	li $t4, 100
	
	# Get bg and palletColor
	lw $t6, backgroundColor
	lw $t7, palletColor
	
	
	bne $t0, $t3, toD
	nop
	
	# $a0 to $a1, keep beggining and
	# end of one of two paddle layers
	sw $t6, 0($a1)
	subi $a1, $a1, 4
  	
  	subi $a0, $a0, 4
	sw $t7, 0($a0)
	  	  	
  	j fimMove
  	nop
  	
  	toD:
  	bne $t0, $t4, fimMove
  	nop
  	addi $a1, $a1, 4
	sw $t7, 0($a1)
	sw $t6, 0($a0)
  	addi $a0, $a0, 4
  	  	
  	fimMove:
  	jr $ra
  	nop
  	
  	
  	
######## getDir where paddle will be moved ###############
.globl getDir	
getDir:
	lw $t0, 0xFFFF0004
	jr $ra
	nop

  ####################################
 #  Function that draws the ball   #############
 #$a0 position to draw ####################
# $a1 position to clean #################### 
#####################################
drawBall:
	lw $t1, ballColor
	lw $t2, backgroundColor
	beq $a0, $a1, samePos
	nop
	sw $t1, 0($a0)
	sw $t2, 0($a1) 
	j endDrawBall
	nop
samePos:
	sw $t1, 0($a0)
endDrawBall:
	jr $ra
	nop
######## move ball######################
# $a0 ball position 		      #
# $a1 direction		             #
# $a1 = 0 = down #		    #
####################################
moveBall:
	subi $sp, $sp, 4
	sw $ra, 0($sp)
	
	beq $a1, 1, up 
	nop
	
	beq $a1, 0, down
	nop
	
	j ballMoved
	nop
up: 	
	
	
	
	subi $s0, $a0, 256 #get next up dot
	or $s2, $zero, $s0
	lw $s0, 0($s0)
	lw $s1, backgroundColor
	
	bne $s0, $s1,  fimUp
	nop
		
	move $a1, $a0 #set $a1 to clear position
	subi $a0, $a0, 256 #set $a0 to draw position
	
	sw $a0, position
	jal delay
	nop
	jal drawBall
	nop
	
	
	j ballMoved
	nop
	
	fimUp:
	
	sw $zero, direction
	
	lw $s3, palletColor
	
	beq $s0,  $s3, keepU
	nop
	
	jal delDot
	nop
	
	keepU:
	
	j ballMoved
	nop
	
down:	
	
	addi $s0, $a0, 256 #get next up dot
	or $s2, $zero, $s0
	lw $s0, 0($s0)
	lw $s1, backgroundColor
	
	bne $s0, $s1,  fimDown
	nop 	
	 	
	move $a1, $a0 #set $a1 to clear position
	addi $a0, $a0, 256 #set $a0 to draw position
	sw $a0, position
	jal delay
	nop
	jal drawBall
	nop
	j ballMoved
	nop
	
	fimDown:
	
	sw $t5, direction
	
	lw $s3, palletColor
	
	beq $s0,  $s3, keepD
	nop
	jal delDot
	nop
	
	keepD:
	j ballMoved
	nop
	
ballMoved:
	lw $ra, 0($sp)
	addi $sp, $sp ,4
	jr $ra
	nop
			
############## DELAY#######
delay: 	li $t1, 0
delayLoop:	beq $t1, 4000, endDelay
		nop
		addi $t1, $t1, 1
		j delayLoop
		nop
endDelay: 	jr $ra
		nop

#### erase func #############
#### $s2 current dot address###
#### $s1 black##########
delDot:
	subi $sp, $sp, 4
	sw $ra, 0($sp) #saving the current adress
	move $a0, $s2 #set surroundings argument
	jal surroundings
	nop
	sw $s1, 0($s2)	#turn current dot into black
	lw $ra, 0($sp)
	addi $sp, $sp ,4
	jr $ra
	nop
	nop

###### erase surroundings########
# $a1 is the current adress#
surroundings:
	lw $t0, palletColor #load pallet color
	lw $t1, backgroundColor #load background color
	lw $t2, 4($a0)
	lw $t3, -4($a0) #load dot surroundings
	beq $t2, $t0, sameColor1
	nop
	sw  $t1, 4($a0) #stores black into right surrounding
	sameColor1: beq $t3, $t0, sameColor2
	nop
	sw $t1, -4($a0) #stores black into left surrounding
	sameColor2:jr $ra
	nop
#### End game######
### $a0 ball position ####
	endGame:
	la $a2, ($gp) #add base of gp
	addi $a2, $a2, 16384
	slt $a1, $a0, $a2 #se posicao da bola for maior que o fim da tela coloca 0
	beq $a1, $zero, ended #se for igual a 0 acaba o jogo
	nop
	jr $ra
	nop
	ended:li $v0, 10
	syscall
	
####################
#### Alternative move ball ########
# $a0 position #
# $a1 direction#
#MARCO LOK VE SE BOTA OS ARGUMENTO DIREITO#
.globl altMvBall
altMvBall:

	subi $sp, $sp, 4
	sw $ra, 0($sp)
	
	beq $a1, 3, trD 
	nop
	
	beq $a1, 4, qcD
	nop
	
	beq $a1, 5, ssD
	nop
	
	beq $a1, 0, trE
	nop
	
	beq $a1, 1, qcE
	nop
	
	beq $a1, 2, ssE
	nop
	
	j AltBallMoved
	nop
	
	trD:
	nop
	
	qcD:
	
	lw $s7, upAndDown
	
	bne $s7, $zero, up_qcD #upward
	nop
	li $t9, 256 #down
	j keep_qcD 
	nop
	up_qcD:
	li $t9, -256 # up
	keep_qcD:
	
	add $s0, $a0, $t9 #get next  dot up/down
	addi $s0, $s0, 4 #And get dir of up dot
	or $s2, $zero, $s0
	
	lw $s0, 0($s0) #loads  $s0 with the next color
	lw $s1, backgroundColor
	
	bne $s0, $s1,  fim_qcD # if $s0 color its not black
	nop
		
	move $a1, $a0 #set $a1 to clear position
	add $a0, $a0, $t9 #set $a0 to draw position
	addi $a0, $a0, 4
	
	sw $a0, position
	jal delay
	nop
	
	jal drawBall
	nop
	
	jal endGame
	nop
	 
	j AltBallMoved
	nop
	
	fim_qcD: #color is not black
	
	bne $s7, $zero, go_qcD #if direction its up
	nop#is down
	
	li $s7, 4 #direction goes to 40 right
	sw $s7, direction
	li $s7, 1 
	sw $s7, upAndDown #sets to go up
	j afterPallet
	nop
	go_qcD:	#is up
	
	lw $s3, palletColor
	
	sw $s7, upAndDown
	
	li $s7, 1 
	sw $s7, direction #sets to goes 40 left
	
	subi $s2, $s2, 4
	jal isPaddleOrTop
	nop
	
	afterPallet:
	
	beq $s0,  $s3, AltBallMoved #if next  dot up/down == palletColor
	nop
	
	jal delDot
	nop
	
	li $s7, 1
	sw $s7, direction
	li $s7, 0
	sw $s7, upAndDown
	
	
	j AltBallMoved
	nop
	
	ssD:
	nop
	
	trE:
	nop
	
	qcE:
	
	lw $s7, upAndDown
	
	bne $s7, $zero, up_qcE
	nop
	li $t9, 256
	j keep_qcE
	nop
	up_qcE:
	li $t9, -256
	keep_qcE:
	add $s0, $a0, $t9 #get next up dot
	subi $s0, $s0, 4 #And get dir of up dot
	or $s2, $zero, $s0
	
	lw $s0, 0($s0)
	lw $s1, backgroundColor
	
	
	
	bne $s0, $s1,  fim_qcE #if next dot != black
	nop
		
	move $a1, $a0 #set $a1 to clear position
	add $a0, $a0, $t9 #set $a0 to draw position
	subi $a0, $a0, 4
	
	sw $a0, position
	jal delay
	nop
	
	jal drawBall
	nop

	jal endGame
	nop
	
	j AltBallMoved
	nop
	
	fim_qcE: #next != black
	
	lw $s3, palletColor
	
	sw $s7, upAndDown
	
	li $s7, 4
	sw $s7, direction
	
	
	addi $s2, $s2, 4
	
	jal isPaddleOrTop
	nop
			
	beq $s0,  $s3, AltBallMoved #if next dot == palletColor
	nop
	

	
	jal delDot
	nop
	
	li $s7, 1
	sw $s7, direction
	li $s7, 0
	sw $s7, upAndDown
	
	
	j AltBallMoved
	nop
	
	ssE:
	nop
	
	
AltBallMoved:
	lw $ra, 0($sp)
	addi $sp, $sp ,4
	jr $ra
	nop

isPaddleOrTop:
	la $t3, 0($gp) #load gp to 
	addi $t3, $t3, 256 # get first monitor line last pixel
	sle $t4, $a0, $t3
	beq $t4, $zero, outOfTop
		nop
		not $t4, $t4
		sw $t4, upAndDown
		jr $ra
		nop
	outOfTop:
		lw $t3, l2Ini
		sub $t4, $a0, $t3
		slt $t4, $t4, $zero
		
		beq $t4, $zero, verifyDirPaddle1
			nop
			jr $ra
			nop
			
		verifyDirPaddle1:
		
		lw $t3, l2End
		sub $t4, $t3, $a0
		slt $t4, $t4, $zero
		
		beq $t4, $zero, verifyDirPaddle2
			nop
			jr $ra
			nop
		verifyDirPaddle2:		
		
		lw $t3, l2End
		sub $t4, $t3, $a0
		div $t4, $t4, 4
		nop
		mflo $t4
		sw $t4, direction
		jr $ra
		nop
		
		

