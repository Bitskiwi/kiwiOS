org 0x7e00

kernel_main:
	call cls
	mov si, KERNEL_MSG
	call outln
	call in

	jmp $

KERNEL_MSG: db "Kernel :)", 0

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
