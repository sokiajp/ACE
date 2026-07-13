    .syntax unified
    .cpu    arm7tdmi

    VERSION = "LG_SWITCH"

.if VERSION == "LG_V1"
    CONST_AddWindow8Bit = 0x08005004
    CONST_CreateTask = 0x08076BB4
    CONST_newAndRepeatedKeys = 0x03003160
    CONST_sLockFieldControls = 0x03000F9C
    CONST_DestroyTask = 0x8076CA0
    CONST_FillWindowPixelBuffer = 0x08004428
    CONST_half_AddTextPrinterParameterized3 = 0x0409767E
.endif

.if VERSION == "LG_SWITCH"
    CONST_AddWindow8Bit = 0x08004F6C
    CONST_CreateTask = 0x0807A3CC
    CONST_newAndRepeatedKeys = 0x03002310
    CONST_sLockFieldControls = 0x0300109C
    CONST_DestroyTask = 0x0807A4B6
    CONST_FillWindowPixelBuffer = 0x08004390
    CONST_half_AddTextPrinterParameterized3 = 0x04099478
.endif


    .thumb
start:
    push    {r2, r5, r6, r7, lr}
    str     r4,[sp]
InitWindow:
.addWindow:
    adr     r0, data_argAddWindow8bit
    ldr     r4, AddWindow8Bit
    mov     r7, pc
    b       Trampoline
    ldr     r5, mem_addr
    strb    r0, [r5,#8]
.word 0xAAAAE000



.fillWindow:
    movs    r1, #0x11
    ldr     r4, FillWindowPixelBuffer
    mov     r7, pc
    b       Trampoline

AddTask:
    movs    r1,#8
    adr     r0, InputHandler
    adds    r0,#1
    ldr     r4,CreateTask
.word 0xAAAAE000

    mov     r7,r15
    b       Trampoline

.addGrayText:
    adr     r0, data_color_gray
    movs    r1, #0
    subs    r3, r1, #1

    strb    r3, [r0, #24]
    adds    r3, #0xAB
    strb    r3, [r0, #17]
    adr     r2, data_font
    movs    r3, #4
    mov     r7, pc
    b       .addTextMain

.addRedText:
    adr     r0, data_color_red
    movs    r3, #0xC
    adr     r7, InitMemory
    movs    r6, #0


.addTextMain:
    push    {r0,r1,r2,r7}
    ldr     r4, half_AddTextPrinterParameterized3
    lsls    r4,r4, #1

    ldrb    r0, [r5,#8]
    movs    r1, #0
    movs    r2, #0
    mov     r7,pc
    b       Trampoline

    pop     {r0,r1,r2,r7}
    mov     pc,r7
    
InitMemory:
    strb    r6, [r5,#5]
    ldr     r0, data_initial_addr
.word 0xAAAAE000

SetAddress:
    str     r0, [r5]
before_InputHandler:
    b       SetMemValue


InputHandler:
    push    {r2,r5,r6,r7,r14}
    str     r4,[sp]
    ldr     r3, newAndRepeatedKeys
    ldrh    r3,[r3]
    ldr     r5, mem_addr
    

    ldrb    r7,[r5,#5]
    cmp     r3,#8
    blt     Handle_N_A_B_SELECT
    bhi     Handle_HorizontalKey
._START_Pressed:
    ldr     r4, sLockFieldControls
    movs    r1, #0
    strb    r1, [r4]
.word 0xAAAAE000

    ldr     r4, DestroyTask
    adr     r7, Exit
    
Trampoline:
    adds    r7, #1
    mov     lr, r7
    mov     pc, r4

Handle_N_A_B_SELECT:
    cmp     r3,#0
    beq     DisplayProcessMain
    ldr     r0,[r5]
    cmp     r3,#2
    blt     ._A_Pressed
    beq     ._B_Pressed
._SELECT_Pressed:
    str     r0, [sp, #0x10]
    b       Exit

._A_Pressed:
    adds    r0,#2
._B_Pressed:
    subs    r0,#1
    
    b       SetAddress

Handle_HorizontalKey:
    cmp     r3,#0x20
    bhi     Handle_VerticalKey_LRKey
    beq     ._LEFT_Pressed
    subs    r0,r7,#4
    beq     ._StoreCursorPosition
    b       ._CursorIsAtAddress
.word 0xAAAAE000

._LEFT_Pressed:
    subs    r0,r7,#1
    bpl     ._StoreCursorPosition
._CursorIsAtAddress:
    adds    r0,#5
._StoreCursorPosition:
    strb    r0,[r5,#5]
    b       DisplayProcessMain
    
Handle_VerticalKey_LRKey:
    movs    r0,#3
    subs    r1,r0,r7
    bpl     ._CursorIsAtAddress2
    movs    r1,#4
._CursorIsAtAddress2:
    ldrb    r0,[r5,r1]
    cmp     r3,#0x80
    bhi     ._L_R_Pressed

    subs    r3, #0x60
    asrs    r3, #5
    cmp     r1, #4
    bne     1f
    negs    r3,r3
1:
    adds    r0, r0, r3
    b       ._StoreDisplayByte
    

._L_R_Pressed:
    lsrs    r3,r3,#9
.word 0xAAAAE000

    bne     ._L_Pressed
    adds    r0,#0x20
._L_Pressed:
    subs    r0,#0x10

._StoreDisplayByte:
    strb    r0,[r5,r1]

.loadAddrIfCursorIsAtAddr:

    cmp     r7,#4
    beq     1f
    ldr     r0,[r5]

SetMemValue:
    ldrb    r0,[r0]
    strb    r0,[r5,#4]
1:
    ldr     r1,[r5]
    strb    r0,[r1]

try_recordAddr:
    ldr     r0, flag_recordAddr
    cmp     r0, #0
    beq     1f
    adr     r0, data_initial_addr
    str     r1, [r0]
.word 0xAAAAE000
1:

DisplayProcessMain:


    ldr     r1, data_LinetileID
    adds    r3,r1,#1
    adds    r4,r1,#2
    ldr     r0, data_half_vram

    lsls    r0,r0,#1
    adds    r6,r0,#2
    movs    r2,#0x14
    
DisplayVerticalLineLoop:
    strh    r1,[r0]
    strh    r3,[r0,#0x12]
    strh    r4,[r0,#0x18]
    adds    r0,#0x40
    subs    r2,#1
    bne     Trampoline2
    movs    r7,#0x14
.word 0xAAAAE000

RowLoop:
    ldr     r3,[r5]
    subs    r0,r3,r7
    adds    r0,#0xB
    ldrb    r3,[r5,#5]
    movs    r1,#3
    eors    r3,r1
    cmp     r7,#0xB
    beq     1f
    movs    r3,#6
    
1:
    movs    r4,#0x1C
    mov     r1,r15
    b       HexConverter
    adds    r6,#2
    ldrb    r0,[r0]
    cmp     r7,#0xB
    bne     2f

    ldrb    r0,[r5,#4]
2:
    subs    r3,#7
    movs    r4,#4
    
    mov     r1,r15
    b       HexConverter
    adds    r6,#0x2A
.word 0xAAAAE000
    subs    r7,#1
    bne     RowLoop
Exit:
    pop     {r4,r5}
    pop     {r6,r7,r15}

    
HexConverter:
    adds    r1,#1
    mov     r14,r1
3:
    .hword  0x0000
    movs    r1,r0
    lsrs    r1,r4
    lsls    r1,r1,#0x1C
    lsrs    r1,r1,#0x1C
    lsrs    r2,r4,#3
    cmp     r2,r3
    bne     2f
    adds    r1,#0x10
2:
    adds    r1,#0xA0
    movs    r2,#0xF
    lsls    r2,r2,#0x0C
    adds    r1,r2,r1
    strh    r1,[r6]
.word 0xAAAAE000
    
    adds    r6,#2
    subs    r4,#4
    bpl     3b
    bx      r14

.align 2


data_color_gray:
    .byte   0x00, 0x02, 0x03, 0x00
data_color_red:
    .byte   0x00, 0x04, 0x05, 0x00

data_font:
    .byte   0xA1,0xA2,0xA3,0xA4
    .byte   0xA5,0xA6,0xA7,0xA8
    .byte   0xA9,0xA9,0xBB,0xBC
    .byte   0xBD,0xBE,0xBF,0xC0
.word 0xAAAAE000
data_buffer:


data_LinetileID:
    .hword  0xE217
Trampoline2:
    b       DisplayVerticalLineLoop

mem_addr:
    .word   0x0203D600
data_half_vram:
    .word   0x03007C11

data_argAddWindow8bit:
    .byte   0x00, 0x00, 0x00, 0x10, 0x15, 0x0F, 0x90, 0x00

AddWindow8Bit:
    .word   CONST_AddWindow8Bit
CreateTask:
    .word   CONST_CreateTask
.word 0xAAAAE000
    
newAndRepeatedKeys:
    .word   CONST_newAndRepeatedKeys

sLockFieldControls:
    .word   CONST_sLockFieldControls
DestroyTask:
    .word   CONST_DestroyTask
FillWindowPixelBuffer:
    .word   CONST_FillWindowPixelBuffer
half_AddTextPrinterParameterized3:
    .word   CONST_half_AddTextPrinterParameterized3
    
data_initial_addr:
    .word   0x02000000
flag_recordAddr:
    .word   0x00000000
    .end
    