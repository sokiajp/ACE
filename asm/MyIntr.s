    .syntax unified
    .cpu    arm7tdmi
    .thumb

    VERSION = "LG_V1"
.if VERSION == "LG_SWITCH"
    CONST_gObjectEvents_movementType = 0x02036D6E
    CONST_heldKeys = 0x0300230C
    CONST_sLockFieldControls = 0x0300109C
    CONST_intrMain_Buffer = 0x03002770
    @ .equ    CONST_newAndRepeatedKeys, 0x03002310
.endif

.if VERSION == "LG_V1"
    CONST_gObjectEvents_movementType = 0x02036D72
    CONST_heldKeys = 0x0300315C
    CONST_sLockFieldControls = 0x03000F9C
    CONST_intrMain_Buffer = 0x030035C0
.endif

    .org    0    
func_BE:

    .org    0x50 * 9
func_MyIntr:
    .arm
@ BIOS からここに来るときは 必ず arm になる
    mov     r0, pc
    add     r0, r0, #5
    bx      r0
    .thumb
    ldr     r0, heldKeys
    ldrb    r0,[r0, #1]
.word   0xAAAAE000
    cmp     r0, #3
    bne     1f
    ldr     r0, sLockFieldControls
    ldrb    r1, [r0]
    cmp     r1, #1
    beq     1f
    movs    r1, #1
    strb    r1, [r0]
    mov     r4, lr
    bl      func_BE
    mov     lr, r4

1:
    movs    r0, #0x6E 
    ldr     r1, gObjectEvents_movementType
    strb    r0, [r1]
    ldr     r3, intrMain_Buffer
    bx      r3

    .align  2

gObjectEvents_movementType:
    .word   CONST_gObjectEvents_movementType
    .word   0xAAAAE000
heldKeys:
    .word   CONST_heldKeys
sLockFieldControls:
    .word   CONST_sLockFieldControls
intrMain_Buffer:
    .word   CONST_intrMain_Buffer


    .end
