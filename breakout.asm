# 	Bitmap Display Settings:                                  			     
#	Unit Width: 8						     
#	Unit Height: 8						     
#	Display Width: 512					     	     
#	Display Height: 512					     
#	Base Address for Display: 0x10008000 ($gp)	

.data
	#Screen
	screenWidth: 	.word 64
	screenHeight: 	.word 64
	
	#Colors
	backgroundColor:.word	0x000000	 # black
	borderColor:    .word	0xffffff	 # white	
	blockColor: 	.word	0x2bcc2e	 # green
	
	#Informações da barra
	barX: 	.word 31
	barY:	.word 31
.text
	main:
	#Desenha o background
	lw $a0, screenWidth #carrega a largura da tela
	lw $a1, blockColor #carrega a cor do fundo
	mul $a2, $a0, $a0 #faz o total do numero de pixels da tela 
	mul $a2, $a2, 4 #endereços 
	add $a2, $a2, $gp #add base of gp
	add $a0, $gp, $zero #contador do loop
	FillLoop:
	beq $a0, $a2, Init #end condition, se a largura da tela for igual 
	nop
	sw $a1, 0($a0) #salva cor no background
	addiu $a0, $a0, 4 #incrementa contador
	j FillLoop
	Init: #fim do desenho background
	nop
