section .note.GNU-stack
extern malloc
extern free
extern memcpy
extern qsort
section .bss
	;
    results     resq 1
	;
    current     resq 1
	;
    n_global    resd 1
	;
    seq_count   resd 1

section .text
global check_langford
global generate_langford_sequences

;int check_langford(int *number, int lenght)
	check_langford:
    push rbp
    mov rbp, rsp
    push r15
    push r14
    push r13
    push r12

    movsxd r8, esi
    mov eax, esi
    cdq
    mov ecx, 2
    idiv ecx

    cmp edx, 0
    jne false_langford
    movsxd r9, eax

    mov r15, 0

	next_check:
    cmp r15, r8
    je check_position
    mov r14, 0
    mov r13, 0
    mov r12d, [rdi + r15*4]

    check_nr_digits:
    cmp r13, r8
    je check_nr_digits_end

    mov ecx, [rdi + r13*4]
    inc r13
    cmp r12d, ecx
    jne check_nr_digits
    inc r14 ; cnt++
    jmp check_nr_digits

	check_nr_digits_end:
    cmp r14, 2
    jne false_langford
    inc r15
    jmp next_check

	check_position:
    mov r10, 1
	for_each_val:
    cmp r10, r9
    jg true_langford

    xor r11, r11
	find_first:
    ; cauta prima aparitie a lui val
    cmp r11, r8
    jge false_langford
    ; r12d = number[i]
    mov r12d, [rdi + r11*4]
    cmp r12d, r10d
    je found_first
    inc r11
    jmp find_first

	found_first:

    mov r13, r11
    add r13, r10
    inc r13

    cmp r13, r8
    jge false_langford

    mov r12d, [rdi + r13*4]
    cmp r12d, r10d
    jne false_langford

    inc r10
    jmp for_each_val

	true_langford:
    mov rax, 1
    jmp end_check

	false_langford:
    xor rax, rax

	end_check:
    pop r12
    pop r13
    pop r14
    pop r15
    leave
    ret


; rdi = a (int**), rsi = b (int**)
	compare:
    push rbp
    mov rbp, rsp

    ; arr1 = *a, arr2 = *b
    mov rdi, [rdi]
    mov rsi, [rsi]

    ; rcx = 2 * n_global
    mov eax, [rel n_global]
    imul eax, 2
    movsxd rcx, eax

    xor r8, r8
	compare_loop:
    cmp r8, rcx
    jge compare_equal

    mov eax, [rdi + r8*4]

    mov edx, [rsi + r8*4]
    cmp eax, edx
    jne compare_done
    inc r8
    jmp compare_loop

	compare_equal:
    xor eax, eax
    leave
    ret

	compare_done:
    sub eax, edx
    leave
    ret

; void backtrack(int val)

	backtrack:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    sub rsp, 8


    mov r12d, edi


    cmp r12d, 0
    je save_seq


    mov r13, [rel current]
    mov r14d, [rel n_global]

    xor r15, r15

	backtrack_loop:
    mov eax, r14d
    imul eax, 2
    sub eax, r12d
    dec eax
    movsxd rax, eax

    cmp r15, rax
    jge backtrack_done

    mov rbx, r15
    add rbx, r12
    inc rbx


    mov eax, [r13 + r15*4]

    cmp eax, 0
    jne backtrack_next


    cmp eax, 0
    jne backtrack_next


    mov [r13 + r15*4], r12d
    mov [r13 + rbx*4], r12d

    mov edi, r12d
    dec edi
    call backtrack


    mov r13, [rel current]
    mov dword [r13 + r15*4], 0
    mov dword [r13 + rbx*4], 0

	backtrack_next:
    inc r15
    jmp backtrack_loop

	backtrack_done:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    leave
    ret

	save_seq:
    mov r13, [rel current]
    mov eax, [rel n_global]

    imul eax, 2

    imul eax, 4
    movsxd rdi, eax
    call malloc
    mov r15, rax

    mov rdi, r15
    mov rsi, r13
    mov eax, [rel n_global]
    imul eax, 2
    imul eax, 4
    movsxd rdx, eax
    call memcpy

    mov rax, [rel results]
    movsxd rcx, dword [rel seq_count]
    mov [rax + rcx*8], r15

    inc dword [rel seq_count]

    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    leave
    ret

; int **generate_langford_sequences(int n, int *seq_num)

	generate_langford_sequences:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    mov r12d, edi
    mov r13, rsi

    mov eax, edi
    cdq

    mov ecx, 4
    idiv ecx
    cmp edx, 1
    je gen_no_sequences

    cmp edx, 2
    je gen_no_sequences


    mov [rel n_global], r12d
    mov dword [rel seq_count], 0

    mov qword [rel current], 0

    mov edi, 8000
    call malloc
    mov [rel results], rax
    mov r14, rax

    mov edi, r12d
    imul edi, 2
    imul edi, 4
    call malloc
    mov [rel current], rax
    mov r15, rax

    mov ecx, r12d
    imul ecx, 2
    xor rbx, rbx

	zero_loop:
    cmp rbx, rcx
    je zero_done
    mov dword [r15 + rbx*4], 0
    inc rbx
    jmp zero_loop

	zero_done:
    mov edi, r12d
    call backtrack

    ; qsort(results, seq_count, sizeof(int*), compare)
    mov rdi, r14
    movsxd rsi, dword [rel seq_count]
    mov rdx, 8
    lea rcx, [rel compare]
    call qsort

    mov eax, [rel seq_count]
    mov [r13], eax

    cmp eax, 0
    je gen_no_sequences

    mov rdi, [rel current]
    call free

    mov rax, r14
    jmp gen_end

	gen_no_sequences:
    mov dword [r13], 0
    mov rdi, [rel current]
    cmp rdi, 0
    je gen_end_null
    call free
	gen_end_null:
    xor rax, rax

	gen_end:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    leave
    ret