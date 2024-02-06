/* 
318868312 Noam Lahmani
*/
.intel_syntax noprefix
.global formula2
.section .data
.section .text
/*
arguments: 
rdi : *x 
rsi : *y 
rdx : length (n)
*/
.F_ONE:       
    .long 1065353216
    .long 1065353216   
    .long 1065353216
    .long 1065353216
    .long 1065353216
    .long 1065353216
    .long 1065353216
    .long 1065353216   
formula2:
    push rbp
    mov rbp, rsp
    push rbx

    #r12 <- n
    movq r12, rdx
     #r13 <- n
    movq r13, rdx

    # k=0 counter in rbx
    #(then the loop until n-1)
    xor rbx, rbx
    # i=0 counter in rcx
    xor rcx, rcx
    #xmm0 <- 0
    vxorps xmm0, xmm0, xmm0
    #xmm1 <- 1.0
    vxorps xmm1, xmm1, xmm1
    vmovups xmm1, [rip + .F_ONE]
    vxorps xmm2,xmm2, xmm2
    vxorps xmm3,xmm3, xmm3
    vxorps xmm4, xmm4,xmm4
    vxorps xmm5, xmm5,xmm5
    vxorps xmm6, xmm6, xmm6

outer_loop:
    cmp rbx, r13
    # k - n >=0 ->  if k>=n
    jae end_outer_loop
    xor rcx, rcx
    #xmm1 <- 1.0
    vbroadcastss  xmm1, [rip + .F_ONE]
    jmp inner_loop

inner_loop:
    vxorps xmm2,xmm2, xmm2
    vxorps xmm3,xmm3, xmm3
    vxorps xmm4, xmm4,xmm4
    vxorps xmm5, xmm5,xmm5
    vxorps xmm6, xmm6, xmm6
    // # i - n >=0 ->  if i>=n
    cmp rcx, r12
    jae end_inner_loop
   
    #xmm2 <- x[i],x[i+1]...x[i+7]
    vmovups xmm2, [rdi + 4 * rcx]
    #xmm3 <- y[i],y[i+1]....y[i+7]
    vmovups xmm3, [rsi + 4 * rcx]

    # xmm4 <- (x[i])^2, (x[i+1])^2....
    vmulps xmm4, xmm2, xmm2
    # xmm5 <- (y[i])^2, (y[i+1])^2....
    vmulps xmm5, xmm3, xmm3
    # xmm4 <- (x[i])^2 + (y[i])^2, (x[i+1])^2 + (y[i+1])^2...
    vaddps xmm4, xmm4, xmm5

    # xmm3 <- x[i] * y[i],...x[i+7]*y[i+7]
    vmulps xmm3, xmm3 , xmm2
    # xmm3 <- x[i] * y[i] + x[i] * y[i] = 2* (x[i] * y[i])..
    vaddps xmm3, xmm3, xmm3

    #1.0
    #xmm6 <- 1.0
    vbroadcastss  xmm6, [rip + .F_ONE]
    # xmm4 <-  (x[i])^2 + (y[i])^2 + 1 
    vaddps xmm4, xmm4, xmm6

    # xmm4 <- (x[i])^2 + (y[i])^2 + 1 - 2* (x[i] * y[i])
    vsubps xmm4, xmm4, xmm3 
    /*Multiply the result from the previous iteration
    with the result from the current iteration*/
    vmulps xmm1, xmm1, xmm4

    # i++
    add rcx, 4
    // inc rcx
    jmp inner_loop



end_inner_loop:
    vxorps xmm2,xmm2, xmm2
    vxorps xmm3,xmm3, xmm3
    #xmm2 <- x[k],x[k+1]...x[k+7]
    vmovups   xmm2, [rdi + 4 * rbx]
    #xmm3 <- y[k],y[k+1]....y[k+7]
    vmovups   xmm3, [rsi + 4 * rbx]
    # xmm2 <- x[k] * y[k]
    vmulps xmm2, xmm2 , xmm3
    # xmm2 <- (x[k] * y[k]) / (x[i])^2 + (y[i])^2 + 1 - 2* (x[i] * y[i])
    vdivps xmm2, xmm2, xmm1
    /*xmm0 (return value) 
    Add the result from the previous iteration
    with the result from the current iteration*/ 
    vaddps xmm0, xmm0, xmm2
 

//     #k++
    add rbx, 4
    jmp outer_loop

#1.0
  
end_outer_loop:
    // add rsp, 256
    vhaddps xmm0, xmm0, xmm0  
    vhaddps xmm0, xmm0, xmm0  

    pop rbx
    mov rsp, rbp
    pop rbp
    ret

