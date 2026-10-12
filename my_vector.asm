section .note.GNU-stack

section .text
extern malloc
global new_vector
global set_element
global get_element
global push_element
global pop_element
global print_vector
global free_vector

;   struct vector {
;       int *arr;
;       int len;
;       int cap;
;   }

struc vector
.arr: resb 8
.len: resb 4
.cap: resb 4
endstruc

    new_vector:
    push rbp
    mov rbp, rsp
    push rbx
    push r12

    mov ebx, edi

    mov rdi, 16
    call malloc
    mov r12, rax

    xor rax, rax
    mov [r12 + vector.arr], rax
    mov dword [r12 + vector.len], 0
    mov dword [r12 + vector.cap], ebx

    test ebx, ebx
    jz done_0

    mov edi, ebx
    imul rdi, 4
    call malloc

    mov [r12 + vector.arr], rax

    done_0:
    mov rax, r12
    pop r12
    pop rbx
    leave
    ret

    set_element:
    push rbp
    mov rbp, rsp
    xor rax, rax

    push r12
    push rbx

    mov eax, [rdi + vector.len]
    test edx, edx
    js invalid_1
    cmp edx, eax
    jae invalid_1

    mov r12, [rdi + vector.arr]
    movsxd rdx, edx
    lea rbx, [r12 + rdx*4]

    mov [rbx], esi

    final_set:
    mov eax, edx
    pop rbx
    pop r12
    leave
    ret

    invalid_1:
    lea rdi, [rel fmt_err_idx]
    mov esi, edx
    xor eax, eax
    call printf

    mov rax, -1
    pop rbx
    pop r12
    leave
    ret

    get_element:
    push rbp
    mov rbp, rsp
    xor rax, rax
    push rbx
    sub rsp, 8

    mov ebx, esi

    test ebx, ebx
    js invalid_2

    mov eax, [rdi + vector.len]
    cmp ebx, eax
    jae invalid_2

    mov rcx, [rdi + vector.arr]
    movsxd rbx, ebx

    mov eax, [rcx + rbx*4]

    add rsp, 8
    pop rbx
    leave
    ret

    invalid_2:
    lea rdi, [rel fmt_err_idx]
    mov esi, ebx
    xor eax, eax
    call printf

    mov rax, -1
    add rsp, 8
    pop rbx
    leave
    ret

    extern realloc

    push_element:
    push rbp
    mov rbp, rsp
    xor rax, rax

    push r12
    push r13

    mov r12, rdi
    mov r13d, esi

    mov eax, [r12 + vector.len]
    cmp eax, [r12 + vector.cap]
    jl push_elem

    resize:
    mov eax, [r12 + vector.cap]
    cmp eax, 0
    jne next

    fix:
    mov eax, 1

    next:
    imul eax, 2
    mov [r12 + vector.cap], eax

    mov rdi, [r12 + vector.arr]
    movsxd rsi, eax
    imul rsi, 4
    call realloc
    mov [r12 + vector.arr], rax

    push_elem:
    mov rcx, [r12 + vector.arr]
    movsxd r10, dword [r12 + vector.len]

    lea r11, [rcx + r10*4]
    mov [r11], r13d

    inc dword [r12 + vector.len]
    mov rax, r10

    pop r13
    pop r12
    leave
    ret

    pop_element:
    push rbp
    mov rbp, rsp
    xor rax, rax

    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    mov r13, [rdi + vector.arr]

    mov eax, [r12 + vector.len]
    cmp eax, 0
    je invalid_3

    sub eax, 1
    mov [r12 + vector.len], eax

    movsxd rcx, eax
    mov r14d, [r13 + rcx*4]

    mov ecx, [r12 + vector.cap]
    shr ecx, 1
    cmp ecx, 1
    jl final

    cmp eax, ecx
    jg final

    realocare:
    mov [r12 + vector.cap], ecx
    mov rdi, r13
    movsxd rsi, ecx
    imul rsi, 4
    call realloc

    mov [r12 + vector.arr], rax
    mov r13, rax

    final:
    mov eax, r14d
    pop r15
    pop r14
    pop r13
    pop r12
    leave
    ret

    invalid_3:
    lea rdi, [rel fmt_err_emp]
    xor eax, eax
    call printf

    mov rax, -1
    pop r15
    pop r14
    pop r13
    pop r12
    leave
    ret

    extern printf

    section .data

    fmt_int db "[%d]", 0
    fmt_empty db "[]", 0
    fmt_start db "v -> {(", 0
    fmt_end db "), %d, %d}", 10, 0
    fmt_err_idx db "Error: len <= %d", 10, 0
    fmt_err_emp db "The vector is empty", 10, 0

    section .text

    print_vector:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    mov r13, [rdi + vector.arr]
    xor r14, r14

    lea rdi, [rel fmt_start]
    xor eax, eax
    call printf

    printare:
    cmp r14d, [r12 + vector.len]
    jge slot_gol
    lea rdi, [rel fmt_int]

    mov esi, [r13 + r14*4]
    xor eax, eax
    call printf
    inc r14
    jmp printare

    slot_gol:
    cmp r14d, [r12 + vector.cap]
    jge done
    lea rdi, [rel fmt_empty]
    xor eax, eax
    call printf
    inc r14
    jmp slot_gol

    done:
    lea rdi, [rel fmt_end]
    mov esi, [r12 + vector.len]
    mov edx, [r12 + vector.cap]
    xor eax, eax
    call printf

    pop r15
    pop r14
    pop r13
    pop r12
    leave
    ret

    extern free

    free_vector:
    push rbp
    mov rbp, rsp
    push r12
    push r13

    mov r12, rdi
    mov r13, [rdi]

    mov rdi, [r13 + vector.arr]
    call free

    mov rdi, r13
    call free

    mov qword [r12], 0

    pop r13
    pop r12
    leave
    ret