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
	maxPixels:	.word 2944			#
							#
########### Frame Colors ################################
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
#########################################################
	
.text
	.globl main
	main:
	#Desenha o background
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
	addiu $a0, $a0, 4 #incrementa contador

j FillBackgroundLoop
	
	Init: #fim do desenho background
	nop

################ Bricks implementation ##############################

	la $a0, 0($gp)  
	lw $t0, red  
	li $a1, 128  
	mul $a1, $a1, 4  
	add $a1, $a1, $a0
	jal redBricks
	nop
	
	la $a0, 0($gp) 
	lw $t0, yellow  
	li $a1, 128 
	mul $a1, $a1, 4
	add $a0, $a0, $a1
	add $a1, $a1, $a0
	jal yellowBricks
	nop
	
	la $a0, 0($gp) 
	lw $t0, green  
	li $a1, 256  
	mul $a1, $a1, 4
	add $a0, $a0, $a1
	addi $a1, $a0, 512  
	jal greenBricks
	nop
	
	la $a0, 0($gp) 
	lw $t0, blue  
	li $a1, 384  
	mul $a1, $a1, 4
	add $a0, $a0, $a1
	addi $a1, $a0, 512  
	jal blueBricks
	nop
	
################ Pallet implementation #########################################

##### memoria maxima 2944
	
	
	la $a0, 0($gp)
	lw $t1, maxPixels 
	sub $t1, $t1, 35   	     	
	mul $t1, $t1, 4	    
	add $a0, $a0, $t1 
	la $a1, 0($a0)
	addi $a1, $a1, 32
	lw $t0, palletColor
	
	jal buildPallet	
	nop
	
	la $a0, 0($gp)
	lw $t1, maxPixels 
	sub $t1, $t1, 99   	     	
	mul $t1, $t1, 4	    
	add $a0, $a0, $t1 
	la $a1, 0($a0)
	addi $a1, $a1, 32
	lw $t0, palletColor
	
	jal buildPallet	
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

	beq $a0, $a1, fimPallet
	nop
	sw $t0, 0($a0) 
	addi $a0, $a0, 4 
	j buildPallet
	nop
	fimPallet:
	jr $ra
	nop

