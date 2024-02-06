/* 313132318 Nir Hadar 
    318868312 Noam Lahmani */
.intel_syntax noprefix
.global formula2
.section .data
.section .text

/*
short code :
    float sum = 0;
    float product = 1;
    for (int i = 0; i < length; i++) {
            product *= ((x[i]- y[i])* (x[i]- y[i]) + 1);
        }

     for (int k = 0; k < length; k++) {
        sum += (x[k]*y[k])/product;
    }
    return sum;
*/

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
    push rcx
    
    # k=0 counter in rbx
    #(then the loop until n-1)
    xor rbx, rbx
    # i=0 counter in rcx
    xor rcx, rcx
    #xmm0 <- sum = 0
    vxorps xmm0, xmm0, xmm0
    #xmm1 <- product = 1
    vxorps xmm1, xmm1, xmm1
    vmovups xmm1, [rip + .F_ONE]
    

calculate_product:
    #xmm2 <- x[i],x[i+1]...x[i+3]
    vmovups xmm2, [rdi + 4 * rcx]
    #xmm3 <- y[i],y[i+1]....y[i+3]
    vmovups xmm3, [rsi + 4 * rcx]
    #xmm2 <- (x[i]- y[i])...
    vsubps xmm2, xmm2, xmm3
    #(x[i]- y[i])^2
    vmulps xmm2, xmm2, xmm2
    ##(x[i]- y[i])^2+1
    vaddps xmm2,xmm2, [rip + .F_ONE]
    vmulps  xmm1, xmm1, xmm2

    add rcx, 4
    cmp rcx, rdx
    jb calculate_product


#save the product in each cell in xmm1
final_product:
    vmovaps xmm2, xmm1 
    vshufps xmm1, xmm1, xmm1, 0b11100001 
    vmulps xmm2, xmm2, xmm1 

    vshufps xmm1, xmm1, xmm1, 0b11100001 
    vmulps xmm2, xmm2, xmm1 
    vshufps xmm1, xmm1, xmm1, 0b11100001 
    vmulps xmm2, xmm2, xmm1 

    vmovaps xmm1, xmm2 


calculate_sum:
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

    add rbx, 4
    cmp rbx, rdx
    jb calculate_sum

end:
    vhaddps xmm0, xmm0, xmm0  
    vhaddps xmm0, xmm0, xmm0  
    pop rbx
    pop rcx
    mov rsp, rbp
    pop rbp
    ret








