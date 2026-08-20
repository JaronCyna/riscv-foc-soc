#ifndef FOC_REGS_H
#define FOC_REGS_H

#include <stdint.h>

#define ANGLE_IN            (*(volatile uint32_t *)0x80000000)
#define DEAD_TIME_CYCLES    (*(volatile uint32_t *)0x80000004)
#define PERIOD_MAX          (*(volatile uint32_t *)0x80000008)
#define DUTY_A              (*(volatile uint32_t *)0x8000000C)
#define DUTY_B              (*(volatile uint32_t *)0x80000010)
#define DUTY_C              (*(volatile uint32_t *)0x80000014)
#define SIN                 (*(volatile uint32_t *)0x80000018)
#define COS                 (*(volatile uint32_t *)0x8000001C)
#define OUT_VALID           (*(volatile uint32_t *)0x80000020)

//Still need to implement in SV
#define CURRENT_A           (*(volatile uint32_t *)0x80000024)
#define CURRENT_B           (*(volatile uint32_t *)0x80000028)
#define POTENTIOMETER       (*(volatile uint32_t *)0x8000002C)
#define FOC_STATUS_REG      (*(volatile uint32_t *)0x80000030)
#define ENCODER_ROTOR_ANGLE (*(volatile uint32_t *)0x80000034)

#endif