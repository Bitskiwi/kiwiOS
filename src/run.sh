nasm boot.asm -o boot.bin                                    # assemble bootloader

nasm kernel.asm -o kernel.bin                                    # assemble kernel

dd if=/dev/zero of=os.img bs=512 count=2880                  # create os.img
dd if=boot.bin of=os.img bs=512 conv=notrunc                 # put boot.o in os.img
dd if=kernel.bin of=os.img bs=512 seek=1 conv=notrunc        # put kernel.o in os.img

qemu-system-x86_64 os.img -display sdl                       # run it in a VM
