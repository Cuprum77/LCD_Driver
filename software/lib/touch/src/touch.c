#include "touch.h"

// Register addresses
volatile struct touch_reg_addr_t touch_reg_addr = touch_reg_addr_init;
// Offsets for the points
volatile struct touch_reg_offsets_t touch_reg_offsets = touch_reg_offsets_init;
// I2C data
volatile struct touch_i2c_data_s touch_i2c_data;
// Chip data
volatile struct touch_chip_data_s touch_chip_data;
// Status register data
volatile struct touch_status_data_s touch_status_data;
// Point data
volatile struct touch_point_data_s touch_points[5];

/**
 * @brief Initialize the touch controller.
 * @param inst The I2C instance.
 * @param i2c_speed The I2C speed.
 * @param i2c_sda The I2C SDA pin.
 * @param i2c_scl The I2C SCL pin.
 * @param i2c_rst The I2C RST pin.
 * @param i2c_int The I2C INT pin.
 */
void touch_init(i2c_inst_t *inst, uint i2c_speed, 
	uint i2c_sda, uint i2c_scl, 
	uint i2c_rst, uint i2c_int
)
{
    // Store the I2C data
    touch_i2c_data.inst = inst;
    touch_i2c_data.i2c_speed = i2c_speed;
    touch_i2c_data.i2c_sda = i2c_sda;
    touch_i2c_data.i2c_scl = i2c_scl;
    touch_i2c_data.i2c_rst = i2c_rst;
    touch_i2c_data.i2c_int = i2c_int;

    // Setup I2C
    i2c_init(touch_i2c_data.inst, touch_i2c_data.i2c_speed);
    gpio_set_function(touch_i2c_data.i2c_sda, GPIO_FUNC_I2C);
    gpio_set_function(touch_i2c_data.i2c_scl, GPIO_FUNC_I2C);
    gpio_pull_up(touch_i2c_data.i2c_sda);
    gpio_pull_up(touch_i2c_data.i2c_scl);

    // Setup the reset pin
    gpio_init(touch_i2c_data.i2c_rst);
    gpio_set_dir(touch_i2c_data.i2c_rst, GPIO_OUT);

    // Setup the interrupt pin
    gpio_init(touch_i2c_data.i2c_int);
    gpio_set_dir(touch_i2c_data.i2c_int, GPIO_IN);

    // Reset the touch controller
    touch_reset();

    // Attach the interrupt handler
    gpio_set_irq_enabled_with_callback(touch_i2c_data.i2c_int, GPIO_IRQ_EDGE_FALL, true, &touch_irq_handler);

    // Configure the chip

    // Set the number of touches to 5
    touch_write_reg(touch_reg_addr.touch_num, (unsigned char*)5, 1);

    // Get the chip data
    unsigned char buffer[11];
    touch_read_reg(touch_reg_addr.product_id, buffer, 4);
    touch_read_reg(touch_reg_addr.firmware_id, buffer + 4, 2);
    touch_read_reg(touch_reg_addr.x_res, buffer + 6, 2);
    touch_read_reg(touch_reg_addr.y_res, buffer + 8, 2);
    touch_read_reg(touch_reg_addr.vendor_id, buffer + 10, 1);

    // Unpack the chip data
    for(int i = 0; i < 4; i++)
    {
        touch_chip_data.product_id[i] = buffer[i];
    }
    touch_chip_data.firmware_version = buffer[4] | buffer[5] << 8;
    touch_chip_data.x_resolution = buffer[6] | buffer[7] << 8;
    touch_chip_data.y_resolution = buffer[8] | buffer[9] << 8;
    touch_chip_data.vendor_id = buffer[10];
}

/**
 * @brief Reset the touch controller.
 * @param i2c_rst The RST pin.
 */
void touch_reset()
{
    // Reset the touch controller
    gpio_put(touch_i2c_data.i2c_rst, 0);
    sleep_us(100);
    gpio_put(touch_i2c_data.i2c_rst, 1);
    // Wait for the touch controller to reset
    sleep_ms(50);
}

/**
 * @brief Write data to a register.
 * @param data The data to write.
 * @param size The size of the data.
 * @return The number of bytes written.
 */
int touch_write_reg(unsigned short reg, unsigned char* data, size_t size)
{
    // Pack the register
    unsigned char reg_data[2 + size];
    reg_data[0] = reg >> 8;
    reg_data[1] = reg & 0xff;

    // Copy the data
    for(int i = 0; i < size; i++)
    {
        reg_data[i + 2] = data[i];
    }

    // Write the register
    int ret = i2c_write_blocking(touch_i2c_data.inst, TOUCH_I2C_ADDR, reg_data, size + 2, false);
    return ret;
}

/**
 * @brief Read data from a register.
 * @param data The data to read into.
 * @param size The size of the data.
 * @return The number of bytes read.
 */
int touch_read_reg(unsigned short reg, unsigned char* data, size_t size)
{
    // Pack the register
    unsigned char reg_data[2];
    reg_data[0] = reg >> 8;
    reg_data[1] = reg & 0xff;
    // Write the register
    int ret = i2c_write_blocking(touch_i2c_data.inst, TOUCH_I2C_ADDR, reg_data, 2, false);
    // Read the word
    ret += i2c_read_blocking(touch_i2c_data.inst, TOUCH_I2C_ADDR, data, size, false);
    return ret;
}

/**
 * @brief Get all the points from the touch controller.
 * @return The number of bytes read.
 * @note This function gets called from the interrupt handler.
*/
int touch_get_all_points()
{
    // Create a variable to store the number of bytes read
    int bytes = 0;

    // Read the status register
    unsigned char status;
    bytes += touch_read_reg(touch_reg_addr.status, &status, 1);

    // Unpack the status register
    touch_status_data.buffer_status = (status >> 7) & 0x01;
    touch_status_data.large_detect = (status >> 6) & 0x01;
    touch_status_data.proximity_valid = (status >> 5) & 0x01;
    touch_status_data.have_key = (status >> 4) & 0x01;
    touch_status_data.num_touches = status & 0x0f;

    // Loop through all the 5 points
    for(int i = 0; i < 5; i++)
    {
        // Buffer to store the point data
        volatile unsigned char point_data[7];

        // Read the point data
        bytes += touch_read_reg(touch_reg_addr.ptr_addr.touch[i], 
            (unsigned char*)point_data, 7
        );
        // Unpack the point data
        touch_points[i].track_id = point_data[touch_reg_offsets.track_id];
        touch_points[i].x = point_data[touch_reg_offsets.xl];
        touch_points[i].x += point_data[touch_reg_offsets.xh] << 8;
        touch_points[i].y = point_data[touch_reg_offsets.yl];
        touch_points[i].y += point_data[touch_reg_offsets.yh] << 8;
        touch_points[i].size = point_data[touch_reg_offsets.size_l];
        touch_points[i].size += point_data[touch_reg_offsets.size_h] << 8;
    }

    // Reset the register as per the datasheet
    status = 0;
    // Write the status register
    bytes += touch_write_reg(touch_reg_addr.status, &status, 1);    

    // Return the number of bytes read
    return bytes;
}

/**
 * @brief The interrupt handler for the touch controller.
 * @note This is an interrupt handler and shouldn't be called outside of the library.
*/
void touch_irq_handler(uint gpio, uint32_t events)
{
    touch_get_all_points();
}