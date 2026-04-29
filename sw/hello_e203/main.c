#include <stdint.h>

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
    while ((UART_LSR & (1u << 5)) == 0u) {
    }
    UART_THR = (uint32_t)(uint8_t)ch;
}

static void uart_puts(const char *text)
{
    while (*text != '\0') {
        uart_putc(*text++);
    }
}

int main(void)
{
    set_stage(1u);
    uart_init();
    uart_puts("\r\nhello_e203: boot\r\n");
    set_stage(0u);
    uart_puts("hello_e203: uart ok\r\n");
    set_stage(1u);
    uart_puts("hello_e203: loop\r\n");

    for (;;) {
        set_stage(1u);
        delay(200000u);
        set_stage(0u);
        delay(200000u);
    }
}
