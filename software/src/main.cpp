#include <stdio.h>
#include "pico/stdlib.h"
#include "touch.h"
#include "tusb.h"

#define LED_PIN 6

touch touch;

int main()
{
    // Init stdio
    stdio_init_all();

    // Setup the blink pin
    gpio_init(LED_PIN);
    gpio_set_dir(LED_PIN, GPIO_OUT);

    // Initialize the touch controller
    touch.init();
    
    // Wait for user input
    while (!tud_cdc_connected())
    {
        printf(".");
        sleep_ms(500);
    }

    // Wait for the user to press enter
    printf("\nPress enter to continue.\n");
    getchar();

    // Get the product ID
    char product_id[5];
    touch.product_id(product_id, 4);
    printf("Product ID: %s\n", product_id);

    // Blink the LED
    while (1)
    {
        gpio_put(LED_PIN, 1);
        sleep_ms(250);
        gpio_put(LED_PIN, 0);
        sleep_ms(250);
    }
}
