#include <stdio.h>
#include "pico/stdlib.h"
#include "touch.h"
#include "tusb.h"

#define LED_PIN 6

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
    
    // Wait for user input
    while (!tud_cdc_connected())
    {
        printf(".");
        sleep_ms(500);
    }

    // Wait for the user to press enter
    printf("\nPress enter to continue.\n");
    getchar();

    // Output the touch chip data
    printf("Product ID: %s\n", touch_chip_data.product_id);
    printf("Firmware version: %d\n", touch_chip_data.firmware_version);
    printf("X resolution: %d\n", touch_chip_data.x_resolution);
    printf("Y resolution: %d\n", touch_chip_data.y_resolution);
    printf("Vendor ID: %d\n", touch_chip_data.vendor_id);   

    while (1)
    {
        // Wait for the user to press enter
        getchar();

        // Wait a few ms
        sleep_ms(10);

        // Get the status register
        unsigned char buffer_status = touch_status_data.buffer_status;
        unsigned char large_detect = touch_status_data.large_detect;
        unsigned char prox_valid = touch_status_data.proximity_valid;
        unsigned char have_key = touch_status_data.have_key;
        unsigned char num_touches = touch_status_data.num_touches;
        printf("Status: %d, %d, %d, %d, %d\n", 
            buffer_status, large_detect, prox_valid, have_key, num_touches);

        // Get the data for each point
        for(int i = 0; i < 5; i++)
        {
            unsigned char track_id = touch_points[i].track_id;
            unsigned short x = touch_points[i].x;
            unsigned short y = touch_points[i].y;
            unsigned short size = touch_points[i].size;

            printf("Point %d: %d, %d, %d, %d\n", (i + 1), track_id, x, y, size);            
        }
    }
}
