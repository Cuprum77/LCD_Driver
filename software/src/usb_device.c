#include "usb_device.h"

// HID Report Descriptor
touch_report_t touch_rep;

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
void usb_device_touch_data(touch_point_data_t* data, size_t size)
{
    // Return if the size does not match the expected size
    if (size != 5)
    {
        return;
    }

    // Fill the struct with the touch data
    touch_rep.reportId = 0x04;

    // First point
    touch_rep.DIG_TouchScreenFingerTipSwitch = FINGER_TIP_SWITCH;
    touch_rep.DIG_TouchScreenFingerContactIdentifier = data[0].track_id;
    touch_rep.GD_TouchScreenFingerX[0] = data[0].x;
    touch_rep.GD_TouchScreenFingerX[1] = 0;
    touch_rep.GD_TouchScreenFingerY[0] = data[0].y;
    touch_rep.GD_TouchScreenFingerY[1] = 0;
    touch_rep.DIG_TouchScreenFingerWidth = data[0].size;
    touch_rep.DIG_TouchScreenFingerHeight = data[0].size;
    touch_rep.DIG_TouchScreenFingerAzimuth = 0; // No data

    // Second point
    touch_rep.DIG_TouchScreenFingerTipSwitch_1 = FINGER_TIP_SWITCH;
    touch_rep.DIG_TouchScreenFingerContactIdentifier_1 = data[1].track_id;
    touch_rep.GD_TouchScreenFingerX_1[0] = data[1].x;
    touch_rep.GD_TouchScreenFingerX_1[1] = 0;
    touch_rep.GD_TouchScreenFingerY_1[0] = data[1].y;
    touch_rep.GD_TouchScreenFingerY_1[1] = 0;
    touch_rep.DIG_TouchScreenFingerWidth_1 = data[1].size;
    touch_rep.DIG_TouchScreenFingerHeight_1 = data[1].size;
    touch_rep.DIG_TouchScreenFingerAzimuth_1 = 0; // No data

    // Third point
    touch_rep.DIG_TouchScreenFingerTipSwitch_2 = FINGER_TIP_SWITCH;
    touch_rep.DIG_TouchScreenFingerContactIdentifier_2 = data[2].track_id;
    touch_rep.GD_TouchScreenFingerX_2[0] = data[2].x;
    touch_rep.GD_TouchScreenFingerX_2[1] = 0;
    touch_rep.GD_TouchScreenFingerY_2[0] = data[2].y;
    touch_rep.GD_TouchScreenFingerY_2[1] = 0;
    touch_rep.DIG_TouchScreenFingerWidth_2 = data[2].size;
    touch_rep.DIG_TouchScreenFingerHeight_2 = data[2].size;
    touch_rep.DIG_TouchScreenFingerAzimuth_2 = 0; // No data

    // Fourth point
    touch_rep.DIG_TouchScreenFingerTipSwitch_3 = FINGER_TIP_SWITCH;
    touch_rep.DIG_TouchScreenFingerContactIdentifier_3 = data[3].track_id;
    touch_rep.GD_TouchScreenFingerX_3[0] = data[3].x;
    touch_rep.GD_TouchScreenFingerX_3[1] = 0;
    touch_rep.GD_TouchScreenFingerY_3[0] = data[3].y;
    touch_rep.GD_TouchScreenFingerY_3[1] = 0;
    touch_rep.DIG_TouchScreenFingerWidth_3 = data[3].size;
    touch_rep.DIG_TouchScreenFingerHeight_3 = data[3].size;
    touch_rep.DIG_TouchScreenFingerAzimuth_3 = 0; // No data

    // Fifth point
    touch_rep.DIG_TouchScreenFingerTipSwitch_4 = FINGER_TIP_SWITCH;
    touch_rep.DIG_TouchScreenFingerContactIdentifier_4 = data[4].track_id;
    touch_rep.GD_TouchScreenFingerX_4[0] = data[4].x;
    touch_rep.GD_TouchScreenFingerX_4[1] = 0;
    touch_rep.GD_TouchScreenFingerY_4[0] = data[4].y;
    touch_rep.GD_TouchScreenFingerY_4[1] = 0;
    touch_rep.DIG_TouchScreenFingerWidth_4 = data[4].size;
    touch_rep.DIG_TouchScreenFingerHeight_4 = data[4].size;
    touch_rep.DIG_TouchScreenFingerAzimuth_4 = 0; // No data

    // Send the touch data
    tud_hid_report(0, &touch_rep, sizeof(touch_report_t));
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
