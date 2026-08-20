#ifndef PI_H
#define PI_H

#include <stdint.h>
#include "foc_math.h"

// fixed-point constants
#define KP_Q15          1500    // Proportional gain in Q15
#define KI_TS_Q15       85      // (Ki * Ts) combined in Q15
#define VMAX            2000    // Maximum voltage 

Vector2D currErr(int32_t d_target, int32_t q_target, Vector2D I_d_q);
Vector2D Prop(Vector2D err);
Vector2D Integral(Vector2D err, Vector2D last_int);
Vector2D System(Vector2D integral, Vector2D prop);

#endif