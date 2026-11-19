; P35 Cache Tag Store - generic assembly-style pseudocode
; This is processor-independent pseudocode, NOT executable 8086/ARM code.
;
; Address format:
;   tag   = addr[7:4]
;   index = addr[3:2]  (0..3)
;   offset= addr[1:0]
;
; Memory/register layout:
;   VALID[0..3] : one valid bit per cache line
;   TAG[0..3]   : one 4-bit tag per cache line
;   R_ADDR      : input address
;   R_ACCESS    : access input
;   R_RST       : reset input
;   R_HIT       : output hit

START:
    ; Reset all four valid bits and stored tags
    IF R_RST != 0 GOTO RESET_CACHE

    ; No request means no hit
    IF R_ACCESS == 0 GOTO NO_HIT

    ; Extract index and tag from the 8-bit address
    R_INDEX = (R_ADDR >> 2) AND 00000011b
    R_TAG   = (R_ADDR >> 4) AND 00001111b

    ; Read selected cache line
    R_VALID = VALID[R_INDEX]
    R_OLDTAG = TAG[R_INDEX]

    ; Check valid bit and tag equality
    IF R_VALID == 0 GOTO MISS
    IF R_OLDTAG != R_TAG GOTO MISS

HIT:
    R_HIT = 1
    GOTO END_CYCLE

MISS:
    R_HIT = 0
    ; Write-allocate: store the new tag and mark line valid
    VALID[R_INDEX] = 1
    TAG[R_INDEX] = R_TAG
    GOTO END_CYCLE

NO_HIT:
    R_HIT = 0
    GOTO END_CYCLE

RESET_CACHE:
    VALID[0] = 0
    VALID[1] = 0
    VALID[2] = 0
    VALID[3] = 0
    TAG[0] = 0
    TAG[1] = 0
    TAG[2] = 0
    TAG[3] = 0
    R_HIT = 0

END_CYCLE:
    ; Wait for next clock/request, then return to START
    GOTO START
