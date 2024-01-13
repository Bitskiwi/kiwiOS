org 0x7c00
bits 16

%define CR 0x0d
%define LF 0x0a
%define CRLF 0x0d, 0x0a

;
; FAT12 header
;

jmp short start
nop

bdb_oem:                    db 'MSWIN4.1'              ; 8 bytes
bdb_bytes_per_sector:       dw 512
bdb_sectors_per_cluster:    db 1
bdb_reserved_sectors:       dw 1
bdb_fat_count:              db 2
bdb_dir_entries_count:      dw 0e0h
bdb_total_sectors:          dw 2880                    ; 2880 * 512 = 1.44MB
bdb_media_descriptor_type:  db 0f0h                    ; f0 = floppy disk
bdb_sectors_per_fat:        dw 9
bdb_sectors_per_track:      dw 18
bdb_heads:                  dw 2
bdb_hidden_sectors:         dd 0
bdb_large_sector_count:     dd 0

;extended boot record

ebr_drive_number:           db 0                       ; 0x00 floppy 0x80 hdd
                            db 0                       ; reserved
ebr_signiture:              db 29h
ebr_volume_id:              db 12h, 34h, 56h, 78h      ; serial number
ebr_volume_label:           db 'KIWI OS :) '           ; 11 bytes
ebr_system_id:              db 'FAT12   '              ; 8 bytes


start:
	jmp main

; prints to the screen
puts:
	; save registers to modify
	push si
	push ax

.loop:
	lodsb
	or al, al           ; check if al is null
	jz .done            ; jump to .done if null
	
	mov ah, 0x0e        ; set the mode
	mov bh, 0           ; page_num = 0
	int 0x10            ; interupt (video)

	jmp .loop           ; iterate

.done:
	pop ax
	pop si
	ret

; main func
main:
	mov ax, 0 
	mov ds, ax
	mov es, ax

	mov ss, ax
	mov sp, 0x7c00      ; don't overwrite the OS (not a good idea)


	; read from floppy
	mov [ebr_drive_number], dl             

	mov ax, 1           ; LBA = 1
	mov cl, 1           ; 1 sector to read
	mov bx, 0x7e00      ; data after bootloader
	call disk_read

	; print my_str
	mov si, msg_hi      ; params for puts
	call puts           ; call puts	

	cli
	hlt

; errors

floppy_error:
	mov si, msg_read_fail
	call puts
	jmp wait_key_and_reboot

wait_key_and_reboot:
	mov ah, 0
	int 16h             ; press any key to continue
	jmp 0FFFFh:0        ; jump to begin of BIOS (Reboot)

.halt:
	cli                 ; disable interupts (There is no escape)
	hlt

; disk routines

; converts LBA to CHS

lba_to_chs:
	push ax
	push dx

	xor dx, dx                             ; dx = 0
	div word [bdb_sectors_per_track]       ; ax = LBA / SectorsPerTrack
                                           ; dx = LBA % SectorsPerTrack
	inc dx                                 ; dx = (LBA % SectorsPerTrack + 1) = sector
	mov cx, dx                             ; cx = sector

	xor dx, dx                             ; dx = 0
	div word [bdb_heads]                   ; ax = (LBA / SectorsPerTrack) / heads = cylinder
                                           ; dx = (LBA / SectorsPerTrack) % heads = head
	mov dh, dl                             ; dh = head
	mov ch, al                             ; ch = cylinder (lower 8 bits)
	shl ah, 6                              
	or cl, ah  

	pop ax
	mov dl,al
	pop ax
	ret

disk_read:

	push ax             ; save registers to modify
	push bx
	push cx
	push dx
	push di

	push cx
	call lba_to_chs
	pop ax

	mov ah, 02h
	mov di, 3           ; retry count

.retry:
	pusha               ; save all registers
	stc
	int 13h
	jnc .done           ; jump if carry not set

	; failed
	popa
	call disk_reset

	dec di
	test di, di
	jnz .retry

.fail:
	; all attempts failed
	jmp floppy_error

.done:
	popa

	pop di             ; restore registers
	pop dx
	pop cx
	pop bx
	pop ax

	mov si, msg_read_success
	call puts

	ret

disk_reset:
	pusha
	mov ah, 0
	stc
	int 13h
	jc floppy_error
	popa
	ret

msg_hi:                 db 'hello world', CRLF, 0
msg_read_fail:          db 'Failed Disk Read', CRLF, 0
msg_read_success:       db '<Kiwi> I just read from disk yay', CRLF, 0

times 510-($-$$) db 0
db 0x55, 0xaa
