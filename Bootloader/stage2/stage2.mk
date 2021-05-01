boot2.o: Boot2.asm
	nasm Boot2.asm -felf64 -o $(OBJ_DIR)/boot2.o