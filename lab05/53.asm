include m_basic.asm
include m_funcs.asm

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
		WRITING xStr
        READING xBuffer

		; READ Y
        WRITING yStr
        READING yBuffer
	
		ATOI xBuffer
        cmp was_overflow, 1
		jne x_good
		EXIT_PROGRAM
		x_good:
		mov x, ax

		ATOI yBuffer
        cmp was_overflow, 1
		jne y_good
		EXIT_PROGRAM
		y_good:
		mov y, ax

		cmp y, 0
		jg maybe_first
		je second
		jl toThird

		maybe_first:
			mov ax, y
			cmp x, ax
			jne first
			EXIT_PROGRAM

		first:
			FIRST_ACTION x, y, remainder, result
            cmp was_overflow, 1
			jne toResultWriting
			EXIT_PROGRAM

		toResultWriting:
			jmp writing_output
		toThird:
			jmp third

		second:
			SECOND_ACTION x, y, remainder, result
			cmp was_overflow, 1
			jne writing_output
			EXIT_PROGRAM

		third:
			THIRD_ACTION x, y, remainder, result
			cmp was_overflow, 1
			jne writing_output
			EXIT_PROGRAM

		writing_output:
			WRITE_RESULT_WITH_REMAINDER resultStr, result, remainderStr, remainder
		main_exit:
			ret
	MAIN ENDP
CSEG ENDS
END MAIN