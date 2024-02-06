
/* 313132318 Nir Hadar
   318868312 Noam Lahmani */
#include <stdio.h>
#include <stdint.h> 
#include <string.h>
#include <stdbool.h>
#include <emmintrin.h> // SSE2 
#include <tmmintrin.h> // SSSE3 header file for _mm_shuffle_epi8
#include <smmintrin.h> // SSE4.1 
#include <immintrin.h>

#define MAX_STR 256

//Have permission to write this serial code

    /*
    range of base16 chars:
    A-Z, a-z, 0-9, +, /
    */
bool is_base64_char(char c) {
    return ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || 
            (c >= '0' && c <= '9') || c == '+' || c == '/');
}

void filter_base64_chars(const char* original_str, char* filtered_str) {
    int j = 0; 
    for (int i = 0; i < strlen(original_str); ++i) {
        if (is_base64_char(original_str[i])) {
            filtered_str[j++] = original_str[i]; 
        }
    }
    filtered_str[j] = '\0'; 
    // printf("filtered: %s",output);
}

__m256i map_base64_values(__m256i filtered) {
    // masks to check which range each character falls into
    __m256i mask_upper = _mm256_and_si256(_mm256_cmpgt_epi8(filtered, _mm256_set1_epi8('A' - 1)), _mm256_cmpgt_epi8(_mm256_set1_epi8('Z' + 1), filtered));
    __m256i mask_lower = _mm256_and_si256(_mm256_cmpgt_epi8(filtered, _mm256_set1_epi8('a' - 1)), _mm256_cmpgt_epi8(_mm256_set1_epi8('z' + 1), filtered));
    __m256i mask_digit = _mm256_and_si256(_mm256_cmpgt_epi8(filtered, _mm256_set1_epi8('0' - 1)), _mm256_cmpgt_epi8(_mm256_set1_epi8('9' + 1), filtered));
    __m256i mask_plus = _mm256_cmpeq_epi8(filtered, _mm256_set1_epi8('+'));
    __m256i mask_slash = _mm256_cmpeq_epi8(filtered, _mm256_set1_epi8('/'));

    // calculate offsets for different ranges
    __m256i upper_value = _mm256_sub_epi8(filtered, _mm256_set1_epi8('A'));
    __m256i lower_value = _mm256_sub_epi8(filtered, _mm256_set1_epi8('a' - 26));
    __m256i digit_value = _mm256_sub_epi8(filtered, _mm256_set1_epi8('0' - 52));
    __m256i plus_value = _mm256_set1_epi8(62);
    __m256i slash_value = _mm256_set1_epi8(63);

    // combine the values based on the masks
    __m256i b64_vals = _mm256_setzero_si256();
    b64_vals = _mm256_or_si256(b64_vals, _mm256_and_si256(mask_upper, upper_value));
    b64_vals = _mm256_or_si256(b64_vals, _mm256_and_si256(mask_lower, lower_value));
    b64_vals = _mm256_or_si256(b64_vals, _mm256_and_si256(mask_digit, digit_value));
    b64_vals = _mm256_or_si256(b64_vals, _mm256_and_si256(mask_plus, plus_value));
    b64_vals = _mm256_or_si256(b64_vals, _mm256_and_si256(mask_slash, slash_value));

    return b64_vals;
}



__uint128_t convert_base64_to_values(const char* input, int length) {
    __uint128_t total = 0;
    unsigned char base64_values_array[32]; 

    for (int chunk = 0; chunk <= (length - 1) / 32; ++chunk) {
        int current_length = chunk < (length - 1) / 32 ? 32 : length % 32;

        // Load current chunk into SIMD register
        __m256i current_chunk = _mm256_loadu_si256((__m256i*)(input + chunk * 32));
        __m256i base64_values = map_base64_values(current_chunk);

        // Store SIMD data into an array for dynamic indexing
        _mm256_storeu_si256((__m256i*)base64_values_array, base64_values);

        for (int i = 0; i < current_length; ++i) {
            int val = base64_values_array[length-i-1] & 63; 

            // calculate the multiplier based on the position
            __uint128_t multiplier = 1;
            for (int j = 0; j < chunk * 32 + i; ++j) {
                multiplier *= 64;
            }

            total += (__uint128_t)val * multiplier;
            // printf(" val: %d\n", val); 
            // printf(" multiplier: %lu\n", (unsigned long)multiplier);
        }
        // printf("Partial total after chunk %d: %lu\n", chunk, (unsigned long)total); // Casting for printing
    
    }
    // printf("Final total: %lu\n", (unsigned long)total);
    return total;
}



int b64_distance(char str1[MAX_STR], char str2[MAX_STR]) {
    char filtered1[MAX_STR];
    char filtered2[MAX_STR];
    filter_base64_chars(str1, filtered1);
    filter_base64_chars(str2, filtered2);

    __uint128_t value1 = convert_base64_to_values(filtered1, strlen(filtered1));
    __uint128_t value2 = convert_base64_to_values(filtered2, strlen(filtered2));

    return (int)(value2 - value1); 
}
