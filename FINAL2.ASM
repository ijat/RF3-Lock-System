;PREDEFINED MACROs
COUT MACRO string
	XOR ax,ax
	XOR cx,cx
	XOR si,si
	XOR BX,BX
	LEA BX,string
	mov cl,[bx+si]
	CALL LCDOUT
ENDM
ECOUT MACRO string2
	XOR ax,ax
	XOR cx,cx
	XOR si,si
	XOR BX,BX
	LEA BX,string2
	mov cl,[bx+si]
	CALL LCDOUT2
ENDM

CSEG SEGMENT
	ASSUME CS:CSEG,DS:CSEG,SS:CSEG,ES:CSEG
	ORG	2000H
	
	CALL STARTP
		
	STARTP PROC NEAR
	START:
		CALL J5ON
		CALL J4ON
		
		CMP RESTART,1H
		JE KEEPGOING
		MOV RESTART,0H
		CALL LCD4BIT
		
		KEEPGOING:
		CALL LCDONDISPLAY2
		CALL LCD2LINE
		CALL LCDCLEAR
		
		;ON LED GREEN + RED
		MOV LEDSTATE,3h
		CALL LEDON
		
		;SPIN SERVO MOTOR TO NEUTRAL
		CALL SERVONEUTRAL
		
		CMP PINSTATE,0H
		JNE NONEEDNEWPIN
		
		;GET NEW PIN
		ECOUT MSG
		
		CALL LCDGOLINE2
		
		ECOUT MSG2
	
		CALL DELAY3
		CALL DELAY3
	
		CALL LCDCLEAR
		CALL LCDGOLINE1
		CALL LCDONDISPLAY2
		
		ECOUT MSG3
		
		CALL LCDGOLINE2
		CALL LCDONDISPLAY
		
		MOV LEDSTATE,2h
		CALL LEDON

		PUSH CX
		XOR CX,CX
		XOR SI,SI
		MOV CL,4H
		LEA BX,CHAR
		MOV SI,1
		
		MORE:
			CALL KEYIN
			CALL DELAYNTL
			MOV [BX+SI],AH
			INC SI
		LOOP MORE
		POP CX
		MOV PINSTATE,1H
		
		NONEEDNEWPIN:
		CALL SERVOSPIN
		
		;CALL J5ON
		CALL LCDCLEAR
		ECOUT MSG4
		CALL LCDGOLINE2
		ECOUT MSG5
		
		MOV LEDSTATE,1h
		CALL LEDON
		
		SECPIN:
		PUSH CX
		XOR CX,CX
		XOR SI,SI
		MOV CL,4H
		LEA BX,TCHAR
		MOV SI,1
		MORE2:
			CALL KEYIN
			CALL DELAYNTL
			MOV [BX+SI],AH
			INC SI
		LOOP MORE2
		POP CX
		
		;COMPARE
		PUSH CX
		XOR CX,CX
		XOR SI,SI
		XOR DX,DX
		INC SI
		MOV CL,4H
		COMPARE:
			LEA BX,CHAR
			MOV AH,[BX+SI]
			LEA BX,TCHAR
			MOV AL,[BX+SI]
			INC SI
			CMP AH,AL
			JE INCDX
		LOOP COMPARE
		JMP LCMP
		INCDX:
			INC DL
		LOOP COMPARE
		LCMP:
			POP CX
			CMP DL,4H
			JE RPIN
			JNE WPIN
		RPIN:
			CALL SERVONEUTRAL
			CALL LCDONDISPLAY2
			CALL LCDCLEAR
			COUT MSG6
			CALL LCDGOLINE2
			COUT MSG7
			
			MOV LEDSTATE,2h
			CALL LEDON
			
			JMP CODEND
		WPIN:
			CALL LCDCLEAR
			CALL LCDONDISPLAY2
			COUT MSG8
			CALL LCDGOLINE2
			COUT MSG9
			
			CALL DELAYL
			CALL DELAYL
			
			CALL LCDONDISPLAY
			CALL LCDCLEAR
			COUT MSG4
			CALL LCDGOLINE2
			COUT MSG5
			
			MOV LEDSTATE,1h
			CALL LEDON
			
			JMP SECPIN
		
		CODEND:
		INT 3
	STARTP ENDP
	
	LEDON PROC NEAR
		MOV DX,J5C
		MOV AL,LEDSTATE
		OUT DX,AL
		RET
	LEDON ENDP
	
	;// SERVO FUNCTIONS
	SERVOSPIN PROC NEAR
		PUSH CX
		XOR CX,CX
		MOV CX,50
		RSPIN:
			MOV DX,0FFE3H
			MOV AL,1H
			OUT DX,AL
			CALL DELAY2MS
			MOV DX,0FFE3H
			MOV AL,0H
			OUT DX,AL
			CALL DELAY20MS
			LOOP RSPIN
		POP CX
		RET
	SERVOSPIN ENDP
	SERVONEUTRAL PROC NEAR
		PUSH CX
		XOR CX,CX
		MOV CX,50
		NEUTRAL:
			MOV DX,0FFE3H
			MOV AL,1H
			OUT DX,AL
			CALL DELAY1P5MS
			MOV DX,0FFE3H
			MOV AL,0H
			OUT DX,AL
			CALL DELAY20MS
			LOOP NEUTRAL
		POP CX
		RET
	SERVONEUTRAL ENDP
	DELAY1P5MS PROC near				
		PUSH CX
		XOR CX,CX
		
		MOV CX,226H
		DELAY2000:
		LOOP DELAY2000
		
		POP CX
		RET
	DELAY1P5MS ENDP
	DELAY2MS PROC near					
		PUSH CX
		XOR CX,CX
		
		MOV CX,100H
		DELAY3000:
		LOOP DELAY3000
		
		POP CX
		RET
	DELAY2MS ENDP
	DELAY20MS PROC near					
		PUSH CX
		XOR CX,CX
		
		MOV CX,198CH
		DELAY1000:
		LOOP DELAY1000
		
		POP CX
		RET
	DELAY20MS ENDP
	;END OF SERVO FUNCTIONS
	
	OUTCHAR PROC NEAR
		;CALL J5ON
		MOV DX,J5A
		
			mov al,ah				;put in al for operations
			and al,0f0h				;empty the lower byte of al
			add al,3h				;add 2 for 'enabled' in LCD
			OUT DX,AL
			CALL DELAY
			sub al,3h				;minus 2 for 'disabled' in LCD
			OUT DX,AL
			CALL DELAY
			
			mov al,ah				
			and al,0fh				;empty the higher byte of al
			push cx					;save cx data in stack
			xor cx,cx				;empty cx
			mov cl,04h				;set cl to 4 times -- used in rotate
			rol al,cl				;rotate al 4 times to left, to bring the lower byte of al to higher byte
			add al,3h				;same
			OUT DX,AL
			CALL DELAY
			sub al,3h				;same
			OUT DX,AL
			CALL DELAY
			pop cx					;push back cx value
		
		RET
	OUTCHAR ENDP
	
	EBTNP PROC NEAR
		MOV DX,J4B
		IN AL,DX
		CMP AL,3h
		JE BTNPNEXT
		RET
		
		BTNPNEXT:
		MOV RESTART,1H
		MOV PINSTATE,0H
		CALL STARTP
	EBTNP ENDP
	
	KEYIN PROC NEAR
		;PUSH BX
		LOAD:
			;CALL J4ON
			MOV DX,J4C
						
			;ROW 1
			MOV AL,10H				;AL = 1X
			OUT DX,AL
			;XOR AL,AL
			IN AL,DX
			CMP AL,11H				;ROW1, COL1
			JE B1					;A PRESSED
			CMP AL,12H				;ROW1, COL2
			JE B2
			CMP AL,14H				;ROW1, COL3
			JE B3
			CMP AL,18H				;ROW1, COL4
			JE BA
			
			;ROW 2
			MOV AL,20H				;AL = 1X
			OUT DX,AL
			;XOR AL,AL
			IN AL,DX
			CMP AL,21H				;ROW1, COL1
			JE B4					;A PRESSED
			CMP AL,22H				;ROW1, COL2
			JE B5
			CMP AL,24H				;ROW1, COL3
			JE B6
			CMP AL,28H				;ROW1, COL4
			JE BB
			
			;ROW 3
			MOV AL,40H				;AL = 1X
			OUT DX,AL
			;XOR AL,AL
			IN AL,DX
			CMP AL,41H				;ROW1, COL1
			JE B7					;A PRESSED
			CMP AL,42H				;ROW1, COL2
			JE B8
			CMP AL,44H				;ROW1, COL3
			JE B9
			CMP AL,48H				;ROW1, COL4
			JE BC
			
			;ROW 4
			MOV AL,80H				;AL = 1X
			OUT DX,AL
			IN AL,DX
			CMP AL,81H				;ROW1, COL1
			JE BSTAR					;A PRESSED
			CMP AL,82H				;ROW1, COL2
			JE B0
			CMP AL,84H				;ROW1, COL3
			JE BHASH
			CMP AL,88H				;ROW1, COL4
			JE BD
			
			;EBUTTON
			CALL EBTNP
			
			JMP LOAD
		
		B1:
			MOV AH,'1'
			CALL OUTCHAR
			JMP THEEND

		B2:
			MOV AH,'2'
			CALL OUTCHAR
			JMP THEEND
		B3:
			MOV AH,'3'
			CALL OUTCHAR
			JMP THEEND
		BA:
			MOV AH,'A'
			CALL OUTCHAR
			JMP THEEND
		B4:
			MOV AH,'4'
			CALL OUTCHAR
			JMP THEEND
		B5:
			MOV AH,'5'
			CALL OUTCHAR
			JMP THEEND
		B6:
			MOV AH,'6'
			CALL OUTCHAR
			JMP THEEND
		BB:
			MOV AH,'B'
			CALL OUTCHAR
			JMP THEEND
		B7:
			MOV AH,'7'
			CALL OUTCHAR
			JMP THEEND
		B8:
			MOV AH,'8'
			CALL OUTCHAR
			JMP THEEND
		B9:
			MOV AH,'9'
			CALL OUTCHAR
			JMP THEEND
		BC:
			MOV AH,'C'
			CALL OUTCHAR
			JMP THEEND
		BSTAR:
			MOV AH,'*'
			CALL OUTCHAR
			JMP THEEND
		B0:
			MOV AH,'0'
			CALL OUTCHAR
			JMP THEEND
		BHASH:
			MOV AH,'#'
			CALL OUTCHAR
			JMP THEEND
		BD:
			MOV AH,'D'
			CALL OUTCHAR
			JMP THEEND
			
		THEEND:
			RET
	KEYIN ENDP
		
	J4ON PROC NEAR
		MOV DX,J4
		MOV AL,93H
		OUT DX,AL
		RET
	J4ON ENDP
		
	LCDOUT PROC NEAR				;Print out to LCD instantly
		MOV DX,J5A
		GO:
			inc si
			mov ah,[bx+si]			;main hex code for characters
			mov al,ah				;put in al for operations
			and al,0f0h				;empty the lower byte of al
			add al,3h				;add 2 for 'enabled' in LCD
			OUT DX,AL
			CALL DELAY
			sub al,3h				;minus 2 for 'disabled' in LCD
			OUT DX,AL
			CALL DELAY
			
			mov al,ah				
			and al,0fh				;empty the higher byte of al
			push cx					;save cx data in stack
			xor cx,cx				;empty cx
			mov cl,04h				;set cl to 4 times -- used in rotate
			rol al,cl				;rotate al 4 times to left, to bring the lower byte of al to higher byte
			add al,3h				;same
			OUT DX,AL
			CALL DELAY
			sub al,3h				;same
			OUT DX,AL
			CALL DELAY
			pop cx					;push back cx value
		loop GO
		RET
	LCDOUT ENDP
	
	LCDOUT2 PROC NEAR				;Print out in LCD with slow fade effect (delay)
		MOV DX,J5A
		GO2:
			inc si
			mov ah,[bx+si]			;main hex code for characters
			mov al,ah				;put in al for operations
			and al,0f0h				;empty the lower byte of al
			add al,3h				;add 2 for 'enabled' in LCD
			OUT DX,AL
			CALL DELAY2
			sub al,3h				;minus 2 for 'disabled' in LCD
			OUT DX,AL
			CALL DELAY2
			
			mov al,ah				
			and al,0fh				;empty the higher byte of al
			push cx					;save cx data in stack
			xor cx,cx				;empty cx
			mov cl,04h				;set cl to 4 times -- used in rotate
			rol al,cl				;rotate al 4 times to left, to bring the lower byte of al to higher byte
			add al,3h				;same
			OUT DX,AL
			CALL DELAY2
			sub al,3h				;same
			OUT DX,AL
			CALL DELAY2
			pop cx					;push back cx value
		loop GO2
		RET
	LCDOUT2 ENDP
	
	LCDCLEAR PROC NEAR
		MOV DX,J5A
		MOV AL,02H
		OUT DX,AL
		CALL DELAY
		MOV AL,00H
		OUT DX,AL
		CALL DELAY
		MOV AL,12H
		OUT DX,AL
		CALL DELAY
		MOV AL,10H
		OUT DX,AL
		CALL DELAY2
		RET
	LCDCLEAR ENDP
	
	LCDGOLINE1 PROC NEAR
		CALL DELAY2
		MOV DX,J5A
		MOV AL,82H
		OUT DX,AL
		CALL DELAY
		MOV AL,80H
		OUT DX,AL
		CALL DELAY	
		MOV AL,02H
		OUT DX,AL
		CALL DELAY
		MOV AL,00H
		OUT DX,AL
		CALL DELAY
		RET
	LCDGOLINE1 ENDP
	
	LCD2LINE PROC NEAR
		MOV DX,J5A
		MOV AL,22H
		OUT DX,AL
		CALL DELAY
		MOV AL,20H
		OUT DX,AL
		CALL DELAY
		MOV AL,82H
		OUT DX,AL
		CALL DELAY
		MOV AL,80H
		OUT DX,AL
		CALL DELAY
		RET
	LCD2LINE ENDP
	
	LCDGOLINE2 PROC NEAR
		CALL DELAY
		MOV DX,J5A
		MOV AL,0C2H
		OUT DX,AL
		CALL DELAY
		MOV AL,0C0H
		OUT DX,AL
		CALL DELAY
		MOV AL,02H
		OUT DX,AL
		CALL DELAY
		MOV AL,00H
		OUT DX,AL
		CALL DELAY
		RET
	LCDGOLINE2 ENDP
		
	LCD4BIT PROC NEAR
		MOV DX,J5A			;Set port j5 a
		MOV AL,22H			;4BIT ON (No need lower nibble)
		OUT DX,AL
		CALL DELAY
		MOV AL,20H
		OUT DX,AL
		CALL DELAY
		RET
	LCD4BIT ENDP
	
	LCDONDISPLAY PROC NEAR
		MOV DX,J5A			;Set port j5 a
		MOV AL,02H
		OUT DX,AL
		CALL DELAY
		MOV AL,00H
		OUT DX,AL
		CALL DELAY
		MOV AL,0F2H
		OUT DX,AL
		CALL DELAY
		MOV AL,0F0H
		OUT DX,AL
		CALL DELAY
		RET
	LCDONDISPLAY ENDP
	
	LCDONDISPLAY2 PROC NEAR
		MOV DX,J5A			;Set port j5 a
		MOV AL,02H
		OUT DX,AL
		CALL DELAY
		MOV AL,00H
		OUT DX,AL
		CALL DELAY
		MOV AL,0C2H
		OUT DX,AL
		CALL DELAY
		MOV AL,0C0H
		OUT DX,AL
		CALL DELAY
		RET
	LCDONDISPLAY2 ENDP

	J5ON PROC NEAR
		MOV DX,J5
		MOV AL,80H
		OUT DX,AL
		RET
	J5ON ENDP
	
	DELAY PROC near
		PUSH CX
		XOR CX,CX
		MOV CX,0FH
		DELAYA:
		LOOP DELAYA
		POP CX
		RET
	DELAY ENDP
	
	DELAY2 PROC near
		PUSH CX
		XOR CX,CX
		MOV CX,0FFFH
		DELAYB:
		LOOP DELAYB
		POP CX
		RET
	DELAY2 ENDP
	
	DELAY3 PROC near ;DELAY 1S
		PUSH CX
		XOR CX,CX
		MOV CX,0FFFFH
		DELAYC:
		LOOP DELAYC
		MOV CX,0FFFFH
		DELAYD:
		LOOP DELAYD
		MOV CX,0FFFFH
		DELAYE:
		LOOP DELAYE
		MOV CX,0FFFFH
		DELAYF:
		LOOP DELAYF
		POP CX
		RET
	DELAY3 ENDP
	
	DELAYL PROC near					;DELAY 1S
		PUSH CX
		XOR CX,CX
		
		MOV CX,0FFFFH
		DELAYA00:
		LOOP DELAYA00
		
		MOV CX,0FFFFH
		DELAYB00:
		LOOP DELAYB00
		
		MOV CX,0FFFFH
		DELAYC00:
		LOOP DELAYC00
		
		MOV CX,0FFFFH
		DELAYD00:
		LOOP DELAYD00
		
		MOV CX,0FFFFH
		DELAYE00:
		LOOP DELAYE00
		
		POP CX
		RET
	DELAYL ENDP
	DELAYNTL PROC near					;DELAY 1S
		PUSH CX
		XOR CX,CX
		
		MOV CX,0FFFFH
		DELAYA01:
		LOOP DELAYA01
		
		MOV CX,0FFFFH
		DELAYB01:
		LOOP DELAYB01
		
		POP CX
		RET
	DELAYNTL ENDP
	
	; DATA & CONSTANTS
	J5	DW	0FFE7H
	J5A	DW	0FFE1H
	J5B	DW	0FFE3H
	J5C	DW	0FFE5H
	
	J4	DW	0FFE6H
	J4A	DW	0FFE0H
	J4B	DW	0FFE2H
	J4C	DW	0FFE4H
	
	;Strings
	MSG			DB	17,'  RF3 Lock System'
	MSG2		DB	16,'   -- ijat.my --'
	MSG3		DB	14,'Enter new pin:'
	MSG4		DB	7,'LOCKED!'
	MSG5		DB	5,'PIN: '
	MSG6		DB	12,'PIN CORRECT!'
	MSG7		DB	17,'   ** THE END! **'
	MSG8		DB	10,'WRONG PIN!'
	MSG9		DB	20,'Please try again. ;)'
	CHAR		DB	4,'    '
	TCHAR		DB	4,'    '
	LEDSTATE	DB	0H
	RESTART		DB	0H
	PINSTATE	DB	0H

	
CSEG ENDS
END	START