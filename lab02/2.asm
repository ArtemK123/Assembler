; STACK SEGMENT
STSEG SEGMENT PARA STACK "STACK"
	DB 64 DUP (0)
STSEG ENDS

; DATA SEGMENT
DSEG SEGMENT PARA PUBLIC "DATA"
	buffError db "Number is too big. From: -32768 to 32767$"
	startStr db "Enter a number : $"
	inputError db "Number has incorrect chars.", 10, "$"
	bufferSize DB 7		; 6 chars + RETURN
	inputLength DB 0		; number of read chars
	buffer DB 7 DUP('?')	; actual buffer
DSEG ENDS

; CODE SEGMENT

CSEG SEGMENT PARA PUBLIC "CODE"
	
	MAIN PROC FAR
		ASSUME cs: CSEG, ds: DSEG, ss:STSEG
		
		push ds
		xor ax, ax
		PUSH ax
		MOV ax,DSEG
		MOV ds, ax

		xor dx, dx
		lea dx, startStr
		call WRITING

		call READING

		mov al, 10
		int 29h
		
		call ATOI
		jo overflow_error

		add ax, 78
		jo overflow_error
		mov bx, ax
		call ITOA
		jmp end_main
		overflow_error:
			xor dx, dx
			lea dx, buffError
			call WRITING
		end_main:
			ret
	MAIN ENDP
	
	ITOA PROC NEAR
		or bx, bx
		jns positive_number
		xor ax, ax
		mov al, '-'
		int 29h
		neg bx
		positive_number:
			mov ax, bx
			xor cx, cx	; chars number
			mov bx, 10	; diviator
			itoa_loop:
				xor dx, dx	; remainder stores here
				div bx
				add dl, '0'
				push dx
				inc cx
				test ax, ax
				jnz itoa_loop
			output:
				pop ax
				int 29h
				loop output
			ret
		ITOA ENDP


	ATOI PROC NEAR
		xor ax, ax 		; result
		xor bx, bx		; iterator
		lea bx, buffer
		xor cx, cx		; char
		xor di, di		; 10
		mov di, 10
		xor si, si		; sign

		skip_whitespaces:
			mov cl, BYTE PTR [bx]
			cmp cl, 32	; ' '
			je step
			cmp cl , 9	; '\t'
			je step
			jmp sign_check
		step:
			inc bx
			jmp skip_whitespaces
		sign_check:
			cmp cl, 45	; '-'
			je minus
			cmp cl, 43	; '+'
			je plus
			jmp atoi_loop
		minus:
			mov si, 1
			plus:
				inc bx
				jmp atoi_loop
		atoi_loop:
			mov cl, BYTE PTR [bx]
			cmp cl, 48	; '0'
			jl atoi_end
			cmp cl, 57	; '9'
			jg atoi_end
			imul di
			jo error
			sub cl, 48
			add ax, cx
			jo exit_atoi
			inc bx
			jmp atoi_loop
		atoi_end:
			cmp si, 1
			je make_neg
			jmp exit_atoi
		make_neg:
			neg ax
			jmp exit_atoi
		error:
		exit_atoi:
			ret
		ATOI ENDP
	READING PROC NEAR
		lea dx, bufferSize
		mov ah, 10
		int 21h
		ret
	READING ENDP

	WRITING PROC NEAR
		mov ah, 9
		int 21h
		ret
	WRITING ENDP
CSEG ENDS
END MAIN