; STACK SEGMENT
STSEG SEGMENT PARA STACK "STACK"
	DB 64 DUP (0)
STSEG ENDS

; DATA SEGMENT
DSEG SEGMENT PARA PUBLIC "DATA"
	xStr db "Enter x : $"
	yStr db "Enter y : $"
	resultStr db "Result : $"
	remainderStr db "Reminder of division : $"
	overflowError db "Overflow error", 10, "$"
	zeroDivision db "Zero division", 10, "$"
	xBuffer db 6, ?, 6 dup ('?')
	yBuffer db 6, ?, 6 dup ('?')
	x dw ?
	y dw ?
	result dw ?
	remainder dw ?
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

		; READ X
		lea dx, xStr
		call far ptr WRITING
		lea dx, xBuffer
		call far ptr READING
		mov ax, 10
		int 29h

		; READ Y
		lea dx, yStr
		call far ptr WRITING
		lea dx, yBuffer
		call far ptr READING
		mov ax, 10
		int 29h
	
		lea bx, xBuffer + 2
		call far ptr ATOI
		cmp was_overflow, 1
		je overflow_error_main
		mov x, ax

		lea bx, yBuffer + 2
		call far ptr ATOI
		cmp was_overflow, 1
		je overflow_error_main
		mov y, ax

		cmp y, 0
		jg maybe_first
		je second
		jl third

		maybe_first:
			mov ax, y
			cmp x, ax
			je main_exit
			jmp first

		first:
			call far ptr FIRST_ACTION
			mov remainder, dx
			cmp was_overflow, 1
			je main_exit
			jmp writing_output

		second:
			call far ptr SECOND_ACTION
			mov remainder, dx
			cmp was_overflow, 1
			je main_exit
			jmp writing_output

		third:
			call far ptr THIRD_ACTION
			mov remainder, dx
			cmp was_overflow, 1
			je main_exit
			jmp writing_output

		overflow_error_main:
			mov was_overflow, 1
			xor dx, dx
			lea dx, overflowError
			call far ptr WRITING
			jmp main_exit

		writing_output:
			mov result, ax
			call far ptr WRITE_OUTPUT

		main_exit:
			ret
	MAIN ENDP

	WRITE_OUTPUT PROC FAR
		lea dx, resultStr
		call far ptr WRITING
		mov bx, result
		call far ptr ITOA
		mov ax, 10
		int 29h
		lea dx, remainderStr
		call far ptr WRITING
		mov bx, remainder
		call far ptr ITOA
		ret
	WRITE_OUTPUT ENDP

	FIRST_ACTION PROC FAR	; (34 * (x ^ 2)) / (y * (x - y)). [y > 0, x <> y]
		xor ax, ax
		mov ax, 34
		mov bx, x

		xor cx, cx
		mov cx, 2
		loop_label:
			imul bx
			jo overflow_error_first
			loop loop_label 
		
		mov cx, ax ; x = 34 * (x ^ 2)

		mov bx, x
		mov ax, y
		sub bx, ax
		jo overflow_error_first

		mov ax, y
		imul bx
		jo overflow_error_first
		
		xor dx, dx				
		mov bx, ax
		mov ax, cx

		idiv bx
		jmp exit_first	 	
		overflow_error_first:
			mov was_overflow, 1
			xor dx, dx
			lea dx, overflowError
			call far ptr WRITING
		exit_first:
			ret
	FIRST_ACTION ENDP

	SECOND_ACTION PROC FAR	;( 1 - x ) / ( 1 + x ). [y = 0]
		mov bx, x
		add bx, 1

		jo overflow_error_second
		mov ax, x
		neg ax
		add ax, 1

		jo overflow_error_second ; ax=1-x  bx=1+x

		xor cx, cx
		cmp ax, 0
		jg ax_positive
			
		inc cx ; ax negative
		neg ax
		ax_positive:

		cmp bx, 0
		je zeroDivision_label
		jg bx_positive
		
		inc cx ; bx negative
		neg bx
		bx_positive:

		xor dx, dx
		idiv bx

		cmp cx, 0
		je exit_second

		loop_negResult:
			neg ax
			loop loop_negResult

		jmp exit_second
		overflow_error_second:
			mov was_overflow, 1
			xor dx, dx
			lea dx, overflowError
			call far ptr WRITING

		zeroDivision_label:
			mov was_overflow, 1
			xor dx, dx
			lea dx, zeroDivision
			call far ptr WRITING

		exit_second:
			ret
	SECOND_ACTION ENDP
	
	THIRD_ACTION PROC FAR ; (x ^ 2) * (y ^ 2). [y < 0]
		mov ax, x
		mov bx, x
		imul bx ; x ^ 2
		jo overflow_error_third
		mov bx, y
		xor cx, cx
		mov cx, 2
		label_loop_third:
			imul bx
			jo overflow_error_third
			loop label_loop_third
		jmp exit_third
		overflow_error_third:
			mov was_overflow, 1
			xor dx, dx
			lea dx, overflowError
			call far ptr WRITING
		exit_third:
			ret
	THIRD_ACTION ENDP

	ITOA PROC FAR
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

	ATOI PROC FAR
		xor ax, ax 		; result
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
			jo error
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
			mov was_overflow, 1			
			xor dx, dx
			lea dx, overflowError
			call far ptr WRITING
		exit_atoi:
			ret
	ATOI ENDP

	READING PROC FAR
		mov ah, 10
		int 21h
		ret
	READING ENDP

	WRITING PROC FAR
		mov ah, 9
		int 21h
		ret
	WRITING ENDP
CSEG ENDS
END MAIN