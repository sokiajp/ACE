@ 機能
    @ ダメタマゴを移動させても機能するコード
    @ 0~Fの文字コードをbox2,3ではなく内部に持たせる
    @ 最初のアドレスをデータにしたので後から指定可能

    .syntax unified
    .cpu    arm7tdmi

    .equ VERSION, 0
        @ 0: gba v1.0 LG, 1:switch LG


.if VERSION == 0
    .equ    CONST_addr_AddWindow8Bit, 0x08005004
    .equ    CONST_addr_CreateTask, 0x08076BB4
    .equ    CONST_newAndRepeatedKeys, 0x03003160
    .equ    CONST_sLockFieldControls, 0x03000F9C
    .equ    CONST_addr_DestroyTask, 0x8076CA0
    .equ    CONST_addr_FillWindowPixelBuffer, 0x08004428
    .equ    CONST_addr_half_AddTextPrinterParameterized3, 0x0409767E
.endif

.if VERSION == 1
    .equ    CONST_addr_AddWindow8Bit, 0x08004F6C
    .equ    CONST_addr_CreateTask, 0x0807A3CC
    .equ    CONST_newAndRepeatedKeys, 0x03002310
    .equ    CONST_sLockFieldControls, 0x0300109C
    .equ    CONST_addr_DestroyTask, 0x0807A4B6
    .equ    CONST_addr_FillWindowPixelBuffer, 0x08004390
    .equ    CONST_addr_half_AddTextPrinterParameterized3, 0x04099478
.endif


    .thumb
start:
    push    {r2, r5, r6, r7, lr}
    str     r4,[sp]
InitWindow:
.addWindow:
    adr     r0, data_argAddWindow8bit
    ldr     r4, addr_AddWindow8Bit
    add     r7, PC,#0
    b       Trampoline
    ldr     r5, mem_addr
    strb    r0, [r5,#8]
@ 0 1st bad egg
.word 0xAAAAE000


.fillWindow:
    movs    r1, #0x11
    ldr     r4, addr_FillWindowPixelBuffer
    mov     r7, pc
    b       Trampoline

AddTask:
    movs    r1,#8
    adr     r0, InputHandler
    adds    r0,#1
    ldr     r4,addr_CreateTask
@ 0-0 2nd bad egg cands
.word 0xAAAAE000
    mov     r7,r15
    b       Trampoline

InitTextPrint:
.addText1:
    adr     r0, data_color_gray
    movs    r1, #0
@ 0-1 2nd bad egg cands

@ -------- add --------------------------------
    movs    r3, #1
    subs    r3, r1, r3
        @ r3 = 0xFFFFFFFF
    strb    r3, [r0, #20]
    adds    r3, #0xAB
        @ r3 下位1byte: 0xAA
    strb    r3, [r0, #13]
    adr     r2, data_font
@ 0-2 2nd bad egg cands

    movs    r3, #4
        @ y = 4 pixel
    mov     r7, pc
    b       .addTextMain

.addText4:
    adr     r0, data_color_red
    movs    r3, #0xC
    adr     r7, InitMemory
@ 0-3 2nd bad egg cands
@ ---------------------------------------------


.addTextMain:
    push    {r0,r1,r2,r7}
    ldr     r4, addr_half_AddTextPrinterParameterized3
    lsls    r4,r4, #1
    ldrb    r0, [r5,#8]
@ 1 pid
    movs    r1, #0
    movs    r2, #0
    mov     r7,pc
    b       Trampoline
    pop     {r0,r1,r2,r7}
    mov     pc,r7
    
InitMemory:
    ldr     r0, data_initial_addr
    strb    r0, [r5,#5]
@ 1 1st bad egg
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
@ 1-0 2nd bad egg cands
    cmp     r3,#8
    blt     Handle_N_A_B_SELECT
    bhi     Handle_HorizontalKey
._START_Pressed:
    ldr     r4, sLockFieldControls
    movs    r1, #0
    strb    r1, [r4]
@ 1-1 2nd bad egg cands
.word 0xAAAAE000
    ldr     r4, addr_DestroyTask
    adr     r7, Exit
    
Trampoline:
    adds    r7, #1
    mov     lr, r7
@ 1-2 2nd bad egg cands
    mov     pc, r4

Handle_N_A_B_SELECT:
    cmp     r3,#0
    beq     DisplayProcessMain
    ldr     r0,[r5]
    cmp     r3,#2
    blt     ._A_Pressed
@ 1-3 2nd bad egg cands
    beq     ._B_Pressed
._SELECT_Pressed:
    str     r0, [sp, #0x10]
        @ pop で pc = r0 となる
    b       Exit

._A_Pressed:
    adds    r0,#2
@ 2 pid
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
@ 2 1st bad egg
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
@ 2-0 2nd bad egg cands
    movs    r1,#4
._CursorIsAtAddress2:
    ldrb    r0,[r5,r1]
    cmp     r3,#0x80
    bhi     ._L_R_Pressed

    subs    r3, #0x60
    asrs    r3, #5
@ 2-1 2nd bad egg cands
        @ UP:r3=-1, DOWN:r3=-1
    cmp     r1, #4
    bne     1f
    negs    r3,r3
1:
    adds    r0, r0, r3
    b       ._StoreDisplayByte
    

._L_R_Pressed:
    lsrs    r3,r3,#9
@ 2-2 2nd bad egg cands
.word 0xAAAAE000
    bne     ._L_Pressed
    adds    r0,#0x20
._L_Pressed:
    subs    r0,#0x10

._StoreDisplayByte:
    strb    r0,[r5,r1]
@ 2-3 2nd bad egg cands

.loadAddrIfCursorIsAtAddr:

    cmp     r7,#4
    beq     1f
    ldr     r0,[r5]

SetMemValue:
    ldrb    r0,[r0]
@ 3 pid
    @ .word   0xAAAAE000
    strb    r0,[r5,#4]
    
    b       2f
1:
    ldr     r1,[r5]
    strb    r0,[r1]
2:


DisplayProcessMain:


    ldr     r1, data_LinetileID
    adds    r3,r1,#1
    adds    r4,r1,#2
    ldr     r0, data_half_vram
@ 3 1st bad egg
.word 0xAAAAE000
    lsls    r0,r0,#1
    adds    r6,r0,#2
    movs    r2,#0x14
    
DisplayVerticalLineLoop:
    strh    r1,[r0]
    strh    r3,[r0,#0x12]
    strh    r4,[r0,#0x18]
    adds    r0,#0x40
    subs    r2,#1
@ 3-0 2nd bad egg cands
    bne     Trampoline2
    movs    r7,#0x14

RowLoop:
    ldr     r3,[r5]
    subs    r0,r3,r7
    adds    r0,#0xB
    ldrb    r3,[r5,#5]
@ 3-1 2nd bad egg cands
    movs    r1,#3
    eors    r3,r1
    cmp     r7,#0xB
    beq     1f
    movs    r3,#6
    
1:
    movs    r4,#0x1C
@ 3-2 2nd bad egg cands
    mov     r1,r15
    b       HexConverter
    adds    r6,#2
    ldrb    r0,[r0]
    cmp     r7,#0xB
    bne     2f
@ 3-3 2nd bad egg cands
.word 0xAAAAE000
    ldrb    r0,[r5,#4]
2:
    subs    r3,#7
@ 4 pid
    movs    r4,#4
    
    mov     r1,r15
    b       HexConverter
    adds    r6,#0x2A
    subs    r7,#1
    bne     RowLoop

Exit:
    pop     {r4,r5}
    pop     {r6,r7,r15}
@ 4 1st bad egg
.word 0xAAAAE000
    
HexConverter:
    adds    r1,#1
    mov     r14,r1
3:
    .hword  0x0000
        @ nop
    movs    r1,r0
    lsrs    r1,r4
    lsls    r1,r1,#0x1C
    lsrs    r1,r1,#0x1C
    lsrs    r2,r4,#3
@ 4-0 2nd bad egg cands
    cmp     r2,r3
    bne     2f
    adds    r1,#0x10
2:
    adds    r1,#0xA0
    movs    r2,#0xF
    lsls    r2,r2,#0x0C
@ 4-1 2nd bad egg cands
    adds    r1,r2,r1
    strh    r1,[r6]
    
    adds    r6,#2
    subs    r4,#4
    bpl     3b
    bx      r14
@ 4-2 2nd bad egg cands

.align 2

data_LinetileID:
    .hword  0xE217
Trampoline2:
    b       DisplayVerticalLineLoop

data_initial_addr:
    .word   0x02000000

data_color_red:
    .byte   0x00, 0x04, 0x05, 0x00
@ 4-3 2nd bad egg cands
.word 0xAAAAE000
data_color_gray:
    .byte   0x00, 0x02, 0x03, 0x00
@ 5 pid

@ ----- add ---------------------------------------------
data_font:
    .byte   0xA1,0xA2,0xA3,0xA4
    .byte   0xA5,0xA6,0xA7,0xA8
    .byte   0xA9,0xA9,0xBB,0xBC
        @ AA は 0xAAAAE000 になるから AA以外 にする
    .byte   0xBD,0xBE,0xBF,0xC0
data_buffer:
@ 5 1st bad egg
.word 0xAAAAE000
    @ .word   0xAAAAE000
    @ buffer の 1byte目に 0xFF をコードで書く
@ -------------------------------------------------------

mem_addr:
    .word   0x0203D600
data_half_vram:
    .word   0x03007C11
data_argAddWindow8bit:
    .byte   0x00, 0x00, 0x00, 0x10, 0x15, 0x0F, 0x90, 0x00
@ 5-0 2nd bad egg cands

addr_AddWindow8Bit:
    .word   CONST_addr_AddWindow8Bit
addr_CreateTask:
    .word   CONST_addr_CreateTask
    

    
newAndRepeatedKeys:
    .word   CONST_newAndRepeatedKeys
@ 5-1 2nd bad egg cands
.word 0xAAAAE000
sLockFieldControls:
    .word   CONST_sLockFieldControls
addr_DestroyTask:
    .word   CONST_addr_DestroyTask
@ 5-2 2nd bad egg cands
addr_FillWindowPixelBuffer:
    .word   CONST_addr_FillWindowPixelBuffer
addr_half_AddTextPrinterParameterized3:
    .word   CONST_addr_half_AddTextPrinterParameterized3
        @ 使用不可能文字のため半分にしている        

    .end
