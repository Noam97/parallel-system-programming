/* 313132318 Nir Hadar 
    318868312 Noam Lahmani */
#include <math.h>
#include <immintrin.h>

//  perform horizontal addition of SSE vector
float hsum_ps_sse(__m128 v) {
    // duplicate elements for addition
    __m128 shuf = _mm_movehdup_ps(v); 
    __m128 sums = _mm_add_ps(v, shuf);
    shuf = _mm_movehl_ps(shuf, sums);
    sums = _mm_add_ss(sums, shuf);
    return _mm_cvtss_f32(sums);
}

float formula1(float *x, unsigned int length) {
    __m128 loaderVectors;
    __m128 onesArray = _mm_set1_ps(1.0);
    __m128 loaderNumerator = _mm_setzero_ps();
    __m128 loaderDenominator = _mm_set1_ps(1.0);

    float component[4]; 
    
    int i;
    for (i = 0; i <= length - 4; i += 4) {
        loaderVectors = _mm_loadu_ps(x + i);
        loaderNumerator = _mm_add_ps(loaderNumerator, _mm_sqrt_ps(loaderVectors));
        loaderDenominator = _mm_mul_ps(loaderDenominator, _mm_fmadd_ps(loaderVectors, loaderVectors, onesArray));
    }

    // reduction of loaderNumerator using horizontal add
    _mm_storeu_ps(component, loaderNumerator);
    // horizontal sum
    float numerator = hsum_ps_sse(loaderNumerator); 

    // reduction of loaderDenominator
    _mm_storeu_ps(component, loaderDenominator);
   // float denominator = component[0] * component[1] * component[2] * component[3]; 
    __m128 compVec = _mm_loadu_ps(component); // Load components into an SSE vector
    __m128 shuf = _mm_shuffle_ps(compVec, compVec, _MM_SHUFFLE(2, 3, 0, 1)); // Shuffle elements
    __m128 mul1 = _mm_mul_ps(compVec, shuf); // Multiply original and shuffled vectors
    shuf = _mm_shuffle_ps(mul1, mul1, _MM_SHUFFLE(1, 0, 3, 2)); // Second shuffle
    __m128 mul2 = _mm_mul_ss(mul1, shuf); // Final multiply to get the product
    float denominator = _mm_cvtss_f32(mul2); // Extract the product

    // handle remaining elements for arrays not divisible by 4
    for (; i < length; ++i) {
        numerator += sqrtf(x[i]);
        denominator *= x[i] * x[i] + 1;
    }

    return sqrtf(1.0f + cbrtf(numerator) / denominator);
}
