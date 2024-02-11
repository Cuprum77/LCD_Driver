#pragma once

#include <stdio.h>
#include "pico/stdlib.h"
#include "tusb.h"
#include "usb_descriptors.h"
#include "touch_struct.h"
#include "usb_device_struct.h"

extern touch_report_t touch_rep;

void usb_device_init(void);
void usb_device_touch_data(touch_point_data_t* data, size_t size);
void usb_device_task(void);