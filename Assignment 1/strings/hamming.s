/* 313132318 Nir Hadar 
    318868312 Noam Lahmani */

.intel_syntax noprefix

.globl hamming_dist
.section .data
    .align 16
.section .rodata

.text
hamming_dist:
    # str1 - rdi
    # str2 - rsi

.INIT:
    # Saving frame pointer to be restored later
    push    rbp
    mov     rbp, rsp

    # Choosing rbx as it is a callee register
    push    rbx

    # Zeroing our counting registers:
    # rax - accumulating the Hamming distance
    # rcx - counting the number of differing characters each iteration
    # xmm0 - A temporary register to store calculations
    xor     rax, rax
    xor     rcx, rcx
    pxor    xmm0, xmm0

.LOOP:
    # The idea is to check the MSB of every byte in xmm0, as after pcmpistrm every byte in xmm0 is either 00 or FF
    # We are not interested in the amount of 1's in xmm0, but in the amount of bytes which their most significant bit is 1
    # Amount of most significant bits which are 1 = matching characters
    
    # PMOVMSKB is a command that creates a mask made up of the most significant bit of each byte of the source operand and
    # stores the result in the low byte or word of the destination operand.
    # Credit to ChatGPT: https://chat.openai.com/share/57432c11-1b3b-4005-b027-a6c5f97f3f3f
    pmovmskb ecx, xmm0
    
    # POPCNT calculates the number of bits set to 1 in the second operand (source) and returns the count in the first operand (a destination register).
    popcnt  rcx, rcx
    
    # RCX now stores in the amount of matching characters in current iteration
    # We need to find the complement of the matching characters - the non-matching characters.
    # Non-matching characters = 16 minus matching characters (rcx)
    # We accumulate rax every iteration.
    lea     rax, [rax + 16]
    sub     rax, rcx
    
    movdqa  xmm1, [rdi]
    movdqa  xmm2, [rsi]

    # Moving rdi and rsi pointers by 16 to iterate on next 16 characters
    lea     rdi, [rdi + 16]
    lea     rsi, [rsi + 16]

    # Strange flow but I don't want to set wrong flags
    # As shown in lecture, using pcmpistrm and mask to find MATCHING characters
    pcmpistrm xmm1, xmm2, 0b01001000
    
    # SF is set if any byte of xmm1 is null
    # ZF is set if any byte of xmm2 is null
    # Thus we check these flags. If none are set to 1 then we proceed to another loop
    jnz     .LOOP
    jns     .LOOP

    # If we didn't jump, then we reached end of string.
    # We count matches and subtract them as they are irrelevant 
    pmovmskb ecx, xmm0
    popcnt   rcx, rcx 
    sub      rax, rcx

.END:    
    # Popping callee register rbx
    pop      rbx
    
    # Restoring frame pointer
    mov      rsp, rbp
    pop      rbp
    ret

