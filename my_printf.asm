section .note.GNU-stack
extern stdout
extern putc
section .text
global my_printf

my_printf:
    push rbp
    mov rbp, rsp

    sub rsp, 48
    mov [rbp-8],  rsi
    mov [rbp-16], rdx
    mov [rbp-24], rcx
    mov [rbp-32], r8
    mov [rbp-40], r9

    push r12
    push r13
    push r14
    push r15
    push rbx

    mov r12, rdi
    xor r13, r13
    xor r14, r14

    read_string:
    movzx rax, byte [r12 + r13]

    cmp al, 0
    je end_string
    cmp al, '%'
    je verificare_tip

    mov edi, eax
    mov rsi, [rel stdout]
    call putc
    inc r13
    jmp read_string

    verificare_tip:
    inc r13
    movzx rax, byte [r12 + r13]
    inc r13

    cmp r14, 0
    je arg0
    cmp r14, 1
    je arg1
    cmp r14, 2
    je arg2
    cmp r14, 3
    je arg3
    cmp r14, 4
    je arg4

    ; [rbp + (index-5) * 8 + 16]
    mov r15, r14
    sub r15, 5
    imul r15, 8
    add r15, 16
    mov r15, [rbp + r15]
    jmp arg_stiva

    arg0:
    mov r15, [rbp-8]
    jmp arg_stiva
    arg1:

    mov r15, [rbp-16]
    jmp arg_stiva
    arg2:

    mov r15, [rbp-24]
    jmp arg_stiva
    arg3:

    mov r15, [rbp-32]
    jmp arg_stiva
    arg4:

    mov r15, [rbp-40]
    jmp arg_stiva

    arg_stiva:
    inc r14

    cmp al, 'c'
    je print_char
    cmp al, 's'
    je print_string
    cmp al, 'l'
    je print_ulong
    jmp read_string

    print_char:
    mov edi, r15d
    mov rsi, [rel stdout]
    call putc
    jmp read_string

    print_string:
    mov rbx, r15
    print_str_loop:
    movzx edi, byte [rbx]
 
    cmp edi, 0
    je read_string
    mov rsi, [rel stdout]
    call putc
    inc rbx
    jmp print_str_loop

    print_ulong:
    inc r13
    mov rax, r15
    sub rsp, 32
    lea rbx, [rsp+28]

    mov byte [rbx], 0
    mov ecx, 10

    convert_loop:
    xor rdx, rdx
    div rcx
    add dl, '0'
    dec rbx
    mov [rbx], dl
    test rax, rax
    jnz convert_loop

    print_ulong_loop:
    movzx edi, byte [rbx]
    cmp edi, 0
    je print_ulong_done

    mov rsi, [rel stdout]
    call putc
    inc rbx
    jmp print_ulong_loop

    print_ulong_done:
    add rsp, 32
    jmp read_string

    end_string:
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    leave
    ret
