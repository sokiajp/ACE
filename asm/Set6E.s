    .syntax unified
    .cpu    arm7tdmi
    .thumb
    
    VERSION = "LG_SWITCH"
.if VERSION == "LG_SWITCH"
    CONST_MovementType_Player_thumb = 0x0805E474 + 1
.endif

.if VERSION == "LG_V1"
    CONST_MovementType_Player_thumb = 0x0805AC74 + 1
.endif

Set6E:
    ldr     r1, INTR_VECTOR
    ldr     r2, absolute_func_MyIntr
    str     r2, [r1]
    ldr     r1, MovementType_Player_thumb
    bx      r1

    .hword  0x0000
    .align  2
INTR_VECTOR:
    .word   0x03007FFC
    .word   0xAAAAE000
absolute_func_MyIntr:
    .word   0x0202924C + 4 + 0x50 * 11
MovementType_Player_thumb:
    .word   CONST_MovementType_Player_thumb

    
    .end
