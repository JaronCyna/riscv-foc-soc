#include <stdio.h>
#include <math.h>

int test_compiling() {
    printf("sin(3.14) = %.2lf\n", sin(3.14));
    printf("sin(10) = %.2lf\n", sin(10.0));
    return 0;
}