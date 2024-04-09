org 0x7e00

kernel_main:
	call cls
	mov si, KERNEL_MSG
	call outln
	mov si, HELP
	call outln

cmd:
	mov si, PROMPT
	call out

	call cin
	call cout
	call CRLF

	cmp al, 'm'
	je message
	
	cmp al, 'h'
	je help
	
	cmp al, 'r'
	je reset
	
	cmp al, 'c'
	je clear

message:
	mov si, HI
	call outln
	jmp cmd

help:
	mov si, HELP
	call outln
	jmp cmd

reset:
	jmp kernel_main

clear:
	call cls
	jmp cmd


	jmp $

KERNEL_MSG: db "x86 real mode Kernel", 0
HELP: db "(m)essage: says hi, (h): says this message, (r): resets, (c): clears screen", 0
HI: db "<kernel> hello user", 0
PROMPT: db "<user> ", 0 

CRLF:
	pusha
	mov ah, 0x0e
	mov al, 0x0a
	int 0x10
	mov al, 0x0d
	int 0x10
	.end:
		popa
		ret

cout:
	mov ah, 0x0e
	int 0x10
	.end:
		ret

out:
	.loop:
		mov al, [si]
		cmp al, 0
		je .end
		call cout
		inc si
		jmp .loop
	.end:
		ret

outln:
	call out
	call CRLF
	.end:
		ret

cin:
	mov ah, 0x00
	int 0x16
	.end:
		ret

in:
	.loop:
		call cin
		;mov al, [ah]
		cmp al, 10
		je .end
		call cout
		jmp .loop
	.end:
		ret

cls:
	mov ah, 0x00
	mov al, 0x03
	int 0x10
	.end:
		ret
