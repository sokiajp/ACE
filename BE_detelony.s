    .syntax unified
    .cpu    arm7tdmi
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

.PutWindowTilemap:
    .word 0xAAAAE000
    ldr     r4, addr_PutWindowTilemap
    mov     r7,r15
    b       Trampoline
.CopyBgTilemap:
    movs    r0,#0
    ldr     r4,addr_CopyBgTilemapBufferToVram
    mov     r7,r15
    b       Trampoline

AddTask:
    movs    r1,#8
    .word 0xAAAAE000
    adr     r0,before_InputHandler
    adds    r0,#3
    ldr     r4,addr_CreateTask
    mov     r7,r15
    b       Trampoline

.fillWindow:
    ldrb    r0, [r5, #8]
    movs    r1, #0x11
    ldr     r4, addr_FillWindowPixelBuffer
    mov     r7, pc
    b       Trampoline


InitTextPrint:
.addText1:
    adr     r0, data_color_gray
    movs    r1, #0

    add     r2, pc, #0x67*4
    ldr     r3, data_diff
    adds    r2, r2, r3
    movs    r3, #4
    mov     r7, pc
    b       .addTextMain


.addText2:
    adds    r2, #9
    movs    r3, #0xC
    mov     r7, pc
    b       .addTextMain

.addText3:
    adr     r0, data_color_red
    subs    r2, #9
    movs    r3, #0x14
    mov     r7, pc
    b       .addTextMain

.addText4:
    adds    r2, #9
    .word 0xAAAAE000
    movs    r3, #0x1C
    adr     r7, InitMemory

.addTextMain:
    push    {r0,r1,r2,r7}
    ldr     r4, addr_half_AddTextPrinterParameterized3
    lsls    r4,r4, #1
    ldrb    r0, [r5,#8]
    movs    r1, #0
    movs    r2, #0
    mov     r7,pc
    b       Trampoline
    pop     {r0,r1,r2,r7}
    mov     pc,r7
    
InitMemory:
    movs    r0, #2
    lsls    r0, 0x18
    strb    r0, [r5,#5]
SetAddress:
    str     r0, [r5]
before_InputHandler:
    b       DisplayProcess2

InputHandler:
    push    {r2,r5,r6,r7,r14}
    str     r4,[sp]
    ldr     r3, newAndRepeatedKeys
    .word 0xAAAAE000
    ldrh    r3,[r3]
    ldr     r5, mem_addr
    subs    r1,r3,#2
    bne     ExceptBPressed
.BPressed:
    ldr     r4, sLockFieldControls
    strb    r1,[r4]
    ldr     r4, addr_DestroyTask
    adr     r7, Exit
    
Trampoline:
    adds    r7, #1
    mov     lr, r7
    mov     pc, r4

@ nop
@ Exit:

ExceptBPressed:

    ldrb    r7,[r5,#5]
    cmp     r3,#0
    beq     DisplayProcess
    cmp     r3,#8
    bhi     Exccept_A_SELECT_START_Pressed
    .word   0xAAAAE000
    ldr     r0,[r5]
    cmp     r3,#4
    bhi     ._START_Pressed
    beq     ._SELECT_Pressed
    ldrb    r1,[r5,#4]
    strb    r1,[r0]
    b       DisplayProcessMain
._START_Pressed:
    adds    r0,#2
._SELECT_Pressed:
    subs    r0,#1
    b       SetAddress

Exccept_A_SELECT_START_Pressed:
    cmp     r3,#0x20
    bhi     Except_RIGHT_LEFT_Pressed
    beq     ._LEFT_Pressed
    subs    r0,r7,#4
    beq     ._StoreCursorPosition
    b       ._CursorIsAtAddress
._LEFT_Pressed:
    subs    r0,r7,#1
    bpl     ._StoreCursorPosition
._CursorIsAtAddress:
    adds    r0,#5
._StoreCursorPosition:
    strb    r0,[r5,#5]
    .word   0xAAAAE000
    b       DisplayProcessMain
    
Except_RIGHT_LEFT_Pressed:
    movs    r0,#3
    subs    r1,r0,r7
    bpl     ._CursorIsAtAddress2
    movs    r1,#4
._CursorIsAtAddress2:
    ldrb    r0,[r5,r1]
    cmp     r3,#0x80
    bhi     ._L_R_Pressed
    beq     ._DownPressed
    adds    r0,#2
._DownPressed:
    subs    r0,#1
    b       ._StoreDisplayByte
._L_R_Pressed:
    lsrs    r3,r3,#9
    bne     ._L_Pressed
    adds    r0,#0x20
._L_Pressed:
    subs    r0,#0x10
    .word   0xAAAAE000
._StoreDisplayByte:
    strb    r0,[r5,r1]


DisplayProcess:
    cmp     r7,#4
    beq     DisplayProcessMain
    ldr     r0,[r5]
DisplayProcess2:
    ldrb    r0,[r0]
    strb    r0,[r5,#4]
DisplayProcessMain:
    ldr     r1, data_LinetileID
    adds    r4,r1,#2
    ldr     r0, data_half_vram
    lsls    r0,r0,#1
    adds    r6,r0,#2
    movs    r2,#0x15
    
DisplayVerticalLineLoop:
    strh    r1,[r0]
    strh    r4,[r0,#0x18]
    adds    r0,#0x40
    subs    r2,#1
    bne     Trampoline2
    movs    r7,#0x14

RowLoop:
    ldr     r3,[r5]
    subs    r0,r3,r7
    adds    r0,#0xB
    ldrb    r3,[r5,#5]
    movs    r1,#3
    eors    r3,r1
    cmp     r7,#0xB
    beq     1f
    .word   0xAAAAE000
    movs    r3,#6
1:
    movs    r4,#0x1C
    mov     r1,r15
    b       HexConverter
    adds    r6,#2
    ldrb    r0,[r0]
    cmp     r7,#0xB
    bne     1f
    ldrb    r0,[r5,#4]
1:
    subs    r3,#7
    .word   0xAAAAE000
    movs    r4,#4
    mov     r1,r15
    b       HexConverter
    adds    r6,#0x2A
    subs    r7,#1
    bne     RowLoop
Exit:
    pop     {r4,r5}
    pop     {r6,r7,r15}
    
HexConverter:
    adds    r1,#1
    mov     r14,r1
2:
    movs    r1,r0
    lsrs    r1,r4
    lsls    r1,r1,#0x1C
    lsrs    r1,r1,#0x1C
    cmp     r1,#8
    bmi     1f
    adds    r1,#3
1:
    lsrs    r2,r4,#3
    cmp     r2,r3
    bne     1f
    .word   0xAAAAE000
    adds    r1,#0x16
1:
    adds    r1,#0x9A
    movs    r2,#0xF
    lsls    r2,r2,#0x0C
    adds    r1,r2,r1
    strh    r1,[r6]
    adds    r6,#2
    subs    r4,#4
    bpl     2b
    bx      r14


.align 2

data_color_gray:
    .byte   0x00, 0x02, 0x03, 0x00
data_color_red:
    .byte   0x00, 0x04, 0x05, 0x00


addr_AddWindow8Bit:
    .word   0x08005004
    .word   0xAAAAE000
addr_PutWindowTilemap:
    .word   0x08003F6C
addr_CopyBgTilemapBufferToVram:
    .word   0x080020BC
addr_CreateTask:
    .word   0x08076BB4
mem_addr:
    .word   0x0203D600
    .word   0xAAAAE000
data_half_vram:
    .word   0x03007C11


data_LinetileID:
    .hword  0xE217
Trampoline2:
    b       DisplayVerticalLineLoop

newAndRepeatedKeys:
    .word   0x03003160
sLockFieldControls:
    .word   0x03000F9C
addr_DestroyTask:
    .word   0x8076CA0
addr_FillWindowPixelBuffer:
    .word   0x08004428
addr_half_AddTextPrinterParameterized3:
    .word   0x0409767E  
data_argAddWindow8bit:
    .byte   0x00, 0x12, 0x00, 0x0B, 0x15, 0x0F, 0x8F, 0x00
data_diff:
    .word   0x000080C9

    .end
