#pragma once

#include <stdio.h>
#include "hardware/i2c.h"

// Typedef for point number
typedef enum
{
    PT1 = 0,
    PT2,
    PT3,
    PT4,
    PT5
} touch_point_number_t;

typedef struct touch_ptr_addr_named_s
{
    uint16_t                touch_1;
    uint16_t                touch_2;
    uint16_t                touch_3;
    uint16_t                touch_4;
    uint16_t                touch_5;
} touch_ptr_addr_named_t;

/**
 * @brief Addresses for the pointer registers of the touch controller
*/
typedef union
{
    uint16_t                touch[5];
    touch_ptr_addr_named_t  named;
} touch_reg_ptr_addr_t;

/**
 * @brief Offsets for the point registers of the touch controller
*/
typedef struct touch_reg_offsets_t
{
    uint8_t                 track_id;
    uint8_t                 xl;
    uint8_t                 xh;
    uint8_t                 yl;
    uint8_t                 yh;
    uint8_t                 size_l;
    uint8_t                 size_h;
} touch_reg_offsets_t;

/**
 * @brief Addresses for the status registers of the touch controller
*/
typedef struct touch_reg_addr_t
{
    uint16_t                touch_num;

    uint16_t                product_id;
    uint16_t                firmware_id;
    uint16_t                x_res;
    uint16_t                y_res;
    uint16_t                vendor_id;
    
    uint16_t                status;

    touch_reg_ptr_addr_t    ptr_addr;
} touch_reg_addr_t;

/**
 * @brief Struct for storing the chip data
*/
typedef struct touch_chip_data_s
{
    uint8_t                 product_id[4];
    uint16_t                firmware_version;
    uint16_t                x_resolution;
    uint16_t                y_resolution;
    uint8_t                 vendor_id;
} touch_chip_data_t;

/**
 * @brief Struct for storing the point data
*/
typedef struct touch_point_data_s
{
    uint8_t                 track_id;
    uint16_t                x;
    uint16_t                y;
    uint16_t                size;
} touch_point_data_t;

/**
 * @brief Struct for storing the status register data
*/
typedef struct touch_status_data_s
{
    uint8_t                 buffer_status;
    uint8_t                 large_detect;
    uint8_t                 proximity_valid;
    uint8_t                 have_key;
    uint8_t                 num_touches;
} touch_status_data_t;

/**
 * @brief Struct for storing the I2C data
*/
typedef struct touch_i2c_data_s
{
    i2c_inst_t              *inst;
    uint                    i2c_speed;
    uint                    i2c_sda;
    uint                    i2c_scl;
    uint                    i2c_rst;
    uint                    i2c_int;
} touch_i2c_data_t;
