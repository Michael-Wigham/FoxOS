boot1.bin: Boot1.asm
	nasm Boot1.asm -o $(OBJ_DIR)/boot1.bin