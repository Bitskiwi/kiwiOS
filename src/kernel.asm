org 0x7e00                                                                     ; define kernel mem address

kernel_main:                                                                   ; kernel_main label
	call cls                                                                   ; clear screen
	mov si, KERNEL_MSG                                                         ; outln params
	call outln                                                                 ; print KERNEL_MSG
	mov si, HELP                                                               ; outln params
	call outln                                                                 ; print HELP
	mov si, user_cmd
	mov esi, PROMPT
	call cmp_str
	cmp ax, 1
	je message

cmd:                                                                           ; command label
	mov si, PROMPT                                                             ; out params
	call out                                                                   ; print PROMPT

	call cin                                                                   ; get char input
	call cout                                                                  ; print the char from input
	call CRLF                                                                  ; newline

	cmp al, 'm'                                                                ; if in = m
	je message                                                                 ; goto message

	cmp al, 'h'                                                                ; if in = h
	je help                                                                    ; goto help

	cmp al, 'r'                                                                ; if in = r
	je reset                                                                   ; goto reset

	cmp al, 'c'                                                                ; if in = c
	je clear                                                                   ; goto clear

	jmp cmd                                                                    ; if null : loop

message:                                                                       ; message cmd
	mov si, HI                                                                 ; outln params
	call outln                                                                 ; print HI
	jmp cmd                                                                    ; loop to cmd

help:                                                                          ; help cmd
	mov si, HELP                                                               ; outln params
	call outln                                                                 ; print HELP
	jmp cmd                                                                    ; loop to cmd

reset:                                                                         ; reset cmd
	jmp kernel_main                                                            ; goto start of kernel to reset

clear:                                                                         ; clear cmd
	call cls                                                                   ; clear screen
	jmp cmd                                                                    ; loop to cmd

	jmp $                                                                      ; infinite loop

; VARS

KERNEL_MSG: db "x86 real mode Kernel", 0
HELP: db "(m)essage: says hi, (h): says this message, (r): resets, (c): clears screen, (f): fix", 0
HI: db "<kernel> hello user", 0
PROMPT: db "<user> ", 0
user_cmd: db "<user> ", 0

; FUNCTIONS

; CRLF()->

CRLF:                                                                          ; CRLF label
	mov ah, 0x0e                                                               ; set mode
	mov al, 0x0a                                                               ; 10h param
	int 0x10                                                                   ; print carriage return
	mov al, 0x0d                                                               ; 10h param
	int 0x10                                                                   ; print line feed
	.end:                                                                      ; end
		ret                                                                    ; return

; cout(char:al)->

cout:                                                                          ; cout label
	mov ah, 0x0e                                                               ; set mode
	int 0x10                                                                   ; print
	.end:                                                                      ; end
		ret                                                                    ; return

; cout(str:si)->

out:                                                                           ; out label
	.loop:                                                                     ; loop
		mov al, [si]                                                           ; put adress of si in al
		cmp al, 0                                                              ; if al = 0
		je .end                                                                ; jump end
		call cout                                                              ; else print al
		inc si                                                                 ; si++
		jmp .loop                                                              ; jump loop
	.end:                                                                      ; end
		ret                                                                    ; return

; outln(str:si)->

outln:                                                                         ; outln label
	call out                                                                   ; call out
	call CRLF                                                                  ; newline
	.end:                                                                      ; end
		ret                                                                    ; return

; cin()->char:al

cin:                                                                           ; cin label
	mov ah, 0x00                                                               ; set mode
	int 0x16                                                                   ; keyboard interupt al = char
	.end:                                                                      ; end
		ret                                                                    ; return

; in()

in:                                                                            ; in label
	.loop:                                                                     ; loop
		call cin                                                               ; get keypress
		cmp al, 0x0d                                                           ; if al is enter
		je .end                                                                ; jump end
		call cout                                                              ; print al
		jmp .loop                                                              ; jump loop
	.end:                                                                      ; end
		call CRLF                                                              ; CRLF
		ret                                                                    ; return

; cls()->

cls:                                                                           ; cls label
	mov ah, 0x00                                                               ; set mode
	mov al, 0x03                                                               ; screen 80x25 16 colors
	int 0x10                                                                   ; reset video
	.end:                                                                      ; end
		ret                                                                    ; return

; EOS(str:si)->EOS:ax

EOS:                                                                           ; EOS label
	.loop:                                                                     ; loop
		mov ax, [si]                                                           ; put deref si address in ax
		cmp ax, 0                                                              ; if ax is terminating char
		je .end                                                                ; jump end
		inc si                                                                 ; si++
		jmp .loop                                                              ; jump loop
	.end:                                                                      ; end
		ret                                                                    ; return

; cmp_str(str1:si str2:esi)->bool:ax

cmp_str:                                                                       ; cmp_str label
	.loop:                                                                     ; loop
		mov ax, [si]                                                           ; ax = str1
		mov bx, [esi]                                                          ; bx = str2
		cmp ax, bx                                                             ; if ax != bx
		jne .false                                                             ; not match
		cmp ax, 0                                                              ; if both are terminating char
		je .true                                                               ; it's a match
		inc si                                                                 ; si++
		inc esi                                                                ; esi++
		jmp .loop                                                              ; jump loop
	.true:                                                                     ; true
		mov ax, 1                                                              ; 1 = true
		ret                                                                    ; return
	.false:                                                                    ; false
		mov ax, 0                                                              ; 0 = false
		ret                                                                    ; return

; str_append

str_append:                                                                    ; str_append label
	
