#pragma once

#include "touch_struct.h"

// Register addresses (default values)
static const touch_reg_addr_t touch_reg_addr_init = {
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

// Offsets for the points (default values)
static const touch_reg_offsets_t touch_reg_offsets_init = { 
    .track_id = 0,
    .xl = 1,
    .xh = 2,
    .yl = 3,
    .yh = 4,
    .size_l = 5,
    .size_h = 6
};
