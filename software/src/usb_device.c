#include "usb_device.h"

// HID Report Descriptor
volatile digitizer_report_t report;

/**
 * @brief Initialize the USB device.
 */
void usb_device_init(void)
{
    // Initialize the USB stack
    tusb_init();
}

/**
 * @brief Send touch data to the USB device.
 * @param data The touch data array.
 * @param size The size of the touch data array.
 */
void usb_device_touch_data(touch_point_data_t* data, size_t size, uint8_t contact_count)
{
    // Return if the size does not match the expected size
    if (size != 5)
    {
        return;
    }
    
    // Fill in the touch report
    report.finger0_contact_id = 0;
    report.finger0_in_range = 1;
    if (contact_count > 0)
    {
        report.finger0_tip_switch = 1;
        report.finger0_x = data[0].x;
        report.finger0_y = data[0].y;
    }
    
    report.finger1_contact_id = 1;
    report.finger1_in_range = 1;
    if (contact_count > 1)
    {
        report.finger1_tip_switch = 1;
        report.finger1_x = data[1].x;
        report.finger1_y = data[1].y;
    }

    report.finger2_contact_id = 2;
    report.finger2_in_range = 1;
    if (contact_count > 2)
    {
        report.finger2_tip_switch = 1;
        report.finger2_x = data[2].x;
        report.finger2_y = data[2].y;
    }

    report.finger3_contact_id = 3;
    report.finger3_in_range = 1;
    if (contact_count > 3)
    {
        report.finger3_tip_switch = 1;
        report.finger3_x = data[3].x;
        report.finger3_y = data[3].y;
    }

    report.finger4_contact_id = 4;
    report.finger4_in_range = 1;
    if (contact_count > 4)
    {
        report.finger4_tip_switch = 1;
        report.finger4_x = data[4].x;
        report.finger4_y = data[4].y;
    }

    // Set the contact count
    report.contact_count = contact_count;
}

/**
 * @brief Send keyboard data to the USB device.
 * @param data The keyboard data array.
 * @param size The size of the keyboard data array.
 */
void usb_device_task(void)
{
    // Poll the USB stack
    tud_task();
}

/**
 * @brief Send HID data to the USB device.
 * @note Only sends the HID data every 10ms.
 */
void usb_hid_task(void)
{
    // Skip if hid is not ready yet
    if (!tud_hid_ready())
    {
        return;
    }

    // Static variable for the task interval counter
    static uint32_t task_interval_counter = 0;

    // Check if the task interval has elapsed, if not return
    if ((time_us_32() - task_interval_counter) < USB_DEVICE_TASK_INTERVAL)
    {
        return;
    }

    // Update the task interval counter
    task_interval_counter = time_us_32();    

    // Wake the up if asleep
    if (tud_suspended())
    {
        // Wake up host if we are in suspend mode
        // and REMOTE_WAKEUP feature is enabled by host
        tud_remote_wakeup();
    }
    else
    {
        // Transmit the touch data
        digitizer_report_t* report_ptr = (digitizer_report_t*) &report;
        tud_hid_report(1, report_ptr, sizeof(digitizer_report_t));
    }
}

/***
 *      _____ _          _   _ ___ ___    ___      _ _ _             _       
 *     |_   _(_)_ _ _  _| | | / __| _ )  / __|__ _| | | |__  __ _ __| |__ ___
 *       | | | | ' \ || | |_| \__ \ _ \ | (__/ _` | | | '_ \/ _` / _| / /(_-<
 *       |_| |_|_||_\_, |\___/|___/___/  \___\__,_|_|_|_.__/\__,_\__|_\_\/__/
 *                  |__/                                                     
 */

//--------------------------------------------------------------------+
// USB HID
//--------------------------------------------------------------------+

// Invoked when sent REPORT successfully to host
// Application can use this to send the next report
// Note: For composite reports, report[0] is report ID
void tud_hid_report_complete_cb(uint8_t instance, uint8_t const* report, uint16_t len)
{
    (void) instance;
    (void) len;

/*
    uint8_t next_report_id = report[0] + 1u;

    if (next_report_id == 2)
    {
        // Transmit the feature report
        digitizer_feature_t feature;
        digitizer_report_t* report_ptr = (digitizer_report_t*) &report;
        feature.contact_count_max = report_ptr->contact_count;

        tud_hid_report(2, (uint8_t*) &feature, sizeof(digitizer_feature_t));
    }
    else
    {
        // Transmit the touch data
        digitizer_report_t* report_ptr = (digitizer_report_t*) &report;
        tud_hid_report(1, report_ptr, sizeof(digitizer_report_t));
    }*/
}

// Invoked when received GET_REPORT control request
// Application must fill buffer report's content and return its length.
// Return zero will cause the stack to STALL request
uint16_t tud_hid_get_report_cb(uint8_t instance, uint8_t report_id, hid_report_type_t report_type, uint8_t* buffer, uint16_t reqlen)
{
    /*if (report_id == 0 && report_type == HID_REPORT_TYPE_INPUT)
    {
        memcpy(buffer, &report, sizeof(digitizer_report_t));
        return sizeof(digitizer_report_t);
    }

    if (report_id == 2)
    {
        memcpy(buffer, &(report.contact_count), sizeof(digitizer_feature_t));
        return sizeof(digitizer_feature_t);
    }
    
    return 0;*/
    // TODO not Implemented
    (void) instance;
    (void) report_id;
    (void) report_type;
    (void) buffer;
    (void) reqlen;

    return 0;
}

// Invoked when received SET_REPORT control request or
// received data on OUT endpoint ( Report ID = 0, Type = 0 )
void tud_hid_set_report_cb(uint8_t instance, uint8_t report_id, hid_report_type_t report_type, uint8_t const* buffer, uint16_t bufsize)
{
    
}