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
	maxPixels:	.word 4096
	delayMessage: 	.asciiz "Select level:\n 1(easy)\n 2(medium)\n 3(hard)\n"
	menuMessage: 	.asciiz "Select option:\n 1(Play)\n 2(Scores)\n 3(Exit)\n"
	scores:         .asciiz "log.txt"
	buffer:         .asciiz "Falha ao ler arquivo log.txt" #espaco relativo a 256 x 256    
	gameOver:	.asciiz "GAME OVER \n Sua Pontuação foi: "
	typeName:       .asciiz "Digite seu nick para registrar o score:"
	ranking:        .asciiz "O log de points eh:\n"                                                                                                                                           "
	dlay:		.word 4000			#
	
	point:		.word 0
	
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
	paddleColision: .word 0				#							
############   PADDLE ATRIBUTES     #####################

	l1Ini: .word 0
	l1End: .word 0
	l2Ini: .word 0
	l2End: .word 0
	
################    ##############################
	

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
	
	beq $a0, $a2, menu #end condition, se a largura da tela for igual 
	nop
	sw $a1, 0($a0) #salva cor no background
	addi $a0, $a0, 4 #incrementa contador

j FillBackgroundLoop
nop

menu:	
	sw $zero, point
	###### Menu ##############
	li $v0, 51
	la $a0, menuMessage
	syscall
	
	beq $a0, 3, exit
	nop
	
	beq $a0, 1, play
	nop
	
	beq $a0, 2, getScores
	nop
	
	
	
	
	
	
	################ Level of game #####################
	play:
	
	li $v0, 51
	la $a0, delayMessage
	syscall
	
	bne $a1, 0, outOfGame
	nop
		#set delay
		beq $a0, 1, easy
		nop
		beq $a0, 2, medium
		nop
		beq $a0, 3, hard
		nop
		j outOfGame
		nop
	easy: li $a0, 12000
		sw $a0, dlay
		j endDialog
		nop
	medium: li $a0, 8000
		sw $a0, dlay
		j endDialog
		nop
	hard: li $a0, 5000
		sw $a0, dlay
		j endDialog
		nop
	outOfGame: 
	li $v0, 10
	syscall
	endDialog:
	#########################################	 
		
	

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
	
	la $a0, 0($gp) 
	lw $t0, backgroundColor  
	li $a1, 4032  
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
	exit:								      #
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
lw $t2, dlay
delayLoop:	beq $t1, $t2, endDelay
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
	li $v0, 31						               #
	li $a0, 66 # dont care                                                 #
	li $a1, 500                                                           #
	li $a2, 32                                                        #
	li $a3, 127                                                            #
	syscall
	lw $a0, point
	addi $a0, $a0, 10
	sw $a0, point
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
	sameColor2:
	addi $a0, $a0, -256
	lw $t2, 4($a0)
	lw $t3, -4($a0) #load dot surroundings
	lw $t4, 0($a0)
	beq $t2, $t0, sameColor3
	nop
	sw  $t1, 4($a0) #stores black into right surrounding
	sameColor3: beq $t3, $t0, sameColor4
	nop
	sw $t1, -4($a0) #stores black into top left surrounding
	sameColor4:
	beq $t2, $t0, sameColor5
	nop
	sw  $t1, 4($a0) #stores black into top right surrounding
	sameColor5:
	beq $t4, $t0, sameColor6
	nop
	sw  $t1, 0($a0) #stores black into top surrounding
	sameColor6:
	addi $a0, $a0, 256
	jr $ra
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
	ended:
	li $v0, 56
	la $a0, gameOver
	lw $a1, point 
	syscall
	
	
	li $v0, 54
	la $a0, typeName
	la $a1, buffer 
	syscall 
	
	
	j main
	nop
	
	
	
	
####################
#### Alternative move ball ########
# $a0 position #
# $a1 direction#
#MARCO LOK VE SE BOTA OS ARGUMENTO DIREITO#
.globl altMvBall
altMvBall:

	subi $sp, $sp, 4
	sw $ra, 0($sp)
	
	beq $a1, 5, trD 
	nop
	
	beq $a1, 4, qcD
	nop
	
	beq $a1, 3, upM
	nop
	
	beq $a1, 0, trE
	nop
	
	beq $a1, 1, qcE
	nop
	
	beq $a1, 2, upM
	nop
	
	j AltBallMoved
	nop
	
############################ func to 90 ################################

upM:
	
	lw $s7, upAndDown
	
	bne $s7, $zero, up_upM
	nop
	li $t9, 256
	j keep_upM
	nop
	up_upM:
	li $t9, -256
	keep_upM:
	add $s0, $a0, $t9 #get next up dot
	or $s2, $zero, $s0
	
	lw $s0, 0($s0)
	lw $s1, backgroundColor
	
	
	
	bne $s0, $s1,  fim_upM #if next dot != black
	nop
		
	move $a1, $a0 #set $a1 to clear position
	add $a0, $a0, $t9 #set $a0 to draw position
	
	sw $a0, position
	jal delay
	nop
	lw $a0, position
	jal drawBall
	nop

	jal endGame
	nop
	
	j AltBallMoved
	nop
	
	fim_upM: #next != black
	

	
	li $s7, 2
	jal isPaddleOrTop
	nop
	lw $s3, palletColor	
	beq $s0,  $s3, AltBallMoved #if next dot == palletColor
	nop
	

	
	jal delDot
	nop
	
	li $s7, 3
	sw $s7, direction
	li $s7, 0
	sw $s7, upAndDown
	
	
	j AltBallMoved
	nop
	
	
	
	
############################ func 30 D ################################
	trD:
	jal delay
	nop
	lw $s7, upAndDown
	
	bne $s7, $zero, up_trD
	nop
	li $t9, 256
	j keep_trD
	nop
	up_trD:
	li $t9, -256
	keep_trD:
	add $s0, $a0, $t9 #get next up dot
	addi $s0, $s0, 8 #And get dir of up dot
	or $s2, $zero, $s0
	
	lw $s0, 0($s0)
	lw $s1, backgroundColor
	
	
	
	bne $s0, $s1,  fim_trD #if next dot != black
	nop
		
	move $a1, $a0 #set $a1 to clear position
	add $a0, $a0, $t9 #set $a0 to draw position
	addi $a0, $a0, 8
	
	sw $a0, position
	jal delay
	nop
	
	lw $a0, position
	
	jal drawBall
	nop

	jal endGame
	nop
	
	j AltBallMoved
	nop
	
	fim_trD: #next != black
	
	li $s7, 0
	jal isPaddleOrTop
	nop
	
	lw $s3, palletColor
			
	beq $s0,  $s3, AltBallMoved #if next dot == palletColor
	nop
	

	
	jal delDot
	nop
	
	li $s7, 5
	sw $s7, direction
	li $s7, 0
	sw $s7, upAndDown
	
	
	j AltBallMoved
	nop
	
##################### funcao 45 D #############
	qcD:
	
	lw $s7, upAndDown
	
	bne $s7, $zero, up_qcD
	nop
	li $t9, 256
	j keep_qcD
	nop
	up_qcD:
	li $t9, -256
	keep_qcD:
	add $s0, $a0, $t9 #get next up dot
	addi $s0, $s0, 4 #And get dir of up dot
	or $s2, $zero, $s0
	
	lw $s0, 0($s0)
	lw $s1, backgroundColor
	
	
	
	bne $s0, $s1,  fim_qcD #if next dot != black
	nop
		
	move $a1, $a0 #set $a1 to clear position
	add $a0, $a0, $t9 #set $a0 to draw position
	addi $a0, $a0, 4
	
	sw $a0, position
	jal delay
	nop
	lw $a0, position
	jal drawBall
	nop

	jal endGame
	nop
	
	j AltBallMoved
	nop
	
	fim_qcD: #next != black
	

	
	li $s7, 1
	jal isPaddleOrTop
	nop
	lw $s3, palletColor	
	beq $s0,  $s3, AltBallMoved #if next dot == palletColor
	nop
	

	
	jal delDot
	nop
	
	li $s7, 4
	sw $s7, direction
	li $s7, 0
	sw $s7, upAndDown
	
	
	j AltBallMoved
	nop
######################	 60 D #####################################
	ssD:
	lw $s7, upAndDown
	
	bne $s7, $zero, up_ssD
	nop
	li $t9, 512
	j keep_ssD
	nop
	up_ssD:
	li $t9, -512
	keep_ssD:
	add $s0, $a0, $t9 #get next up dot
	addi $s0, $s0, 4 #And get dir of up dot
	or $s2, $zero, $s0
	
	lw $s0, 0($s0)
	lw $s1, backgroundColor
	
	
	
	bne $s0, $s1,  fim_ssD #if next dot != black
	nop
		
	move $a1, $a0 #set $a1 to clear position
	add $a0, $a0, $t9 #set $a0 to draw position
	addi $a0, $a0, 4
	
	sw $a0, position
	jal delay
	nop
	
	lw $a0, position
	
	jal drawBall
	nop

	jal endGame
	nop
	
	j AltBallMoved
	nop
	
	fim_ssD: #next != black
	

	
	li $s7, 2
	jal isPaddleOrTop
	nop
	lw $s3, palletColor
	beq $s0,  $s3, AltBallMoved #if next dot == palletColor
	nop
	

	
	jal delDot
	nop
	
	li $s7, 3
	sw $s7, direction
	li $s7, 0
	sw $s7, upAndDown
	
	
	j AltBallMoved
	nop
	
	
############################ 30 E ############################
	trE:
	jal delay
	nop
	lw $s7, upAndDown
	
	bne $s7, $zero, up_trE
	nop
	li $t9, 256
	j keep_trE
	nop
	up_trE:
	li $t9, -256
	keep_trE:
	add $s0, $a0, $t9 #get next up dot
	subi $s0, $s0, 8 #And get dir of up dot
	or $s2, $zero, $s0
	
	lw $s0, 0($s0)
	lw $s1, backgroundColor
	
	
	
	bne $s0, $s1,  fim_trE #if next dot != black
	nop
		
	move $a1, $a0 #set $a1 to clear position
	add $a0, $a0, $t9 #set $a0 to draw position
	subi $a0, $a0, 8
	
	sw $a0, position
	jal delay
	nop
	
	lw $a0, position
	
	jal drawBall
	nop

	jal endGame
	nop
	
	j AltBallMoved
	nop
	
	fim_trE: #next != black
	
	li $s7, 5
	jal isPaddleOrTop
	nop
	lw $s3, palletColor
	beq $s0,  $s3, AltBallMoved #if next dot == palletColor
	nop
	

	
	jal delDot
	nop
	
	li $s7, 0
	sw $s7, direction
	li $s7, 0
	sw $s7, upAndDown
	
	
	j AltBallMoved
	nop
########################## 45 E ####################################
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
	
	lw $a0, position
	
	jal drawBall
	nop

	jal endGame
	nop
	
	j AltBallMoved
	nop
	
	fim_qcE: #next != black
	
	

	
	li $s7, 4
	jal isPaddleOrTop
	nop
	lw $s3, palletColor
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
###################### 60 E ######################################
	ssE:
	lw $s7, upAndDown
	
	bne $s7, $zero, up_ssE
	nop
	li $t9, 512
	j keep_ssE
	nop
	up_ssE:
	li $t9, -512
	keep_ssE:
	add $s0, $a0, $t9 #get next up dot
	subi $s0, $s0, 4 #And get dir of up dot
	or $s2, $zero, $s0
	
	lw $s0, 0($s0)
	lw $s1, backgroundColor
	
	
	
	bne $s0, $s1,  fim_ssE #if next dot != black
	nop
		
	move $a1, $a0 #set $a1 to clear position
	add $a0, $a0, $t9 #set $a0 to draw position
	subi $a0, $a0, 4
	
	sw $a0, position
	jal delay
	nop
	
	lw $a0, position
	
	jal drawBall
	nop

	jal endGame
	nop
	
	j AltBallMoved
	nop
	
	fim_ssE: #next != black
	
	

	
	li $s7, 3
	jal isPaddleOrTop
	nop
	lw $s3, palletColor
	beq $s0,  $s3, AltBallMoved #if next dot == palletColor
	nop
	

	
	jal delDot
	nop
	
	li $s7, 2
	sw $s7, direction
	li $s7, 0
	sw $s7, upAndDown
	
	
	j AltBallMoved
	nop

	
	
AltBallMoved:	
	lw $ra, 0($sp)
	addi $sp, $sp ,4
	jr $ra
	nop
###### $a0 ball position ########
###### $s7 next direction ######## 
isPaddleOrTop:
	li $v0, 31						               #                                             #
	li $a1, 500                                                           #
	li $a2, 32                                                        #
	li $a3, 127                                                            #
	syscall
	
	la $t3, 0($gp) #load gp to 
	addi $t3, $t3, 256 # get first monitor line last pixel
	lw $t9, upAndDown
	bne $t9, $zero, up_Pad
	nop
	addi $s3, $a0, 256
	j keep_Pad
	nop
	up_Pad:
	addi $s3, $a0, -256
	keep_Pad:
	sle $t4, $s3, $t3
	nop
	beq $t4, $zero, outOfTop #se nao estiver no topo
		nop
		li $t4, 0 #não um é zero
		sw $t4, upAndDown
		jr $ra
		nop
	outOfTop:
		
		
		
		lw $t3, l2Ini #inicio da barra
		sub $t4, $s3, $t3 #$t4 <0
		slt $t4, $t4, $zero 	
		beq $t4, $zero, verifyDirPaddle1
			nop
			sw $s7, direction
			jr $ra
			nop
			
		verifyDirPaddle1:
		
		lw $t3, l2End #final da barra
		sub $t4, $t3, $a0 #$t4 = finalbarra - posiçao bola
		slt $t4, $t4, $zero
		
		beq $t4, $zero, verifyDirPaddle2
			nop
			sw $s7, direction
			jr $ra
			nop
		verifyDirPaddle2:		
		
		lw $t3, l2Ini
		sub $t4, $s3, $t3
		div $t4, $t4, 4
		nop
		li $s7, 1
		sw $s7, upAndDown
		sw $t4, direction
		jr $ra
		nop

getScores:
 
 	
# Sample MIPS program that writes to a new file.
#   by Kenneth Vollmar and Pete Sanderson

        .data
        .text
  ###############################################################
  # Open (for writing) a file that does not exist
  li   $v0, 13       # system call for open file
  la   $a0, scores     # output file name
  li   $a1, 1        # Open for writing (flags are 0: read, 1: write)
  li   $a2, 0        # mode is ignored
  syscall            # open a file (file descriptor returned in $v0)
  move $s6, $v0      # save the file descriptor 
  ###############################################################
  # Write to file just opened
  li   $v0, 15       # system call for write to file
  move $a0, $s6      # file descriptor 
  la   $a1, buffer   # address of buffer from which to write
  li   $a2, 10       # hardcoded buffer length
  syscall            # write to file
  ###############################################################
  # Close the file 
  li   $v0, 16       # system call for close file
  move $a0, $s6      # file descriptor to close
  syscall            # close file
  ###############################################################
  li $v0, 59
  la $a0, ranking
  la $a1, buffer
	syscall 
  
  j main
  nop
	
setScores:

  ###############################################################
  # Open (for writing) a file that does not exist
  li   $v0, 13       # system call for open file
  la   $a0, scores     # output file name
  li   $a1, 0        # Open for writing (flags are 0: read, 1: write)
  li   $a2, 0        # mode is ignored
  syscall            # open a file (file descriptor returned in $v0)
  move $s6, $v0      # save the file descriptor 
  ###############################################################
  # Write to file just opened
  li   $v0, 15       # system call for write to file
  move $a0, $s6      # file descriptor 
  la   $a1, menuMessage   # address of buffer from which to write
  li   $a2, 44       # hardcoded buffer length
  syscall            # write to file
  ###############################################################
  # Close the file 
  li   $v0, 16       # system call for close file
  move $a0, $s6      # file descriptor to close
  syscall            # close file
  ###############################################################
	j main
	nop



