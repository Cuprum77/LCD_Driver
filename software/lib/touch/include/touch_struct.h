#pragma once

#ifdef __cplusplus
extern "C"
{
#endif

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

struct touch_ptr_addr_named_t
{
    unsigned short touch_1;
    unsigned short touch_2;
    unsigned short touch_3;
    unsigned short touch_4;
    unsigned short touch_5;
};

/**
 * @brief Addresses for the pointer registers of the touch controller
*/
typedef union
{
    unsigned short touch[5];
    struct touch_ptr_addr_named_t named;
} touch_reg_ptr_addr_t;

/**
 * @brief Offsets for the point registers of the touch controller
*/
struct touch_reg_offsets_t
{
    unsigned char track_id;
    unsigned char xl;
    unsigned char xh;
    unsigned char yl;
    unsigned char yh;
    unsigned char size_l;
    unsigned char size_h;
};

/**
 * @brief Addresses for the status registers of the touch controller
*/
struct touch_reg_addr_t
{
    unsigned short touch_num;

    unsigned short product_id;
    unsigned short firmware_id;
    unsigned short x_res;
    unsigned short y_res;
    unsigned short vendor_id;
    
    unsigned short status;

    touch_reg_ptr_addr_t ptr_addr;
};

/**
 * @brief Struct for storing the chip data
*/
struct touch_chip_data_s
{
    unsigned char product_id[4];
    unsigned short firmware_version;
    unsigned short x_resolution;
    unsigned short y_resolution;
    unsigned char vendor_id;
};

/**
 * @brief Struct for storing the point data
*/
struct touch_point_data_s
{
    unsigned char track_id;
    unsigned short x;
    unsigned short y;
    unsigned short size;
};

/**
 * @brief Struct for storing the status register data
*/
struct touch_status_data_s
{
    unsigned char buffer_status;
    unsigned char large_detect;
    unsigned char proximity_valid;
    unsigned char have_key;
    unsigned char num_touches;
};

/**
 * @brief Struct for storing the I2C data
*/
struct touch_i2c_data_s
{
    i2c_inst_t *inst;
    uint i2c_speed;
    uint i2c_sda;
    uint i2c_scl;
    uint i2c_rst;
    uint i2c_int;
};

// Offsets for the points (default values)
const struct touch_reg_offsets_t touch_reg_offsets_init = { 
    .track_id = 0,
    .xl = 1,
    .xh = 2,
    .yl = 3,
    .yh = 4,
    .size_l = 5,
    .size_h = 6
};

// Register addresses (default values)
const struct touch_reg_addr_t touch_reg_addr_init = {
    .touch_num = 0x804C,

    .product_id = 0x8140,
    .firmware_id = 0x8144,
    .x_res = 0x8146,
    .y_res = 0x8148,
    .vendor_id = 0x814A,
    
    .status = 0x814E,

    .ptr_addr = {
        .touch = { 
            0x814F,
            0x8157,
            0x815F,
            0x8167,
            0x816F
        }
    }
};

#ifdef __cplusplus
}
#endif