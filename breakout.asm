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
	backgroundColor:.word	0xffffff	 # white
	borderColor:    .word	0xA9A9A9	 # grey	
	blockColor: 	.word	0x2bcc2e	 # green
	
	#Informações da barra
	barX: 	.word 31
	barY:	.word 31
.text
	main:
	#Desenha o background
	lw $a0, screenWidth #carrega a largura da tela
	lw $a1, backgroundColor #carrega a cor do fundo
	mul $a2, $a0, $a0 #faz o total do numero de pixels da tela 
	mul $a2, $a2, 4 #endereços 
	add $a2, $a2, $gp #add base of gp
	add $a0, $gp, $zero #contador do loop
	fillBackgroundLoop:
	beq $a0, $a2, Init #end condition, se a largura da tela for igual 
	nop
	sw $a1, 0($a0) #salva cor no background
	addiu $a0, $a0, 4 #incrementa contador
	j fillBackgroundLoop
	Init: #fim do desenho background
	nop
	add $a2, $zero, $gp #primeira posicao do display 
	lw $a1,borderColor #carrega a cor da borda
	add $a3, $gp , 16384# ulitma posiçao da borda 
	drawLeftBorder:
	beq $a2, $a3, LeftBorderDrawed
	nop
	sw $a1, 0($a2) #salva cor ($a1) no display ($a2)
	addiu $a2, $a2, 256 #incrementa o display em 256 pois cada word tem 4 bits e o display 64
	j drawLeftBorder
	nop
	LeftBorderDrawed:
	
	addi $a2, $gp, 252 #ultima coluna do display
	add $a3, $gp , 16636# ulitma posiçao da borda 
	drawRightBorder:
	beq $a2, $a3, RightBorderDrawed
	nop
	sw $a1, 0($a2) #salva cor ($a1) no display ($a2)
	addiu $a2, $a2, 256 #incrementa o display em 256 pois cada word tem 4 bits e o display 64
	j drawRightBorder
	nop
	RightBorderDrawed: 
	
	addi $a2, $gp, 0 #primeira coluna do display
	sw $a1, 0($a2) #salva cor ($a1) no display ($a2)
	add $a3, $gp , 252# ulitma posiçao da borda 
	drawTopBorder:
	beq $a2, $a3, TopBorderDrawed
	nop
	sw $a1, 0($a2) #salva cor ($a1) no display ($a2)
	addiu $a2, $a2, 4 #incrementa o display em 4 pois cada word tem 4 bits e o display 64
	j drawTopBorder
	nop
	TopBorderDrawed: nop
	
	
	
	
	
	
	
