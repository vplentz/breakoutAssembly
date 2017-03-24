# breakoutAssembly
Alunos: Vítor Plentz e Marco Birck.
Breakout in Assembly (MIPS Mars)
Instruções para executar o breakout:
1- Utilizar Mars corrigido que acompanha o arquivo .asm;
2- Utilizar o Bitmap Displat com as seguintes configurações:
	- Unit Width in pixels: 8;
	- Unit Height in pixels: 8;
	- Display Width in pixels: 512;
	- Display Height in pixels: 512;
	- Base address for display: 0x10008000($gp);
3- Conectar o KeyBoard Simulator.

#############################################################

	INSTRUÇÕES DO JOGO:

No menu inicial há as seguintes possibilidades:

	1- Iniciar jogo;
	2- Score;
	3- Exit;
		

#############################################################
Iniciar jogo:
		- Selecione o nível ( easy, medium or hard);
		- Para mover para a esquerda aperte 'a';
		- Para mover para a direita aperte 'd'.
		- Para finalizar o jogo, morra.
#############################################################
Score :
		- Exibe um log com o score mais alto (funciona parcialmente).
#############################################################
Exit:
		- Chama syscall de término de programa.
#############################################################
	FUNÇOES DO JOGO:
- ESCOLHA DE NÍVEL: Define o delay do game;
- DESENHO DE BACKGROUND: Constroi bricks e e barras laterais;
- DESENHO DO PALLET: Controi o pallet guardando referências para movimentação;
- DESENHO DA BOLINHA: Desenha bolinha em determinada posição da tela;
- PADDLE MOVIMENTAÇÃO E FUNCIONALIDADES: O paddle é dividio em 6 pixels que 
	definem as possibilidades de movimentação em graus de rebate sendo da esqueda 
	para direita [30ESQ, 45ESQ, 90, 90, 45DIR, 30DIR], a movimentação do mesmo se dá
	pelo keybord simulator;
- DETECÇÃO DE COLISÃO: Quando a bolinha colide com algum pixel que não é preto, alguma das 
	ações é tomada:
		1- Se o pixel for cinza e for lateral: modifica a direção (esquerda, direita)
			da bolinha;
		2- Se o pixel for cinza e for a barra superior: coloca a bolinha em movimento 
			para baixo, mantendo o grau da mesma;
		3- Se o pixel for cinza e for o paddle: rebate conforme as definições já
			explicadas;
		4- Se o pixel for de outra cor(BRICKS): Destroi um grupo de pixels.
-SCORE: É aumentado quando há destruição de bricks, e é salvado quando o jogo é finalizado.
-TERMINO DE GAME: O jogo é finalizado quando a bolinha sai da área dos pixels da tela.
     
 
Example:

![alt tag](https://github.com/vplentz/breakoutAssembly/blob/master/gamePlay.gif)
