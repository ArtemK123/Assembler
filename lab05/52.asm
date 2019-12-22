include m_basic.asm

; STACK SEGMENT
STSEG SEGMENT PARA STACK "STACK"
	DB 64 DUP (0)
STSEG ENDS

; DATA SEGMENT
DSEG SEGMENT PARA PUBLIC "DATA"
	overflowError db "Number is too big. From: -32768 to 32767$"
	startStr db "Enter a number : $"
    inputError db "Number has incorrect chars.", 10, "$"
	bufferSize DB 7		; 6 chars + RETURN
	inputLength DB 0		; number of read chars
	buffer DB 7 DUP('?')	; actual buffer
    was_overflow db 0    
DSEG ENDS

; CODE SEGMENT
CSEG SEGMENT PARA PUBLIC "CODE"
	MAIN PROC FAR
		ASSUME cs: CSEG, ds: DSEG, ss:STSEG
		
		push ds
		xor ax, ax
		push ax
		mov ax, DSEG
		mov ds, ax

		WRITING startStr
		READING bufferSize

		ATOI bufferSize
		cmp was_overflow, 1
        je overflow_error

		add ax, 78
		jo overflow_error
		ITOA ax
		jmp end_main
		overflow_error:
			WRITING overflowError
		end_main:
			ret
	MAIN ENDP
CSEG ENDS
END MAIN