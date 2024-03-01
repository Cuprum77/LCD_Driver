#pragma once

#include <stdio.h>

// Taken from https://github.com/azukovskij89/AVR-MultiTouch

typedef struct
{
    // Collection Touch Screen
    uint8_t contact_count_max;
} digitizer_feature_t;

// Digitizer Report
typedef struct
{
    // Collection 0
    uint8_t finger0_tip_switch  : 1;
    uint8_t finger0_in_range    : 1;
    uint8_t finger0_contact_id;
    uint16_t finger0_x;
    uint16_t finger0_y;
    // Collection 1
    uint8_t finger1_tip_switch  : 1;
    uint8_t finger1_in_range    : 1;
    uint8_t finger1_contact_id;
    uint16_t finger1_x;
    uint16_t finger1_y;
    // Collection 2
    uint8_t finger2_tip_switch  : 1;
    uint8_t finger2_in_range    : 1;
    uint8_t finger2_contact_id;
    uint16_t finger2_x;
    uint16_t finger2_y;
    // Collection 3
    uint8_t finger3_tip_switch  : 1;
    uint8_t finger3_in_range    : 1;
    uint8_t finger3_contact_id;
    uint16_t finger3_x;
    uint16_t finger3_y;
    // Collection 4
    uint8_t finger4_tip_switch  : 1;
    uint8_t finger4_in_range    : 1;
    uint8_t finger4_contact_id;
    uint16_t finger4_x;
    uint16_t finger4_y;
    // Collection Touch Screen
    uint8_t contact_count;
} digitizer_report_t;
