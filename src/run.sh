as --32 boot.s -o boot.o
gcc -m32 -c kernel.c -o kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
gcc -T linker.ld -o kiwiOS.bin -ffreestanding -O2 -nostdlib boot.o kernel.o -lgcc -m32

mkdir -p iso/boot/grub
cp kiwiOS.bin iso/boot/kiwiOS.bin
cp grub.cfg iso/boot/grub/grub.cfg
grub-mkrescue -o kiwiOS.iso iso

qemu-system-i386 -cdrom kiwiOS.iso
