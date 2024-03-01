#include <stdio.h>
#include "pico/stdlib.h"
#include "pico/multicore.h"
#include "pico/binary_info.h"
#include "version.h"
#include "touch.h"
#include "usb_device.h"

#define LED_PIN 25

#define TOUCH_I2C_SDA 	18
#define TOUCH_I2C_SCL 	19
#define TOUCH_I2C_RST 	20
#define TOUCH_I2C_INT 	21

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

    // Interval for transmitting touch data
    uint32_t touch_interval = 100000;
    uint32_t touch_timer = 0;
    
    while (1)
    {
        // Blink the LED
        blink_led();

        // Device task
        usb_device_task();

        // Printout the touch data
        if ((time_us_32() - touch_timer) >= touch_interval)
        {
            touch_timer = time_us_32();
            printf("Status: %d, %d, %d, %d, %d\n", touch_status_data.buffer_status, touch_status_data.large_detect, touch_status_data.proximity_valid, touch_status_data.have_key, touch_status_data.num_touches);
            for (size_t i = 0; i < 5; i++)
            {
                printf("Touch %d: %d, %d, %d\n", i, touch_points[i].x, touch_points[i].y, touch_points[i].size);
            }
        }
        
        // Touch task
        usb_device_touch_data((touch_point_data_t*)touch_points, 5, 5);
    }
}