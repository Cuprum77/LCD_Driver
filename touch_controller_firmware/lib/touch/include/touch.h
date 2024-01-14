#pragma once

#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/i2c.h"
#include "touch_reg.h"

#define I2C_SDA 18
#define I2C_SCL 19
#define I2C_RST 20
#define I2C_INT 21

#define I2C_SPEED 400'000
#define I2C_ADDR 0x5d

class touch
{
public:
	touch(
		i2c_inst_t *inst = i2c1,
		uint i2c_speed = I2C_SPEED,
		uint i2c_sda = I2C_SDA,
		uint i2c_scl = I2C_SCL,
		uint i2c_rst = I2C_RST,
		uint i2c_int = I2C_INT
	);

	void init();
	void reset();

	bool product_id(char* buffer, size_t size);

private:
	int write_reg(unsigned short reg, unsigned char* data, size_t size);
	int read_reg(unsigned short reg, unsigned char* data, size_t size);

	i2c_inst_t *inst;
	uint i2c_speed;
	uint i2c_sda;
	uint i2c_scl;
	uint i2c_rst;
	uint i2c_int;
};
