#include "formulas.h"
#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>



#define NUM_TESTS 500
#define MAX_LENGTH 10000
#define MAX_ERROR 0.0001
#define MIN_VAL 0.00001
#define MAX_VAl 0.01

int is_close(float f1, float f2) {
    return f1 - f2 <= MAX_ERROR && f2 - f1 <= MAX_ERROR;
}

int is_close2(float f1, float f2) {
    return f1 - f2 <= MAX_ERROR && f2 - f1 <= MAX_ERROR;
}



float formula2_test(float *x, float *y, unsigned int length) {
    float sum = 0;
    for (int k = 0; k < length; k++) {
        float product = 1;
        for (int i = 0; i < length; i++) {
            product *= (x[i]*x[i] + y[i]*y[i] - 2*x[i]*y[i] + 1);
        }
        sum += (x[k]*y[k])/product;
    }
    return sum;
}


int main(void) {
    srand(time(NULL));

    
    float *x = malloc(sizeof(float) * MAX_LENGTH);
    float *y = malloc(sizeof(float) * MAX_LENGTH);

    for (int i = 0; i < NUM_TESTS; i++) {
        unsigned int length = (rand() % MAX_LENGTH) + 1;

        float product;
        if (length%4 == 0){
        do {
            for (unsigned int k = 0; k < length; k++) {
                x[k] = (((float)rand())/((float)RAND_MAX)) * (MAX_VAl - MIN_VAL) + MIN_VAL;
                y[k] = (((float)rand())/((float)RAND_MAX)) * (MAX_VAl - MIN_VAL) + MIN_VAL;
            }

            product = 1;
            for (int i = 0; i < length; i++) {
                product *= (x[i]*x[i] + y[i]*y[i] - 2*x[i]*y[i] + 1);
            }

            
        } while (isnanf(((float)1)/product));
        }
        else{
            continue;
        }
        

        float form2 = formula2(x, y, length);
        float test2 = formula2_test(x, y, length);

 

        if (!is_close(form2, test2)) {
            printf("failed formula 2\n");
            printf("%f %f\n", form2, test2);
            is_close2(form2, test2);

            return 0;
        }

        printf("test2:%f\n",test2);
    }
    printf("test completed successfully\n");

    free(x);
    free(y);
}