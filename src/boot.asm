ORG 0x7c00                             ; mem offset

main:
	mov ax, 0x9000                     ; set up stack
	mov ss, ax
	mov sp, 0xffff

	mov si, msg_boot                   ; print boot msg
	call print

;	mov ax, 0x8c00                     ; kernel adress
;	mov cx, 0x0002                     ; sector
;	mov dl, 0x80                       ; first hard disk?
;	mov dh, 0x00                       ; head
;	mov bx, 0x0000                     ; cylinder & sector
;	mov ah, 0x02                       ; read sector mode
;	mov al, 0x01                       ; sector count to read
;	int 0x13                           ; read disk
;	jc disk_err                        ; error checking

	jmp 0x8c00                         ; jump to kernel

disk_err:
	mov si, msg_disk_err               ; print disk error message
	call print
	jmp .halt                          ; stop CPU

.halt:
	hlt
	jmp .halt

print:                                 ; print function
	.loop:                             ; loop
		mov ah, 0x0e                   ; set mode
		mov al, [si]                   ; char to print == current char in string
		cmp al, 0                      ; if end of string, break
		je .end
		int 0x10                       ; print al
		inc si                         ; iterate
		jmp .loop                      ; loop
	.end:                              ; end of function
		ret                            ; return to call location

msg_boot: db "KiwiOS bootloader",0     ; define string
msg_disk_err: db "disk :(",0

times 510 - ($ - $$) db 0              ; bootloader size should be 512 bytes
dw 0xAA55                              ; magic bootloader number

after_boot:
