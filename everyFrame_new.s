    .syntax unified
    .cpu    arm7tdmi


    VERSION = "LG_SWITCH"
.if VERSION == "LG_SWITCH"
    CONST_MovementType_Player = 0x0805E474
    CONST_gObjectEvents_movementType = 0x02036D6E
    CONST_heldKeys = 0x0300230C
    CONST_sLockFieldControls = 0x0300109C
    CONST_intrMain_Buffer = 0x03002770
    CONST_gPlayerAvatar = 0x02036FA8
    CONST_SetPlayerAvatarObjectEventIdAndObjectId = 0x080620EC

.endif

.if VERSION == "LG_V1"
    CONST_MovementType_Player = 0x0805AC74
    CONST_gObjectEvents_movementType = 0x02036D72 
    CONST_heldKeys = 0x0300315C
    CONST_sLockFieldControls = 0x03000F9C
    CONST_intrMain_Buffer = 0x030035C0
    CONST_gPlayerAvatar = 0x02036FAC
    CONST_SetPlayerAvatarObjectEventIdAndObjectId = 0x0805E8EC
.endif


.org    0
    .thumb


try_installEveryFrameACE:
    push    {r0}
    ldr     r0, hasInstalled
    ldrb    r1, [r0]
    cmp     r1, #0
    bne     dont_install
    
installEveryFrameACE:
.set_INTR_VECTOR:
    ldr     r0, INTR_VECTOR
    ldr     r1, MyIntr_Buffer
    str     r1, [r0]
.word 0xFFFFE000
.set_hasInstalled:
    ldr     r0, hasInstalled
    movs    r1, #1
    strb    r1, [r0]
.copy2MapBuffer:
    adr     r0, MyIntr
    ldr     r1, MyIntr_Buffer
    adr     r2, copySrc_end
    subs    r2, r2, r0
    lsrs    r2, #1
    swi     #0xB
        @ CpuSet

dont_install:
    pop     {r0}
    ldr     r1, MovementType_Player_thumb
    bx      r1

.hword  0x0000
    @ 実行時の目印

uninstallEveryFrameACE:
    ldr     r0, hasInstalled
.word 0xFFFFE000
    movs    r1, #0
    strb    r1, [r0]

    ldr     r0, gObjectEvents_movementType
    movs    r1, #0x0B
    strb    r1, [r0]

    ldr     r0, gSprite_Player_callback
    ldr     r1, MovementType_Player_thumb
    str     r1, [r0]
    
    ldr     r0, INTR_VECTOR
    ldr     r1, intrMain_Buffer
    str     r1, [r0]

    mov     pc, lr



.org    0x50
MyIntr:
.switch2THUMB:
.arm
    mov     r0, pc
    add     r0, r0, #5
    bx      r0
.thumb
.call_IntrMain_Buffer:
    push    {lr}
    mov     r0, pc
.word 0xFFFFE000
    adds    r0, 5*2+1@#0xB
    mov     lr, r0
    ldr     r0, intrMain_Buffer
    bx      r0
    b       call_BE
2:
    movs    r0, #0x6E
    ldr     r1, gObjectEvents_movementType
    strb    r0, [r1]
    pop     {r0}
    bx      r0

call_BE:
    ldr     r0, heldKeys
    ldrb    r0,[r0, #1]
    cmp     r0, #3
    bne     1f
    ldr     r0, sLockFieldControls
    ldrb    r1, [r0]
    cmp     r1, #0
    bne     1f

    movs    r1, #1
    strb    r1, [r0]

.word 0xFFFFE000
    ldr     r0, func_BE_thumb
    mov     lr, pc
    bx      r0
1:

@ バグ防止
setPlayerID:
    ldr     r2, gPlayerAvatar
    ldrb    r0, [r2]
        @ gPlayerAvatar.flags
    cmp     r0, #0
        @ 6E に設定してるときは 帰還(returun field)時に 21 や 22 ではなく 00 になる
    bne     2b

    ldrb    r0, [r2,#5]
    ldrb    r1, [r2,#4]
    ldr     r2, SetPlayerAvatarObjectEventIdAndObjectId
    mov     r3, pc

    adds    r3, #5
    mov     lr, r3
    mov     pc, r2
    b       2b



    .hword  0x0000
.word 0xFFFFE000

    .align  2
MyIntr_Buffer:
    .word   0x0203C000
INTR_VECTOR:
    .word   0x03007FFC
hasInstalled:
    .word  0x0203D010
gSprite_Player_callback:
    .word   0x020205D4

gObjectEvents_movementType:
    .word   CONST_gObjectEvents_movementType
MovementType_Player_thumb:
    .word   CONST_MovementType_Player + 1
intrMain_Buffer:
    .word   CONST_intrMain_Buffer

heldKeys:
    .word   CONST_heldKeys
sLockFieldControls:
    .word   CONST_sLockFieldControls
func_BE_thumb:
    .word   0x0202924C + 4 + 0x50 * 2 + 1

.word 0xFFFFE000

gPlayerAvatar:
    .word   CONST_gPlayerAvatar
SetPlayerAvatarObjectEventIdAndObjectId:
    .word   CONST_SetPlayerAvatarObjectEventIdAndObjectId


copySrc_end:

    .end


