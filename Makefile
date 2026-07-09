PREFIX  := arm-none-eabi-
AS      := $(PREFIX)as
LD      := $(PREFIX)ld
OBJCOPY := $(PREFIX)objcopy

CPU		:= arm7tdmi

ASFLAGS := -mcpu=$(CPU) -mthumb

SRC_DIR 	:= asm
BUILD_DIR 	:= build


%:
	$(AS) $(ASFLAGS) -o $(BUILD_DIR)/$@.o $(SRC_DIR)/$@.s
	$(OBJCOPY) -O binary $(BUILD_DIR)/$@.o $(BUILD_DIR)/$@.bin
	rm -f $(BUILD_DIR)/$@.o