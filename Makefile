MAKE_DIR = $(PWD)

STAGE1_DIR := $(MAKE_DIR)/Bootloader/stage1
STAGE2_DIR := $(MAKE_DIR)/Bootloader/stage2
KERNAL_DIR := $(MAKE_DIR)/Kernal

INC_SRCH_PATH := 
INC_SRCH_PATH += -I$(STAGE1_DIR)
INC_SRCH_PATH += -I$(STAGE2_DIR) 
INC_SRCH_PATH += -I$(KERNAL_DIR)

CFLAGS :=
CFLAGS += $(INC_SRCH_PATH)

export MAKE_DIR CC LD CFLAGS INC_SRCH_PATH
OBJ_DIR = $(MAKE_DIR)/objects
export OBJ_DIR

bootFile = $(MAKE_DIR)/objects/boot1.bin
kernFile = $(MAKE_DIR)/objects/Kernal.bin

all:
	mkdir -p objects
	@$(MAKE) -C $(STAGE1_DIR) -f stage1.mk 
	@$(MAKE) -C $(STAGE2_DIR) -f stage2.mk
	@$(MAKE) -C $(KERNAL_DIR) -f kernal.mk
	$(info Objects Compliled)
	cp $(bootFile) $(MAKE_DIR)/Fox.bin
	dd if=$(kernFile) of=$(MAKE_DIR)/Fox.bin seek=1
	$(info Kernal Built)

.PHONY: clean

clean:
	rm -r objects 
	$(info Objects Removed)
	