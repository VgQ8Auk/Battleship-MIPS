.data

	SetUpPhase: .asciiz "\n-------------\nBATTLESHIP\n\nEach player has 3 destroyers (2x1), 2 cruisers (3x1) and 1 battleship (4x1) to fight.\n-------------\nSetup phase!\n"
	Player1Input: .asciiz "Player 1's turn to type your ship position: \n"
	Player2Input: .asciiz "Player 2's turn to type your ship position: \n"
	WrongFormat: .asciiz "Wrong Input Format. Exit..."
	InvalidBoat: .asciiz "Invalid ship(s) position. Exit..."
	TooManyBattleships: .asciiz "You entered more than 1 Battleship. Exit..."
	TooManyCruisers: .asciiz "You entered more than 2 Cruisers. Exit..."
	TooManyDestroyers: .asciiz "You entered more than 3 Cruisers. Exit..."
	OverlapShip: .asciiz "Ship overlapped."
	Players: .asciiz "Player "
	Turn: .asciiz "'s turn:\n"
	WrongInputFormat: .asciiz "Wrong Input. "
	Win: .asciiz " wins."
	Hit: .asciiz "HIT!\n"
	InputTurnA: .space 10
	InputTurnB: .space 10
	InputStringA: .space 100
	InputStringB: .space 100
	BoardA: .space 49 
	BoardB: .space 49
	ConvertedA: .space 25
	ConvertedB: .space 25
	BattleshipA: .word 1
	BattleshipB: .word 1
	CruisersA: .word 2
	CruisersB: .word 2
	DestroyersA: .word 3
	DestroyersB: .word 3
.text
.globl main
main:

	la $t0, BoardA
	jal InitBoard
	
	la $t0, BoardB
	jal InitBoard
	la $a0, SetUpPhase
	li $v0, 4
	syscall
	PlayerInput:
		li $t9, 5
		la $a0, Player1Input
		li $v0, 4
		syscall
		li $v0, 8
		la $a0, InputStringA
		li $a1, 100
		syscall
		la $t0, InputStringA
		jal CheckingStringValidStart
		la $t0, InputStringA
		la $t1, ConvertedA
		jal ConvertToBoardPositionStart
		jal PutBoatOnBoardA

		li $t9, 5
		la $a0, Player2Input
		li $v0, 4
		syscall
		li $v0, 8
		la $a0, InputStringB
		li $a1, 100
		syscall
		la $t0, InputStringB
		jal CheckingStringValidStart
		la $t0, InputStringB
		la $t1, ConvertedB
		jal ConvertToBoardPositionStart
		jal PutBoatOnBoardB
		
		li $s0, 1
		Gamestart:
		li $v0, 4
		la $a0, Players
		syscall
		
		li $v0, 1
		move $a0, $s0
		syscall
		
		li $v0, 4
		la $a0, Turn
		syscall
		
		beq $s0, 1, PlayerA
		beq $s0, 2, PlayerB
		PlayerA:
			addi $s0, $s0, 1
			li $v0, 8
			la $a0, InputTurnA
			li $a1, 10
			syscall
			la $t0, BoardB
			la $t1, InputTurnA
			jal CheckTurn
			la $t0, BoardB
			jal CheckBoard
			j Gamestart
		PlayerB:
			subi $s0, $s0, 1
			li $v0, 8
			la $a0, InputTurnB
			li $a1, 10
			syscall
			la $t0, BoardA
			la $t1, InputTurnB
			jal CheckTurn
			la $t0, BoardA
			jal CheckBoard
			j Gamestart
		Gameend:
		j EndProgram

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #	
InitBoard:
    li $t1, 48             # Load zero into $t1 (to store as initial value)
    li $t2, 49            # Load the number of elements in the board (49 for a 7x7 board)
Init_loop:
    sb $t1, ($t0)         # Store zero at the current address in the board
    addi $t0, $t0, 1      # Move to the next element address
    addi $t2, $t2, -1      # Decrement the counter

    bnez $t2, Init_loop
	jr $ra
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
CheckBoard:
	li $t1, 0
	CheckBoardLoop:
	lb $t2, ($t0)
	beq $t2, 49, CheckBoardEnd
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	bne $t1, 49, CheckBoardLoop
	j WinnerPrint
CheckBoardEnd:
	jr $ra
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
ConvertToBoardPositionStart:
	lb $t2, ($t0)
	addi $t0, $t0, 2
	lb $t3, ($t0)
	addi $t0, $t0, 2
	
	li $s0, 0x30
	sub $t2, $t2, $s0
	sub $t3, $t3, $s0
	mul $t2, $t2, 7
	add $t2, $t3, $t2
	sb $t2, ($t1)
	addi $t1, $t1, 1
	lb $t3, ($t0)
	bne $t3, 0, ConvertToBoardPositionStart
	jr $ra
ConvertToBoardPositionEnd:
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
CheckingStringValidStart:
		li $t6, 0	#loop counter for 50 characters string
		li $t7, 0	#counting amount of numbers
		li $t8, 0	#Checking space characters, if >2 then terminate
		CheckingStringValidLoop:
			lb $t1, ($t0)
			beq $t1, 32, CurrentByteIsSpace
			blt $t1, 48, ErrorFormat
			bgt $t1, 54, ErrorFormat
			addi $t7, $t7, 1
			move $t2, $t0
			addi $t2, $t2, 1
			lb $t2, ($t2)
			beq $t2, 10, CheckingStringValidEnd
			bne $t2, 32, ErrorFormat #$t2 checking if the next character next to number is blank or not (Prevent two digit number)
			j CheckingStringValidLooper
			CurrentByteIsSpace:
			beq $t7, 0, ErrorFormat #Case: User typing '              1 2 3 4'
			addi $t8, $t8, 1
			bgt $t8, 23, ErrorFormat
			beq $t7, 24, CheckingStringValidEnd
			
			CheckingStringValidLooper:
			addi $t0, $t0, 1
			addi $t6, $t6, 1
			blt $t6, 50, CheckingStringValidLoop
	CheckingStringValidEnd:
	jr $ra
		
	ErrorFormat:
	# print Error
	la $a0, WrongFormat
	li $v0, 4
	syscall
	j EndProgram
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #	
PutBoatOnBoardA:
	la $s1 InputStringA
	la $s2 BoardA
	la $s3 ConvertedA
	lw $s4 BattleshipA
	lw $s5 CruisersA
	lw $s6 DestroyersA
	
	li $t9, 6 #No. of Ships
	PutBoatOnBoardALoop:
		lb $t1, ($s1)
		addi $s1, $s1, 2
		lb $t2, ($s1)
		addi $s1, $s1, 2
		lb $t3, ($s1)
		addi $s1, $s1, 2
		lb $t4, ($s1)
		addi $s1, $s1, 2
		
		lb $t5, ($s3)
		addi $s3, $s3, 1
		lb $t6, ($s3)
		addi $s3, $s3, 1
		sub $t0, $t5, $t6
		beq $t0, $0, ErrorInvalidBoat
		li $t0, 49
		
		beq $t1, $t3, HorizontalBoatA
		beq $t2, $t4, VerticalBoatA
		j ErrorInvalidBoat
		HorizontalBoatA:
			la $s0, BoardA
			la $s2, BoardA
			add $s0, $s0, $t5
			add $s2, $s2, $t6
			blt $s0, $s2, UserAPutBoatInNormalOrderHorizontalBoatA
			bgt $s0, $s2, UserAPutBoatInReversedOrderHorizontalBoatA
			UserAPutBoatInNormalOrderHorizontalBoatA:
				lb $t8, ($s0)
				beq $t8, 49, ErrorOverlapShip
				sb $t0, ($s0)
				addi $s0, $s0, 1
				ble $s0, $s2, UserAPutBoatInNormalOrderHorizontalBoatA
				sub $t0, $t6, $t5
				j VerticalBoatAEnd
			UserAPutBoatInReversedOrderHorizontalBoatA:
				lb $t8, ($s0)
				beq $t8, 49, ErrorOverlapShip
				sb $t0, ($s2)
				addi $s2, $s2, 1
				ble $s2, $s0, UserAPutBoatInReversedOrderHorizontalBoatA
				sub $t0, $t5, $t6
				j VerticalBoatAEnd
		HorizontalBoatAEnd:
		VerticalBoatA:
			la $s0, BoardA
			la $s2, BoardA
			add $s0, $s0, $t5
			add $s2, $s2, $t6
			blt $s0, $s2, UserAPutBoatInNormalOrderVerticalBoatA
			bgt $s0, $s2, UserAPutBoatInReversedOrderVerticalBoatA
			UserAPutBoatInNormalOrderVerticalBoatA:
				lb $t8, ($s0)
				beq $t8, 49, ErrorOverlapShip
				sb $t0, ($s0)
				addi $s0, $s0, 7
				ble $s0, $s2, UserAPutBoatInNormalOrderVerticalBoatA
				sub $t0, $t6, $t5
				div $t0, $t0, 7
				j VerticalBoatAEnd
			UserAPutBoatInReversedOrderVerticalBoatA:
				lb $t8, ($s0)
				beq $t8, 49, ErrorOverlapShip
				sb $t0, ($s2)
				addi $s2, $s2, 7
				ble $s2, $s0, UserAPutBoatInReversedOrderVerticalBoatA
				sub $t0, $t5, $t6
				div $t0, $t0, 7
				j VerticalBoatAEnd
		VerticalBoatAEnd:
		subi $t9, $t9, 1
		beq $t0, 1, SubtractDestroyersA
		beq $t0, 2, SubtractCruisersA
		beq $t0, 3, SubtractBattleshipsA
		j ErrorInvalidBoat
			SubtractDestroyersA:
				lw $t0, DestroyersA
				beq $t0, 0, ErrorTooManyDestroyers
				subi $t0, $t0, 1
				sw $t0, DestroyersA
				j EndSubtractA
			SubtractCruisersA:
				lw $t0, CruisersA
				beq $t0, 0, ErrorTooManyCruisers
				subi $t0, $t0, 1
				sw $t0, CruisersA
				j EndSubtractA
			SubtractBattleshipsA:
				lw $t0, BattleshipA
				beq $t0, 0, ErrorTooManyBattleships
				subi $t0, $t0, 1
				sw $t0, BattleshipA
				j EndSubtractA
		EndSubtractA:
		bne $t9, $0, PutBoatOnBoardALoop
	PutBoatOnBoardALoopEnd:
PutBoatOnBoardAEnd:
	jr $ra
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #	
PutBoatOnBoardB:
	la $s1 InputStringB
	la $s2 BoardB
	la $s3 ConvertedB
	lw $s4 BattleshipB
	lw $s5 CruisersB
	lw $s6 DestroyersB
	
	li $t9, 6 #No. of Ships
	PutBoatOnBoardBLoop:
		lb $t1, ($s1)
		addi $s1, $s1, 2
		lb $t2, ($s1)
		addi $s1, $s1, 2
		lb $t3, ($s1)
		addi $s1, $s1, 2
		lb $t4, ($s1)
		addi $s1, $s1, 2
		
		lb $t5, ($s3)
		addi $s3, $s3, 1
		lb $t6, ($s3)
		addi $s3, $s3, 1
		sub $t0, $t5, $t6
		beq $t0, $0, ErrorInvalidBoat
		li $t0, 49
		
		beq $t1, $t3, HorizontalBoatB
		beq $t2, $t4, VerticalBoatB
		j ErrorInvalidBoat
		HorizontalBoatB:
			la $s0, BoardB
			la $s2, BoardB
			add $s0, $s0, $t5
			add $s2, $s2, $t6
			blt $s0, $s2, UserBPutBoatInNormalOrderHorizontalBoatB
			bgt $s0, $s2, UserBPutBoatInReversedOrderHorizontalBoatB
			UserBPutBoatInNormalOrderHorizontalBoatB:
				lb $t8, ($s0)
				beq $t8, 49, ErrorOverlapShip
				sb $t0, ($s0)
				addi $s0, $s0, 1
				ble $s0, $s2, UserBPutBoatInNormalOrderHorizontalBoatB
				sub $t0, $t6, $t5
				j VerticalBoatBEnd
			UserBPutBoatInReversedOrderHorizontalBoatB:
				lb $t8, ($s0)
				beq $t8, 49, ErrorOverlapShip
				sb $t0, ($s2)
				addi $s2, $s2, 1
				ble $s2, $s0, UserBPutBoatInReversedOrderHorizontalBoatB
				sub $t0, $t5, $t6
				j VerticalBoatBEnd
		HorizontalBoatBEnd:
		VerticalBoatB:
			la $s0, BoardB
			la $s2, BoardB
			add $s0, $s0, $t5
			add $s2, $s2, $t6
			blt $s0, $s2, UserBPutBoatInNormalOrderVerticalBoatB
			bgt $s0, $s2, UserBPutBoatInReversedOrderVerticalBoatB
			UserBPutBoatInNormalOrderVerticalBoatB:
				lb $t8, ($s0)
				beq $t8, 49, ErrorOverlapShip
				sb $t0, ($s0)
				addi $s0, $s0, 7
				ble $s0, $s2, UserBPutBoatInNormalOrderVerticalBoatB
				sub $t0, $t6, $t5
				div $t0, $t0, 7
				j VerticalBoatBEnd
			UserBPutBoatInReversedOrderVerticalBoatB:
				lb $t8, ($s0)
				beq $t8, 49, ErrorOverlapShip
				sb $t0, ($s2)
				addi $s2, $s2, 7
				ble $s2, $s0, UserBPutBoatInReversedOrderVerticalBoatB
				sub $t0, $t5, $t6
				div $t0, $t0, 7
				j VerticalBoatBEnd
		VerticalBoatBEnd:
		subi $t9, $t9, 1
		beq $t0, 1, SubtractDestroyersB
		beq $t0, 2, SubtractCruisersB
		beq $t0, 3, SubtractBattleshipsB
		j ErrorInvalidBoat
			SubtractDestroyersB:
				lw $t0, DestroyersB
				beq $t0, 0, ErrorTooManyDestroyers
				subi $t0, $t0, 1
				sw $t0, DestroyersB
				j EndSubtractB
			SubtractCruisersB:
				lw $t0, CruisersB
				beq $t0, 0, ErrorTooManyCruisers
				subi $t0, $t0, 1
				sw $t0, CruisersB
				j EndSubtractB
			SubtractBattleshipsB:
				lw $t0, BattleshipB
				beq $t0, 0, ErrorTooManyBattleships
				subi $t0, $t0, 1
				sw $t0, BattleshipB
				j EndSubtractB
		EndSubtractB:
		bne $t9, $0, PutBoatOnBoardBLoop
	PutBoatOnBoardBLoopEnd:
PutBoatOnBoardBEnd:
	jr $ra
# # # # # # # # #
CheckTurn:
		li $t6, 0	#loop counter for 50 characters string
		li $t7, 0	#counting amount of numbers
		li $t8, 0	#Checking space characters, if >2 then terminate
		CheckTurnValidLoop:
			lb $t3, ($t1)
			beq $t3, 32, CurrentByteIsSpaceCheckTurn
			blt $t3, 48, ErrorFormatCheckTurn
			bgt $t3, 54, ErrorFormatCheckTurn
			addi $t7, $t7, 1
			move $t2, $t1
			addi $t2, $t2, 1
			lb $t2, ($t2)
			beq $t2, 10, CheckTurnValidEnd
			bne $t2, 32, ErrorFormatCheckTurn #$t2 checking if the next character next to number is blank or not (Prevent two digit number)
			j CheckTurnValidLooper
			CurrentByteIsSpaceCheckTurn:
			beq $t7, 0, ErrorFormatCheckTurn #Case: User typing '              1 2 3 4'
			addi $t8, $t8, 1
			bgt $t8, 1, ErrorFormatCheckTurn
			beq $t7, 2, CheckTurnValidEnd
			
			CheckTurnValidLooper:
			addi $t1, $t1, 1
			addi $t6, $t6, 1
			blt $t6, 10, CheckTurnValidLoop
	CheckTurnValidEnd:
	beq $s0, 1, ValueInputB
	beq $s0, 2, ValueInputA
	ValueInputA:
		la $t1, InputTurnA
		j ValueInput
	ValueInputB:
	la $t1, InputTurnB
	ValueInput:
		lb $t2, ($t1)
		addi $t1, $t1, 2
		lb $t3, ($t1)
		
		li $t5, 0x30
		sub $t2, $t2, $t5
		sub $t3, $t3, $t5
		mul $t2, $t2, 7
		add $t2, $t3, $t2
		
		add $t0, $t0, $t2
		lb $t2, ($t0)
		beq $t2, 0x31, HIT
		j HITEnd
		HIT:
			la $a0, Hit
			li $v0, 4
			syscall
			li $t2, 48
			sb $t2, ($t0)
		HITEnd:
	
CheckTurnend:
	jr $ra
			
	ErrorFormatCheckTurn:
	# print Error
	la $a0, WrongInputFormat
	li $v0, 4
	syscall
	la $a0, Players
	li $v0, 4
	syscall
	move $a0, $s0
	li $v0, 1
	syscall
	la $a0, Win
	li $v0, 4
	syscall
	j EndProgram
# # # # # # # # #
ErrorInvalidBoat:
	la $a0, InvalidBoat
	li $v0, 4
	syscall
	j EndProgram
ErrorTooManyBattleships:
	la $a0, TooManyBattleships
	li $v0, 4
	syscall
	j EndProgram
ErrorTooManyCruisers:
	la $a0, TooManyCruisers
	li $v0, 4
	syscall
	j EndProgram
ErrorTooManyDestroyers:
	la $a0, TooManyDestroyers
	li $v0, 4
	syscall
	j EndProgram
ErrorOverlapShip:
	la $a0, OverlapShip
	li $v0, 4
	syscall
	j EndProgram
WinnerPrint:
	la $a0, Players
	li $v0, 4
	syscall
	beq $s0, 1, PlayerBWin
	beq $s0, 2, PlayerAWin
	PlayerBWin:
	addi $s0, $s0, 1
	j PrintPlayer
	PlayerAWin:
	subi $s0, $s0, 1
	j PrintPlayer
	PrintPlayer:
	
	move $a0, $s0
	li $v0, 1
	syscall
	la $a0, Win
	li $v0, 4
	syscall
	j EndProgram
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #	
	
	
	
EndProgram:
li $v0, 10
syscall

