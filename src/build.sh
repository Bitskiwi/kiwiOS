# Compile assembly files
nasm -f bin boot.asm -o boot.bin
nasm -f bin kernel.asm -o kernel.bin

# Create a disk image
dd if=/dev/zero of=os.img bs=512 count=2880  # Create a 1.44 MB file
dd if=boot.bin of=os.img bs=512 conv=notrunc
dd if=kernel.bin of=os.img bs=512 seek=1 conv=notrunc
