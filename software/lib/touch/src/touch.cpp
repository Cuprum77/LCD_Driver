#include "touch.h"

/**
 * @brief Create a new touch controller.
 * 
 * @param inst The I2C instance.
 * @param i2c_speed The speed of the I2C bus.
 * @param i2c_sda The SDA pin.
 * @param i2c_scl The SCL pin.
 * @param i2c_rst The RST pin.
 * @param i2c_int The INT pin.
 * 
 * @note All parameters are optional and have default values.
 * @note The library will attempt to get the address 0xba and 0xbb.
 */
touch::touch(i2c_inst_t *inst, uint i2c_speed, uint i2c_sda, uint i2c_scl, uint i2c_rst, uint i2c_int)
{
    // Save the parameters
    this->inst = inst;
    this->i2c_speed = i2c_speed;
    this->i2c_sda = i2c_sda;
    this->i2c_scl = i2c_scl;
    this->i2c_rst = i2c_rst;
    this->i2c_int = i2c_int;
}

/**
 * @brief Initialize the touch controller.
 */
void touch::init()
{
    // Setup I2C
    i2c_init(inst, i2c_speed);
    gpio_set_function(i2c_sda, GPIO_FUNC_I2C);
    gpio_set_function(i2c_scl, GPIO_FUNC_I2C);
    gpio_pull_up(i2c_sda);
    gpio_pull_up(i2c_scl);

    // Setup the reset pin
    gpio_init(i2c_rst);
    gpio_set_dir(i2c_rst, GPIO_OUT);

    // Setup the interrupt pin
    gpio_init(i2c_int);
    gpio_set_dir(i2c_int, GPIO_IN);

    // Reset the touch controller
    this->reset();
}

/**
 * @brief Reset the touch controller.
 * 
 * @param i2c_rst The RST pin.
 */
void touch::reset()
{
    // Reset the touch controller
    gpio_put(this->i2c_rst, 0);
    sleep_us(100);
    gpio_put(this->i2c_rst, 1);
}

/**
 * @brief Read the product ID.
 * 
 * @param buffer The buffer to read into.
 * @param size The size of the buffer.
 * 
 * @return True if the product ID is valid.
 */ 
bool touch::product_id(char* buffer, size_t size)
{
    // If size is less than 4, return false
    if (size < 4)
        return false;
    // Read the product ID
    int ret = this->read_reg(TOUCH_REG_PRODUCT_ID, (unsigned char*)buffer, 4);
    return true;
}

/**
 * @private
 * @brief Write data to a register.
 * 
 * @param data The data to write.
 * @param size The size of the data.
 * 
 * @return The number of bytes written.
 */
int touch::write_reg(unsigned short reg, unsigned char* data, size_t size)
{
    // Pack the register
    unsigned char reg_data[2];
    reg_data[0] = reg >> 8;
    reg_data[1] = reg & 0xff;
    // Write the register
    int ret = i2c_write_blocking(inst, I2C_ADDR, reg_data, 2, true);
    // Write the word
    ret += i2c_write_blocking(inst, I2C_ADDR, data, size, false);
    return ret;
}

/**
 * @private
 * @brief Read data from a register.
 * 
 * @param data The data to read into.
 * @param size The size of the data.
 * 
 * @return The number of bytes read.
 */
int touch::read_reg(unsigned short reg, unsigned char* data, size_t size)
{
    // Pack the register
    unsigned char reg_data[2];
    reg_data[0] = reg >> 8;
    reg_data[1] = reg & 0xff;
    // Write the register
    int ret = i2c_write_blocking(inst, I2C_ADDR, reg_data, 2, false);
    // Read the word
    ret += i2c_read_blocking(inst, I2C_ADDR, data, size, false);
    return ret;
}