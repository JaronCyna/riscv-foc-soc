#include "pi.h"

Vector2D currErr(int32_t d_target, int32_t q_target, Vector2D I_d_q) {
    int32_t ed = d_target - I_d_q.a;
    int32_t eq = q_target - I_d_q.b;
    Vector2D err = {ed, eq};
    return err;
}

Vector2D Prop(Vector2D err) {
    int32_t KPd = (KP_Q15 * err.a) >> 15;
    int32_t KPq = (KP_Q15 * err.b) >> 15;
    Vector2D prop = {KPd, KPq};
    return prop;
}

Vector2D Integral(Vector2D err, Vector2D last_int) {
    int32_t new_int_d = last_int.a + ((KI_TS_Q15 * err.a) >> 15);
    int32_t new_int_q = last_int.b + ((KI_TS_Q15 * err.b) >> 15);

    if (new_int_d > VMAX)  new_int_d = VMAX;
    if (new_int_d < -VMAX) new_int_d = -VMAX;

    if (new_int_q > VMAX)  new_int_q = VMAX;
    if (new_int_q < -VMAX) new_int_q = -VMAX;

    Vector2D integral = {new_int_d, new_int_q};
    return integral;
}

Vector2D System(Vector2D integral, Vector2D prop) {
    int32_t sys_d = prop.a + integral.a;
    int32_t sys_q = prop.b + integral.b;

    // Total output clamping
    if (sys_d > VMAX)  sys_d = VMAX;
    if (sys_d < -VMAX) sys_d = -VMAX;

    if (sys_q > VMAX)  sys_q = VMAX;
    if (sys_q < -VMAX) sys_q = -VMAX;

    Vector2D sys = {sys_d, sys_q};
    return sys;
}