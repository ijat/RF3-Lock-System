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
		
	START:
		CALL J5ON
		CALL LCD4BIT
		CALL LCDONDISPLAY2
		CALL LCD2LINE
		
		ECOUT MSG
		
		CALL LCDGOLINE2
		
		ECOUT MSG2
	
		CALL DELAY3
		CALL DELAY3
		CALL DELAY3
		CALL DELAY3
	
		CALL LCDCLEAR
		CALL LCDGOLINE1
		CALL LCDONDISPLAY2
		
		ECOUT MSG3
		
		CALL LCDGOLINE2
		CALL LCDONDISPLAY
	
		INT 3
		
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
	MSG		DB	17,'  RF3 Lock System'
	MSG2	DB	16,'   -- ijat.my --'
	MSG3	DB	14,'Enter new pin:'

	
CSEG ENDS
END	START