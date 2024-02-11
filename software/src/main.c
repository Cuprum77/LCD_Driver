#include <stdio.h>
#include "pico/stdlib.h"
#include "pico/multicore.h"
#include "pico/binary_info.h"
#include "version.h"
#include "touch.h"
#include "tusb.h"
#include "usb_device.h"

#define LED_PIN 6

#define TOUCH_I2C_SDA 	18
#define TOUCH_I2C_SCL 	19
#define TOUCH_I2C_RST 	20
#define TOUCH_I2C_INT 	21

// Define which LED to indicate the bootloader activity
#define PICO_STDIO_USB_RESET_BOOTSEL_FIXED_ACTIVITY_LED LED_PIN

// Declare the binary info
bi_decl(bi_program_description("Touchscreen HID"));
bi_decl(bi_1pin_with_name(LED_PIN, "On-board LED"));
bi_decl(bi_program_version_string(GIT_COMMIT_HASH));
bi_decl(bi_program_build_date_string(GIT_COMMIT_DATE));
bi_decl(bi_program_url("https://github.com/Cuprum77/LCD_Driver"));
bi_decl(bi_4pins_with_names(TOUCH_I2C_SDA, "I2C SDA", TOUCH_I2C_SCL, "I2C SCL", TOUCH_I2C_RST, "I2C RST", TOUCH_I2C_INT, "I2C INT"));

// LED blinker
bool led_state = false;
uint32_t interval = 250000;
uint32_t timer = 0;
void blink_led()
{
    if ((time_us_32() - timer) >= interval)
    {
        timer = time_us_32();
        led_state = !led_state;
        gpio_put(LED_PIN, led_state);
    }
}

int main()
{
    // Init stdio
    stdio_init_all();

    // Setup the blink pin
    gpio_init(LED_PIN);
    gpio_set_dir(LED_PIN, GPIO_OUT);

    // Initialize the touch controller
    touch_init(i2c1, TOUCH_I2C_SPEED, TOUCH_I2C_SDA, TOUCH_I2C_SCL, 
        TOUCH_I2C_RST, TOUCH_I2C_INT
    );

    // Init the USB
    usb_device_init();

    while (1)
    {
        // Blink the LED
        blink_led();

        // Device task
        usb_device_task();

        // Touch task
        usb_device_touch_data((touch_point_data_t*)touch_points, 5);
    }
}

//--------------------------------------------------------------------+
// Device callbacks
//--------------------------------------------------------------------+

// Invoked when device is mounted
void tud_mount_cb(void)
{

}

// Invoked when device is unmounted
void tud_umount_cb(void)
{

}

// Invoked when usb bus is suspended
// remote_wakeup_en : if host allow us  to perform remote wakeup
// Within 7ms, device must draw an average of current less than 2.5 mA from bus
void tud_suspend_cb(bool remote_wakeup_en)
{
    
}

// Invoked when usb bus is resumed
void tud_resume_cb(void)
{
    
}

//--------------------------------------------------------------------+
// USB HID
//--------------------------------------------------------------------+

static void send_hid_report(uint8_t report_id, uint32_t btn)
{
    
}

// Every 10ms, we will sent 1 report for each HID profile (keyboard, mouse etc ..)
// tud_hid_report_complete_cb() is used to send the next report after previous one is complete
void hid_task(void)
{
    
}

// Invoked when sent REPORT successfully to host
// Application can use this to send the next report
// Note: For composite reports, report[0] is report ID
void tud_hid_report_complete_cb(uint8_t instance, uint8_t const* report, uint16_t len)
{
    
}

// Invoked when received GET_REPORT control request
// Application must fill buffer report's content and return its length.
// Return zero will cause the stack to STALL request
uint16_t tud_hid_get_report_cb(uint8_t instance, uint8_t report_id, hid_report_type_t report_type, uint8_t* buffer, uint16_t reqlen)
{
    return 0;
}

// Invoked when received SET_REPORT control request or
// received data on OUT endpoint ( Report ID = 0, Type = 0 )
void tud_hid_set_report_cb(uint8_t instance, uint8_t report_id, hid_report_type_t report_type, uint8_t const* buffer, uint16_t bufsize)
{
    
}