###################
# CONSTS
###################

.set MAGIC, 0x1badb002                                                         # magic number for computer to know this is bootloader
.set FLAGS, (1<<0 | 1<<1)
.set CHECKSUM, -(MAGIC + FLAGS)

###################
# STUFF
###################

.section .multiboot
	.long MAGIC
	.long FLAGS
	.long CHECKSUM

.section .text
.extern kernelMain                                                             # expect a function called kernelMain
.extern callConstructors
.global boot

###################
# MAIN FUNCTION & STOP
###################

boot:                                                                          # main function for bootloader
	mov $kernel_stack, %esp                                                    # kernel_stack to stack ptr
	
	call callConstructors

	push %eax
	push %ebx

	push %ecx
	push %edx

	call kernelMain                                                            # run the kernel

_stop:                                                                         # trap the CPU
	cli
	hlt
	jmp _stop

###################
# STUFF PART 2
###################

.section .bss
.space 2*1024*1024                                                             # space it out 2MiB to be correct size
kernel_stack:
