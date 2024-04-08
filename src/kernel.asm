org 0x7e00

kernel_main:
	mov si, KERNEL_MSG
	call println

	jmp $

KERNEL_MSG: db "Kernel :)", 0

CRLF:
	mov ah, 0x0e
	mov al, 0x0a
	int 0x10
	mov al, 0x0d
	int 0x10
	ret

printc:
	mov ah, 0x0e
	int 0x10
	ret

print:
	.loop:
		mov al, [si]
		cmp al, 0
		je .end
		call printc
		inc si
		jmp .loop
	.end:
		ret

println:
	call print
	call CRLF
	ret

cls:
	mov ah, 0x06
	int 0x10
	ret
