Kernal.bin: Kernal.o
	ld -Tlink.ld

Kernal.o:
	g++ -Ttext 0x8000 -ffreestanding -mno-red-zone -m64 -c Kernal.cpp -o $(OBJ_DIR)/Kernal.o
	$(info Objects Compliled)
