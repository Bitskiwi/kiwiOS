jmp main

main:
	mov si, msg_welcome
	call print
	jmp .halt

.halt:
	hlt
	jmp .halt

print:
	.loop:
		mov ah, 0x0e                   ; set mode to print
		mov al, [si]                   ; load current char
		cmp al, 0                      ; check end of string (0)
		je .end
		int 0x10
		inc si
		jmp .loop
	.end:
		ret

CR: db 0x0d
LF: db 0x0a
msg_welcome: db "Welcome to KiwiOS!"
