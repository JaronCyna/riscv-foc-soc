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

static inline Vector2D clarkTransform(int32_t I_a, int32_t I_b) {
    int32_t I_alpha = I_a;
    int32_t temp = I_a + (I_b << 1);
    int32_t I_beta = (temp * ONE_BY_SQRT3_Q15) >> 15;

    Vector2D result = {I_alpha, I_beta};
    return result;
}

static inline Vector2D parkTransform(Vector2D I_ab, int32_t cos, int32_t sin) {
    int32_t I_d = (I_ab.a * cos + I_ab.b * sin) >> 15;
    int32_t I_q = (-I_ab.a * sin + I_ab.b * cos) >> 15;

    Vector2D result = {I_d, I_q};
    return result;
}

static inline Vector2D invParkTransform(Vector2D V_dq, int32_t cos, int32_t sin) {
    int32_t V_alpha = (V_dq.a * cos - V_dq.b * sin) >> 15;
    int32_t V_beta  = (V_dq.a * sin + V_dq.b * cos) >> 15;

    Vector2D result = {V_alpha, V_beta};
    return result;
}

static inline Vector3D invClarkTransform(Vector2D V_ab) {
    int32_t Va = V_ab.a;
    int32_t Vb = (-V_ab.a >> 1) + ((V_ab.b * SQRT3_BY_2_Q15) >> 15);
    int32_t Vc = -Va - Vb;

    Vector3D result = {Va, Vb, Vc};
    return result;
}


#endif