org 0x7C00
bits 16

%define CRLF 0x0D, 0x0A

;
; FAT12 header
;
jmp short start
nop

bdb_oem:                    db 'MSWIN4.1'           ; 8 bytes
bdb_bytes_per_sector:       dw 512
bdb_sectors_per_cluster:    db 1
bdb_reserved_sectors:       dw 1
bdb_fat_count:              db 2
bdb_dir_entries_count:      dw 0E0h
bdb_total_sectors:          dw 2880                 ; 2880 * 512 = 1.44MB
bdb_media_descriptor_type:  db 0F0h                 ; F0 = 3.5" floppy disk
bdb_sectors_per_fat:        dw 9                    ; 9 sectors/fat
bdb_sectors_per_track:      dw 18
bdb_heads:                  dw 2
bdb_hidden_sectors:         dd 0
bdb_large_sector_count:     dd 0

; extended boot record
ebr_drive_number:           db 0                    ; 0x00 floppy, 0x80 hdd, useless
                            db 0
ebr_signature:              db 29h
ebr_volume_id:              db 12h, 34h, 56h, 78h   ; serial
ebr_volume_label:           db 'KIWI OS :) '        ; 11 bytes
ebr_system_id:              db 'FAT12   '           ; 8 bytes

;
; Code goes here
;

start:
    ; setup data segments
    mov ax, 0           ; can't set ds/es directly
    mov ds, ax
    mov es, ax

    ; setup stack
    mov ss, ax
    mov sp, 0x7C00              ; don't overwrite OS (bad idea)

    ; bioses are different we need to be in correct spot
    push es
    push word .after
    retf

.after:

    ; read from floppy dl = drive num
    mov [ebr_drive_number], dl

    ; loading
    mov si, msg_loading
    call puts

    ; read drive params
    push es
    mov ah, 08h
    int 13h
    jc floppy_error
    pop es

    and cl, 0x3F                        ; remove 2bits
    xor ch, ch
    mov [bdb_sectors_per_track], cx     ; sectors

    inc dh
    mov [bdb_heads], dh                 ; heads

    ; root LBA = reserved + fats * sectors/fat
    mov ax, [bdb_sectors_per_fat]
    mov bl, [bdb_fat_count]
    xor bh, bh
    mul bx                              ; ax = fats * fats/sector
    add ax, [bdb_reserved_sectors]      ; ax = root LBA
    push ax

    ; root size = (32 * entries) / (bytes/sector)
    mov ax, [bdb_dir_entries_count]
    shl ax, 5                           ; ax *= 32
    xor dx, dx                          ; dx = 0
    div word [bdb_bytes_per_sector]     ; how many sectors to read

    test dx, dx                         ; if dx != 0, += 1
    jz .root_dir_after
    inc ax                              ; remainder != 0, += 1
                                        ; sector only has a few entries
.root_dir_after:

    ; read root
    mov cl, al                          ; cl = sectors to read = root size
    pop ax                              ; ax = root LBA
    mov dl, [ebr_drive_number]          ; dl still = drive number
    mov bx, buffer                      ; es:bx = buffer
    call disk_read

    ; search for kernel.bin
    xor bx, bx
    mov di, buffer

.search_kernel:
    mov si, file_kernel_bin
    mov cx, 11                          ; compare 11 chars
    push di
    repe cmpsb
    pop di
    je .found_kernel

    add di, 32
    inc bx
    cmp bx, [bdb_dir_entries_count]
    jl .search_kernel

    ; kernel not found
    jmp kernel_not_found_error

.found_kernel:

    ; di adress to entry
    mov ax, [di + 26]
    mov [kernel_cluster], ax

    ; FAT disk -> memory
    mov ax, [bdb_reserved_sectors]
    mov bx, buffer
    mov cl, [bdb_sectors_per_fat]
    mov dl, [ebr_drive_number]
    call disk_read

    ; read kernel
    mov bx, KERNEL_LOAD_SEGMENT
    mov es, bx
    mov bx, KERNEL_LOAD_OFFSET

.load_kernel_loop:

    ; read next cluster
    mov ax, [kernel_cluster]

    add ax, 31                          ; cluster 1 = (kernel_cluster - 2) * sectors/cluster + sector 1
                                        ; sector 1 = reserved + fats + root size = 1 + 18 + 134 = 33
    mov cl, 1
    mov dl, [ebr_drive_number]
    call disk_read

    add bx, [bdb_bytes_per_sector]

    ; location of next cluster
    mov ax, [kernel_cluster]
    mov cx, 3
    mul cx
    mov cx, 2
    div cx
	mov si, buffer
    add si, ax
    mov ax, [ds:si]                     ; read entry from FAT table at index ax

    or dx, dx
    jz .even

.odd:
    shr ax, 4
    jmp .next_cluster_after

.even:
    and ax, 0x0FFF

.next_cluster_after:
    cmp ax, 0x0FF8                      ; end of chain
    jae .read_finish

    mov [kernel_cluster], ax
    jmp .load_kernel_loop

.read_finish:

    ; jump to our kernel
    mov dl, [ebr_drive_number]          ; boot device in dl

    mov ax, KERNEL_LOAD_SEGMENT
    mov ds, ax
    mov es, ax

    jmp KERNEL_LOAD_SEGMENT:KERNEL_LOAD_OFFSET

    jmp wait_key_and_reboot             ; shouldn't happen

    cli                                 ; trap the CPU
    hlt


;;;;;;;;;;;;;;;
; errors
;;;;;;;;;;;;;;;

floppy_error:
    mov si, msg_read_failed
    call puts
    jmp wait_key_and_reboot

kernel_not_found_error:
    mov si, msg_kernel_not_found
    call puts
    jmp wait_key_and_reboot

wait_key_and_reboot:
    mov ah, 0
    int 16h                     ; wait for keypress
    jmp 0FFFFh:0                ; reboot

.halt:
    cli
    hlt

puts:
    ; save registers
    push si
    push ax
    push bx

.loop:
    lodsb               ; loads char
    or al, al           ; next char = 0?
    jz .done

    mov ah, 0x0E
    mov bh, 0
    int 0x10

    jmp .loop

.done:
    pop bx
    pop ax
    pop si
    ret

;
; Disk routines
;

lba_to_chs:
    push ax
    push dx

    xor dx, dx                          ; dx = 0
    div word [bdb_sectors_per_track]    ; ax = LBA / SectorsPerTrack
                                        ; dx = LBA % SectorsPerTrack

    inc dx                              ; dx = (LBA % SectorsPerTrack + 1) = sector
    mov cx, dx                          ; cx = sector

    xor dx, dx                          ; dx = 0
    div word [bdb_heads]                ; ax = (LBA / SectorsPerTrack) / Heads = cylinder
                                        ; dx = (LBA / SectorsPerTrack) % Heads = head
    mov dh, dl                          ; dh = head
    mov ch, al                          ; ch = cylinder (lower 8 bits)
    shl ah, 6
    or cl, ah                           ; put upper 2 bits of cylinder in CL

    pop ax
    mov dl, al                          ; restore DL
    pop ax
    ret

; reads sectors from disk

disk_read:

    push ax                             ; save registers
    push bx
    push cx
    push dx
    push di

    push cx
	call lba_to_chs
    pop ax

    mov ah, 02h
    mov di, 3                           ; retry count

.retry:
    pusha                               ; save all registers
    stc                                 ; set carry flag
    int 13h                             ; success
    jnc .done

    ; read failed
    popa
    call disk_reset

    dec di
    test di, di
    jnz .retry

.fail:
    ; no more retries
    jmp floppy_error

.done:
    popa

    pop di
    pop dx
    pop cx
    pop bx
    pop ax                             ; load registers
    ret

disk_reset:
    pusha
    mov ah, 0
    stc
    int 13h
    jc floppy_error
    popa
    ret


msg_loading:            db 'loading...', CRLF, 0
msg_read_failed:        db 'disk :(', CRLF, 0
msg_kernel_not_found:   db 'kernel :(', CRLF, 0
file_kernel_bin:        db 'KERNEL  BIN'
kernel_cluster:         dw 0

KERNEL_LOAD_SEGMENT     equ 0x2000
KERNEL_LOAD_OFFSET      equ 0


times 510-($-$$) db 0
dw 0AA55h

buffer:
