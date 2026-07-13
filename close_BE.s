    .syntax unified
    .cpu    arm7tdmi
    .thumb

    VERSION = "LG_SWITCH"
.if VERSION == "LG_SWITCH"
    CONST_ClearStdWindowAndFrame = 0x080FB874
    CONST_RemoveWindow = 0x08003D70
.endif

.if VERSION == "LG_V1"
    CONST_ClearStdWindowAndFrame = 0x080F7FD4
    CONST_RemoveWindow = 0x08003E08
.endif


.org 0x86
ChangeCode:
    adr     r7, CloseBE
Trampoline:
    adds    r7, #1
    mov     lr, r7
    mov     pc, r4


.org 0x50 * 6
CloseBE:
    ldrb    r0, [r5, #8]
    movs    r1, #1
    ldr     r4, ClearStdWindowAndFrame
    mov     r7,pc
    b       Trampoline
    
    ldrb    r0, [r5, #8]
    ldr     r4, RemoveWindow
    adr     r7, 1f
.word   0xFFFFE000
    b       Trampoline
    .hword  0x0000
1:
    pop     {r4,r5,r6,r7,pc}

.hword   0x0000
.align 2
ClearStdWindowAndFrame:
    .word   CONST_ClearStdWindowAndFrame
RemoveWindow:
    .word   CONST_RemoveWindow


