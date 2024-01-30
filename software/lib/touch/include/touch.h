#pragma once

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/i2c.h"
#include "hardware/gpio.h"
#include "touch_struct.h"

#define TOUCH_I2C_SDA 	18
#define TOUCH_I2C_SCL 	19
#define TOUCH_I2C_RST 	20
#define TOUCH_I2C_INT 	21

#define TOUCH_I2C_SPEED 400000
#define TOUCH_I2C_ADDR 	0x5d

// Register addresses
extern volatile struct touch_reg_addr_t touch_reg_addr;
// Offsets for the points
extern volatile struct touch_reg_offsets_t touch_reg_offsets;
// I2C data
extern volatile struct touch_i2c_data_s touch_i2c_data;
// Chip data
extern volatile struct touch_chip_data_s touch_chip_data;
// Status register data
extern volatile struct touch_status_data_s touch_status_data;
// Point data
extern volatile struct touch_point_data_s touch_points[5];

void touch_init(i2c_inst_t *inst, uint i2c_speed, 
	uint i2c_sda, uint i2c_scl, 
	uint i2c_rst, uint i2c_int
);
void touch_reset();

int touch_write_reg(unsigned short reg, unsigned char* data, size_t size);
int touch_read_reg(unsigned short reg, unsigned char* data, size_t size);

int touch_get_all_points();
static void touch_irq_handler(uint gpio, uint32_t events);

#ifdef __cplusplus
}
#endif