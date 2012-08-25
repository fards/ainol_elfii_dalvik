    /*
     * Signed 64-bit integer multiply.
     *
     * For JIT: op1 in r0/r1, op2 in r2/r3, return in r0/r1
     *
     * Consider WXxYZ (r1r0 x r3r2) with a long multiply:
     *        WX
     *      x YZ
     *  --------
     *     ZW ZX
     *  YW YX
     *
     * The low word of the result holds ZX, the high word holds
     * (ZW+YX) + (the high overflow from ZX).  YW doesn't matter because
     * it doesn't fit in the low 64 bits.
     *
     * Unlike most ARM math operations, multiply instructions have
     * restrictions on using the same register more than once (Rd and Rm
     * cannot be the same).
     */
    /* mul-long vAA, vBB, vCC */
#if 0                                                                       // cycles
    mul     ip, r2, r1                  @  ip<- ZxW                         // 2
    umull   r9, r10, r2, r0             @  r9/r10 <- ZxX                    // 3
    mla     r2, r0, r3, ip              @  r2<- YxX + (ZxW)                 // 2
    add     r10, r2, r10                @  r10<- r10 + low(ZxW + (YxX))     // 3, r2 interlock
    mov     r0,r9                                                           // 1
    mov     r1,r10                                                          // 1
    bx      lr
#else
    mul     ip, r0, r3                                                      // 2
    umull   r0, r10, r2, r0                                                 // 3
    mla     r9, r2, r1, ip                                                  // 2
    add     r1, r9, r10                                                     // 3, r9 interlock
    bx      lr
#endif
