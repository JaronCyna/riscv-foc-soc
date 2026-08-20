#ifndef FOC_MATH_H
#define FOC_MATH_H

#include <stdint.h>

#define ONE_BY_SQRT3_Q15    18919   // 1 / sqrt(3) * 2^15
#define SQRT3_BY_2_Q15      28378   // sqrt(3) / 2 * 2^15

typedef struct {
    int32_t a;
    int32_t b;
} Vector2D;

typedef struct {
    int32_t a;
    int32_t b;
    int32_t c;
} Vector3D;

Vector2D clarkTransform(int32_t I_a, int32_t I_b);
Vector2D parkTransform(Vector2D I_ab, int32_t cos, int32_t sin);
Vector2D invParkTransform(Vector2D V_dq, int32_t cos, int32_t sin);
Vector3D invClarkTransform(Vector2D V_ab);

#endif