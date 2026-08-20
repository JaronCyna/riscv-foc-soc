#include <stdint.h>
#include "pi.h"
#include "foc_math.h"
#include "foc_regs.h"

static inline uint32_t scale(int32_t V, uint32_t half_period) {
    int32_t duty = (int32_t)half_period + V;
    if (duty < 0) duty = 0;
    else if (duty > (half_period << 1)) duty = (half_period << 1);
    return (uint32_t)duty;
}

int main(void){

    Vector2D integral_state = {0, 0};
    
    DEAD_TIME_CYCLES = 50;     // 50 cycles = 1.0 us dead time
    PERIOD_MAX       = 2500;   // 50 MHz / 20 kHz = 2500 cycles    
    uint32_t half_N = PERIOD_MAX >> 1;

    while(1)
    {
        while(((FOC_STATUS_REG & 0x01) == 0));

        int32_t ia = (int32_t)CURRENT_A;
        int32_t ib = (int32_t)CURRENT_B;


        ANGLE_IN = ENCODER_ROTOR_ANGLE;
        while (!OUT_VALID);

        Vector2D Current_val = {0, 0};
        Vector2D Current_err = {0, 0};
        Vector3D Final_val = {0, 0, 0};

        int32_t cos_val = (int32_t)COS;
        int32_t sin_val = (int32_t)SIN;

        //Clark and Park
        Current_val = clarkTransform(ia, ib);
        Current_val = parkTransform(Current_val, cos_val, sin_val);

        //PI Controller
        Current_err = currErr(0, (int32_t)POTENTIOMETER, Current_val);
        Current_val = Prop(Current_err);
        integral_state = Integral(Current_err, integral_state);
        Current_val = System(integral_state, Current_val);

        //Inv Clark and Park
        Current_val = invParkTransform(Current_val, cos_val, sin_val);
        Final_val = invClarkTransform(Current_val);

        DUTY_A = scale(Final_val.a, half_N);
        DUTY_B = scale(Final_val.b, half_N);
        DUTY_C = scale(Final_val.c, half_N);

        FOC_STATUS_REG = 0;
    }

    return 0;
}