section .note.GNU-stack
extern atoi
extern scanf
extern printf

section .data
;
    fmt_str db "%s", 0
    fmt_out db "%d", 10, 0 ; "%d\n"

section .bss
;
    buffer resb 64
;
    stack resq 128
section .text

global reverse_polish_notation

reverse_polish_notation:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    lea r15, [rel stack]
    xor r14, r14

	loop:
    lea rdi, [rel fmt_str]
    lea rsi, [rel buffer]
    xor eax, eax
    call scanf

    cmp eax, -1
    je done

    movzx eax, byte [buffer]
    cmp eax, '0'
    jl este_operator
    cmp eax, '9'
    jg este_operator

	este_numar:
    lea rdi, [rel buffer]
    call atoi

    mov [r15 + r14*8], rax
    inc r14
    jmp loop

	este_operator:
    dec r14
    mov r12, [r15 + r14*8]
    dec r14
    mov r13, [r15 + r14*8]

    cmp byte [buffer], '+'
    je adunare
    cmp byte [buffer], '*'
    je inmultire
    cmp byte [buffer], '-'
    je scadere
    cmp byte [buffer], '/'
    je impartire

	adunare:
    add r13, r12
    
    mov [r15 + r14*8], r13
    inc r14
    jmp loop

	scadere:
    sub r13, r12

    mov [r15 + r14*8], r13
    inc r14
    jmp loop

	inmultire:
    imul r13, r12

    mov [r15 + r14*8], r13
    inc r14
    jmp loop

	impartire:
    mov rax, r13
    cqo 
    idiv r12
    
    mov [r15 + r14*8], rax
    inc r14
    jmp loop

	done:

    dec r14
    mov esi, [r15 + r14*8]
    lea rdi, [rel fmt_out]
    xor eax, eax
    call printf
    pop r15
    pop r14
    pop r13
    pop r12
    leave
    ret
