FIRST_ACTION MACRO x, y, remainder, result ; (34 * (x ^ 2)) / (y * (x - y)). [y > 0, x <> y]
    LOCAL @@loop_label, @@error, @@exit
    xor ax, ax
    mov ax, 34
    mov bx, x

    xor cx, cx
    mov cx, 2
    @@loop_label:
        imul bx
        jo @@error
        loop @@loop_label 
    
    mov cx, ax ; x = 34 * (x ^ 2)

    mov bx, x
    mov ax, y
    sub bx, ax
    jo @@error

    mov ax, y
    imul bx
    jo @@error
    
    xor dx, dx				
    mov bx, ax
    mov ax, cx

    idiv bx

    mov result, ax
    mov remainder, dx
    jmp @@exit	 	
    @@error:
		mov was_overflow, 1
		WRITING overflowError
    @@exit:
ENDM

SECOND_ACTION MACRO x, y, remainder, result	;( 1 - x ) / ( 1 + x ). [y = 0]
    LOCAL @@loop_label, @@overflow_error, @@exit, @@ax_positive, @@bx_positive, @@loop_negResult, @@zeroDivision_error
    mov bx, x
    add bx, 1
    jo @@overflow_error

    mov ax, x
    neg ax
    add ax, 1
    jo @@overflow_error ; ax=1-x  bx=1+x

    xor cx, cx
    cmp ax, 0
    jg @@ax_positive
        
    inc cx ; ax negative
    neg ax
    @@ax_positive:

    cmp bx, 0
    je @@zeroDivision_error
    jg @@bx_positive
    
    inc cx ; bx negative
    neg bx
    @@bx_positive:

    xor dx, dx
    idiv bx

    @@loop_negResult:
        neg ax
        loop @@loop_negResult
    
    mov result, ax
    mov remainder, dx
    jmp @@exit
    @@overflow_error:
		mov was_overflow, 1
		WRITING overflowError

    @@zeroDivision_error:
        mov was_overflow, 1
		WRITING zeroDivision

    @@exit:
ENDM

THIRD_ACTION MACRO x, y, remainder, result ; (x ^ 2) * (y ^ 2). [y < 0]
    LOCAL @@loop_label, @@error, @@exit
    mov ax, x
    mov bx, x
    imul bx ; x ^ 2
    jo @@error
    mov bx, y
    xor cx, cx
    mov cx, 2
    @@label_loop:
        imul bx
        jo @@error
        loop @@label_loop
    
    mov result, ax
    mov remainder, dx
    jmp @@exit
    @@error:
		mov was_overflow, 1
		WRITING overflowError
    @@exit:
ENDM

WRITE_RESULT_WITH_REMAINDER MACRO resultStr, result, remainderStr, remainder
    WRITING resultStr
    ITOA result
    mov ax, 10
    int 29h
    WRITING remainderStr
    ITOA remainder
ENDM