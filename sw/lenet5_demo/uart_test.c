/*
 * Minimal UART test - prints "ABCD" in a loop
 * Uses DLL=9 for 115200-ish @ 16MHz
 */
#define GPIOA_BASE 0x10012000UL
#define GPIO_PADDIR (*(volatile unsigned*)(GPIOA_BASE + 0x00))
#define GPIO_PADOUT (*(volatile unsigned*)(GPIOA_BASE + 0x08))
#define GPIO_IOFCFG (*(volatile unsigned*)(GPIOA_BASE + 0x1c))

#define UART0_BASE 0x10013000UL
#define UART_THR (*(volatile unsigned*)(UART0_BASE + 0x00))
#define UART_DLL (*(volatile unsigned*)(UART0_BASE + 0x00))
#define UART_LCR (*(volatile unsigned*)(UART0_BASE + 0x0c))
#define UART_FCR (*(volatile unsigned*)(UART0_BASE + 0x08))
#define UART_LSR (*(volatile unsigned*)(UART0_BASE + 0x14))

static void uart_putc(char c) {
    while(!(UART_LSR & (1u<<5)));
    UART_THR = (unsigned)(unsigned char)c;
}
static void uart_puts(const char *s) {
    while(*s) uart_putc(*s++);
}

int main(void) {
    GPIO_IOFCFG |= (1u<<16)|(1u<<17);
    UART_LCR = 0x80u;
    UART_DLL = 9u;
    UART_LCR = 0x03u;
    UART_FCR = 0x06u;

    volatile unsigned delay;
    for(delay=0; delay<5000000; delay++) __asm__ volatile("nop");  // ~1 sec delay

    while(1) {
        uart_puts("\r\nABCD uart_test DLL=9 @16MHz \r\n");
        for(delay=0; delay<2000000; delay++) __asm__ volatile("nop");
    }
    return 0;
}
