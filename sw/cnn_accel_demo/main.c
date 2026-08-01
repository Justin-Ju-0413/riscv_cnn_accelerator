#include <stdint.h>
#include "../inc/cnn_v1_demo.h"
#include "../inc/cnn_v1_benchmark.h"

#define GPIOA_BASE 0x10012000UL
#define GPIO_PADDIR (*(volatile uint32_t *)(GPIOA_BASE + 0x00))
#define GPIO_PADOUT (*(volatile uint32_t *)(GPIOA_BASE + 0x08))
#define GPIO_IOFCFG (*(volatile uint32_t *)(GPIOA_BASE + 0x1c))

#define UART0_BASE 0x10013000UL
#define UART_THR (*(volatile uint32_t *)(UART0_BASE + 0x00))
#define UART_DLL (*(volatile uint32_t *)(UART0_BASE + 0x00))
#define UART_DLM (*(volatile uint32_t *)(UART0_BASE + 0x04))
#define UART_FCR (*(volatile uint32_t *)(UART0_BASE + 0x08))
#define UART_LCR (*(volatile uint32_t *)(UART0_BASE + 0x0c))
#define UART_LSR (*(volatile uint32_t *)(UART0_BASE + 0x14))

#define LED0_MASK (1u << 0)
#define UART_RX_IOF_MASK (1u << 16)
#define UART_TX_IOF_MASK (1u << 17)

static void set_stage(uint32_t value)
{
    GPIO_PADDIR |= LED0_MASK;
    if (value & 1u) {
        GPIO_PADOUT |= LED0_MASK;
    } else {
        GPIO_PADOUT &= ~LED0_MASK;
    }
}

static void delay(volatile uint32_t cycles)
{
    while (cycles--) {
        __asm__ volatile ("nop");
    }
}

static void uart_init(void)
{
    GPIO_IOFCFG |= UART_RX_IOF_MASK | UART_TX_IOF_MASK;
    UART_LCR = 0x80u;
    UART_DLL = 138u;
    UART_DLM = 0u;
    UART_LCR = 0x03u;
    UART_FCR = 0x06u;
}

static void uart_putc(char ch)
{
    while ((UART_LSR & (1u << 5)) == 0u) {}
    UART_THR = (uint32_t)(uint8_t)ch;
}

static void uart_puts(const char *text)
{
    while (*text != '\0') {
        uart_putc(*text++);
    }
}

static void uart_putdec_u32(uint32_t u)
{
    char buf[16];
    int pos = 0;
    int i;

    if (u == 0) {
        uart_putc('0');
        return;
    }
    while (u > 0) {
        buf[pos++] = '0' + (u % 10);
        u /= 10;
    }
    for (i = pos - 1; i >= 0; i--) {
        uart_putc(buf[i]);
    }
}

static void uart_putdec32(int32_t val)
{
    if (val < 0) {
        uart_putc('-');
        uart_putdec_u32((uint32_t)(-val));
    } else {
        uart_putdec_u32((uint32_t)val);
    }
}

static int compare_feature_maps_2x2(const int32_t lhs[4], const int32_t rhs[4])
{
    int i;
    for (i = 0; i < 4; ++i) {
        if (lhs[i] != rhs[i]) {
            return 0;
        }
    }
    return 1;
}

int main(void)
{
    int32_t sw_output[4];
    int32_t hw_output[4];
    const int32_t *expected_output = CNN_V1_DEMO_ENABLE_RELU
        ? CNN_V1_DEMO_EXPECTED_RELU : CNN_V1_DEMO_EXPECTED_RAW;
    uint64_t cpu_cycles_64;
    uint64_t accel_cycles_64;
    uint32_t cpu_cycles;
    uint32_t accel_cycles;
    int sw_pass;
    int hw_pass;
    int i;

    set_stage(1u);
    uart_init();
    uart_puts("\r\ncnn_accel_demo: boot\r\n");

    uart_puts("Kernel: 3x3 INT8, Input: 4x4 INT8, Output: 2x2\r\n");
    uart_puts("ReLU: ");
    uart_puts(CNN_V1_DEMO_ENABLE_RELU ? "on\r\n" : "off\r\n");

    /* CPU reference */
    set_stage(0u);
    cpu_cycles_64 = cnn_v1_measure_reference_conv3x3_4x4(
        CNN_V1_DEMO_INPUT, CNN_V1_DEMO_KERNEL,
        sw_output, CNN_V1_DEMO_ENABLE_RELU);
    cpu_cycles = (uint32_t)cpu_cycles_64;
    uart_puts("CPU reference done, cycles=");
    uart_putdec_u32(cpu_cycles);
    uart_puts("\r\n");

    /* Accelerator */
    set_stage(1u);
    accel_cycles_64 = cnn_v1_measure_accel_conv3x3_4x4(
        CNN_V1_DEMO_INPUT, CNN_V1_DEMO_KERNEL,
        hw_output, CNN_V1_DEMO_ENABLE_RELU);
    accel_cycles = (uint32_t)accel_cycles_64;
    uart_puts("Accelerator done, cycles=");
    uart_putdec_u32(accel_cycles);
    uart_puts("\r\n");

    /* Print results */
    uart_puts("SW output:");
    for (i = 0; i < 4; i++) {
        uart_putc(' ');
        uart_putdec32(sw_output[i]);
    }
    uart_puts("\r\n");

    uart_puts("HW output:");
    for (i = 0; i < 4; i++) {
        uart_putc(' ');
        uart_putdec32(hw_output[i]);
    }
    uart_puts("\r\n");

    uart_puts("Expected :");
    for (i = 0; i < 4; i++) {
        uart_putc(' ');
        uart_putdec32(expected_output[i]);
    }
    uart_puts("\r\n");

    /* Speedup */
    if (accel_cycles > 0 && accel_cycles < 0xFFFFFFFFUL / 1000UL) {
        uint32_t speedup_x1000 = (cpu_cycles * 1000UL) / accel_cycles;
        uart_puts("Speedup: ");
        uart_putdec_u32(speedup_x1000 / 1000);
        uart_putc('.');
        uart_putdec_u32(speedup_x1000 % 1000);
        uart_puts(" x\r\n");
    } else if (accel_cycles > 0) {
        uart_puts("Speedup: (overflow, use simulation)\r\n");
    }

    /* Verdict */
    sw_pass = compare_feature_maps_2x2(sw_output, expected_output);
    hw_pass = compare_feature_maps_2x2(hw_output, expected_output);

    if (sw_pass && hw_pass) {
        uart_puts(">>> CNN v1 DEMO PASSED <<<\r\n");
    } else {
        uart_puts(">>> CNN v1 DEMO FAILED <<<");
        if (!sw_pass) uart_puts(" (SW mismatch)");
        if (!hw_pass) uart_puts(" (HW mismatch)");
        uart_puts("\r\n");
    }

    /* Loop with LED heartbeat */
    for (;;) {
        set_stage(1u);
        delay(200000u);
        set_stage(0u);
        delay(200000u);
    }
}
