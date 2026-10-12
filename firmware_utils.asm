section .note.GNU-stack
extern printf

section .data
	;
	msg_heavy       db "The number is heavy", 10, 0
	;
	msg_not_heavy   db "The number is not heavy", 10, 0
	;
	fmt_int         db "%d", 10, 0

section .text

global ave
global switch_cases
global heavy
global flat_matrix


; void ave(char *src, char *dest, int n)
	ave:
	push rbp
	mov rbp, rsp
	xor rax, rax
	push rbx
	push r12

	mov r12d, edx
	xor rcx, rcx

	ave_loop:
	movzx eax, byte [rdi + rcx]
	cmp al, 0
	je ave_end

	sub eax, 'A'
	add eax, r12d
	mov ebx, 31
	cdq
	idiv ebx
	add edx, 'A'


	mov byte [rsi + rcx], dl

	inc rcx
	jmp ave_loop

	ave_end:
	mov byte [rsi + rcx], 0
	pop r12
	pop rbx
	leave
	ret


	; void switch_cases(char *src, char *dest)
	switch_cases:
	push rbp
	mov rbp, rsp

	xor rcx, rcx

	switch_loop:
	movzx eax, byte [rdi + rcx]
	cmp al, 0
	je switch_end

	cmp al, 'A'
	jl not_upper
	cmp al, 'Z'
	jg not_upper
	add al, 32
	jmp save_char

	not_upper:
	cmp al, 'a'
	jl not_lower
	cmp al, 'z'
	jg not_lower
	sub al, 32
	jmp save_char

	not_lower:

	save_char:
	mov byte [rsi + rcx], al

	inc rcx
	jmp switch_loop

	switch_end:
	mov byte [rsi + rcx], 0
	leave
	ret

	; void heavy(int number)

	heavy:
	push rbp
	mov rbp, rsp
	push rbx
	sub rsp, 8

	mov ebx, edi

	test ebx, 0x80000000
	jz not_heavy

	mov eax, ebx

	shr eax, 16
	and eax, 0xFF

	mov edx, ebx

	shr edx, 24
	and edx, 0xFF

	shl eax, 8
	or eax, edx 

	cmp eax, 255
	jle not_heavy

	is_heavy:
	lea rdi, [rel msg_heavy]
	xor eax, eax
	call printf
	jmp heavy_end

	not_heavy:
	lea rdi, [rel msg_not_heavy]
	xor eax, eax
	call printf

	heavy_end:
	;
	add rsp, 8
	pop rbx
	leave
	ret

; void flat_matrix(int *mat, int n)

	flat_matrix:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15

	mov r12, rdi 
	mov r13d, esi

	xor r14, r14
	col_loop:
	cmp r14d, r13d
	jge flat_end

	mov eax, [r12 + r14*4]
	mov r15d, eax

	mov rbx, 1
	row_loop:
	cmp ebx, r13d
	jge row_done

	mov eax, ebx
	imul eax, r13d
	add eax, r14d
	movsxd rax, eax
	mov eax, [r12 + rax*4]

	cmp eax, r15d
	jle row_next
	mov r15d, eax

	row_next:
	inc rbx
	jmp row_loop

	row_done:
	lea rdi, [rel fmt_int]
	mov esi, r15d
	xor eax, eax
	call printf

	inc r14
	jmp col_loop

	flat_end:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	leave
	ret