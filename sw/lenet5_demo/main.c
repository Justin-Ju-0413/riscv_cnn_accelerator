/*
 * LeNet-5 MNIST Inference on RISC-V E203 + NICE CNN Accelerator
 *
 * Uses NICE 4x4 PE array for Conv1 & Conv2 (tiled 5x5 -> 4x4).
 * Pooling and FC layers in software.
 * Weights: INT8 quantized, 98.31% MNIST test accuracy.
 */
#include <stdint.h>
#include "../inc/custom_insn.h"
#include "../inc/lenet5_weights.h"
#include "../inc/lenet5_shifts.h"
#include "../inc/mnist_test_images.h"

/* --- Hardware registers --- */
#define GPIOA    0x10012000UL
#define UART0    0x10013000UL

#define GPIO_PADDIR  (*(volatile uint32_t *)(GPIOA + 0x00))
#define GPIO_PADOUT  (*(volatile uint32_t *)(GPIOA + 0x08))
#define GPIO_IOFCFG  (*(volatile uint32_t *)(GPIOA + 0x1c))
#define UART_THR     (*(volatile uint32_t *)(UART0 + 0x00))
#define UART_DLL     (*(volatile uint32_t *)(UART0 + 0x00))
#define UART_LCR     (*(volatile uint32_t *)(UART0 + 0x0c))
#define UART_FCR     (*(volatile uint32_t *)(UART0 + 0x08))
#define UART_LSR     (*(volatile uint32_t *)(UART0 + 0x14))

#define LED0 (1u << 0)

/* --- Pack 4x INT8 -> u32 (b0=LSB) --- */
static inline uint32_t p4(int8_t a, int8_t b, int8_t c, int8_t d) {
    return ((uint32_t)(uint8_t)a)
         | ((uint32_t)(uint8_t)b << 8)
         | ((uint32_t)(uint8_t)c << 16)
         | ((uint32_t)(uint8_t)d << 24);
}

/* --- NICE 4x4 tile MAC (no CLEAR - caller must CLEAR before first tile) --- */
static inline int32_t nice_4x4(const uint32_t w[4], const uint32_t d[4]) {
    int32_t r;
    ACC_WLOAD(w[0],0); ACC_WLOAD(w[1],1); ACC_WLOAD(w[2],2); ACC_WLOAD(w[3],3);
    ACC_DLOAD(d[0],0); ACC_DLOAD(d[1],1); ACC_DLOAD(d[2],2); ACC_DLOAD(d[3],3);
    ACC_COMP();
    ACC_RSTAT(r);
    return r;
}

/* ================================================================
 * NICE-accelerated KxK convolution (single input channel)
 * Kernel size K, input HxW, output (H-K+1)x(W-K+1)
 *
 * Decomposition: HW 4x4 MAC for top-left tile (up to 16 products),
 * remaining border elements computed in software. No overlap.
 * ================================================================ */
static void nice_conv(const int8_t *in, int H, int W,
                      const int8_t *kern, int K, int32_t bias,
                      int32_t *out, int relu)
{
    int Ho = H - K + 1, Wo = W - K + 1;

    /* Pre-build top-left 4x4 weight tile (zero-padded if K<4) */
    uint32_t kw[4];
    int hw_sz = (K < 4) ? K : 4;
    for (int ww = 0; ww < 4; ww++) {
        kw[ww] = p4(
            (ww<hw_sz && 0<hw_sz) ? kern[ww*K+0] : 0,
            (ww<hw_sz && 1<hw_sz) ? kern[ww*K+1] : 0,
            (ww<hw_sz && 2<hw_sz) ? kern[ww*K+2] : 0,
            (ww<hw_sz && 3<hw_sz) ? kern[ww*K+3] : 0);
    }

    for (int oy = 0; oy < Ho; oy++) {
        for (int ox = 0; ox < Wo; ox++) {
            int32_t result = 0;

            /* --- HW: top-left 4x4 tile --- */
            uint32_t dw[4];
            for (int ww = 0; ww < 4; ww++) {
                dw[ww] = p4(
                    (ww<hw_sz && 0<hw_sz) ? in[(oy+ww)*W+(ox+0)] : 0,
                    (ww<hw_sz && 1<hw_sz) ? in[(oy+ww)*W+(ox+1)] : 0,
                    (ww<hw_sz && 2<hw_sz) ? in[(oy+ww)*W+(ox+2)] : 0,
                    (ww<hw_sz && 3<hw_sz) ? in[(oy+ww)*W+(ox+3)] : 0);
            }
            ACC_CLEAR();
            result = nice_4x4(kw, dw);

            /* --- SW: remaining border (right cols + bottom rows, no overlap) --- */
            for (int ky = 0; ky < K; ky++)
                for (int kx = 4; kx < K; kx++)
                    result += (int32_t)kern[ky*K+kx] * (int32_t)in[(oy+ky)*W+(ox+kx)];
            for (int ky = 4; ky < K; ky++)
                for (int kx = 0; kx < hw_sz; kx++)
                    result += (int32_t)kern[ky*K+kx] * (int32_t)in[(oy+ky)*W+(ox+kx)];

            out[oy * Wo + ox] = (relu && (result + bias < 0)) ? 0 : (result + bias);
        }
    }
}

/* Software 2x2 max pool */
static void pool_2x2(const int32_t *in, int H, int W, int32_t *out) {
    int H2 = H / 2, W2 = W / 2;
    for (int y = 0; y < H2; y++)
        for (int x = 0; x < W2; x++) {
            int32_t m = in[(y*2)*W+(x*2)], v;
            v = in[(y*2)*W+(x*2+1)]; if (v>m) m=v;
            v = in[(y*2+1)*W+(x*2)]; if (v>m) m=v;
            v = in[(y*2+1)*W+(x*2+1)]; if (v>m) m=v;
            out[y*W2+x] = m;
        }
}

/* Software FC: INT8 weights * INT32 input -> INT32 output + optional ReLU
 * Uses INT64 accumulator to prevent overflow, then right-shifts to rescale.
 * The rescale factor (rshift) compensates for the INT8 weight scaling.
 */
static void fc(const int32_t *in, int Ni,
               const int8_t *w, const int32_t *b, int No,
               int32_t *out, int relu, int rshift)
{
    for (int j = 0; j < No; j++) {
        int64_t s = b ? (int64_t)b[j] : 0LL;
        for (int i = 0; i < Ni; i++) {
            s += (int64_t)w[j*Ni+i] * (int64_t)in[i];
        }
        s = s >> rshift;  // rescale
        out[j] = (relu && s < 0) ? 0 : (int32_t)s;
    }
}

/* Argmax */
static int argmax(const int32_t *v, int n) {
    int b = 0; int32_t bv = v[0];
    for (int i = 1; i < n; i++) { if (v[i] > bv) { bv = v[i]; b = i; } }
    return b;
}

/* --- UART --- */
static void uart_init(void) {
    GPIO_IOFCFG |= (1u<<16)|(1u<<17);
    UART_LCR=0x80; UART_DLL=27; UART_LCR=0x03; UART_FCR=0x06;
}
static void up(char c) { while(!(UART_LSR&(1u<<5))); UART_THR=(uint32_t)(uint8_t)c; }
static void us(const char *s) { while(*s) up(*s++); }
static void ud(int32_t v) {
    if(v<0){up('-');v=-v;}
    char b[12]; int i=0;
    do{b[i++]='0'+(v%10);v/=10;}while(v);
    while(i) up(b[--i]);
}

/* --- LED --- */
static void led(int on) {
    GPIO_PADDIR |= LED0;
    if(on) GPIO_PADOUT |= LED0; else GPIO_PADOUT &= ~LED0;
}

/* --- CPU reference convolution (no NICE, for cross-validation) --- */
static void cpu_conv(const int8_t *in, int H, int W,
                     const int8_t *kern, int K, int32_t bias,
                     int32_t *out, int relu)
{
    int Ho = H - K + 1, Wo = W - K + 1;
    for (int oy = 0; oy < Ho; oy++) {
        for (int ox = 0; ox < Wo; ox++) {
            int32_t sum = 0;
            for (int ky = 0; ky < K; ky++)
                for (int kx = 0; kx < K; kx++)
                    sum += (int32_t)kern[ky*K+kx] * (int32_t)in[(oy+ky)*W+(ox+kx)];
            out[oy*Wo+ox] = (relu && (sum + bias < 0)) ? 0 : (sum + bias);
        }
    }
}

/* ================================================================
 * LeNet-5 Main
 * ================================================================ */
int main(void) {
    uart_init(); led(1);

    us("\r\n========================================\r\n");
    us("LeNet-5 MNIST on E203 + NICE Accelerator\r\n");
    us("Version: v8 (fix Conv2 ReLU position + calibrated shifts)\r\n");
    us("========================================\r\n\r\n");

    /* --- Smoke test: verify nice_conv matches CPU reference --- */
    us("Self-check: nice_conv vs cpu_conv... ");
    {
        int8_t test_in[25];   /* 5x5 */
        int8_t test_k[25];    /* 5x5 */
        int32_t nice_out[1], cpu_out[1];
        for (int i = 0; i < 25; i++) { test_in[i] = (int8_t)((i % 7) - 3); }
        for (int i = 0; i < 25; i++) { test_k[i]  = (int8_t)((i % 5) - 2); }
        nice_conv(test_in, 5, 5, test_k, 5, 0, nice_out, 0);
        cpu_conv(test_in, 5, 5, test_k, 5, 0, cpu_out, 0);
        if (nice_out[0] == cpu_out[0]) {
            us("PASS (");
            ud(nice_out[0]);
            us(")\r\n\r\n");
        } else {
            us("FAIL: nice=");
            ud(nice_out[0]);
            us(" cpu=");
            ud(cpu_out[0]);
            us("\r\n");
            while(1) { led(0); for(volatile int i=0;i<1000000;i++); led(1); for(volatile int i=0;i<1000000;i++); }
        }
    }

    /* Working buffers (on stack - limited to ~32KB for DTCM safety) */
    int32_t fm1[6*24*24];    /* Conv1 output:  6x24x24 */
    int32_t p1[6*12*12];     /* Pool1 output:  6x12x12 */
    int32_t fm2[16*8*8];     /* Conv2 output: 16x8x8   */
    int32_t p2[16*4*4];      /* Pool2 output: 16x4x4   */
    int32_t f1[120], f2[84], f3[10];

    int ok = 0, n_img = 10;

    for (int n = 0; n < n_img; n++) {
        /* Select test image (stored as uint8 [0,255]) */
        const uint8_t *raw;
        switch(n) {
            case 0: raw=mnist_img_0; break; case 1: raw=mnist_img_1; break;
            case 2: raw=mnist_img_2; break; case 3: raw=mnist_img_3; break;
            case 4: raw=mnist_img_4; break; case 5: raw=mnist_img_5; break;
            case 6: raw=mnist_img_6; break; case 7: raw=mnist_img_7; break;
            case 8: raw=mnist_img_8; break; default: raw=mnist_img_9; break;
        }

        /* Convert uint8 pixel [0,255] -> signed int8 [-128,127] */
        int8_t img[784];
        for (int i = 0; i < 784; i++) img[i] = (int8_t)((int)raw[i] - 128);

        /* ---- Conv1 (NICE): 1x28x28 -> 6x24x24, kernel 5x5 ---- */
        for (int k = 0; k < 6; k++)
            nice_conv(img, 28, 28, &lenet5_conv1_weight[k*25], 5,
                      lenet5_conv1_bias[k], &fm1[k*24*24], 1);

        /* ---- Pool1: 6x24x24 -> 6x12x12 ---- */
        for (int k = 0; k < 6; k++)
            pool_2x2(&fm1[k*24*24], 24, 24, &p1[k*12*12]);

        /* ---- Conv2 (NICE): 6x12x12 -> 16x8x8, kernel 5x5 ---- */
        /* For each output channel, sum NICE conv over all 6 input channels */
        for (int ko = 0; ko < 16; ko++) {
            for (int y = 0; y < 8; y++)
                for (int x = 0; x < 8; x++)
                    fm2[ko*64 + y*8 + x] = lenet5_conv2_bias[ko];

            for (int ki = 0; ki < 6; ki++) {
                /* Extract ki-th channel from p1 and rebuild as int8 for conv */
                int8_t ch_in[144]; /* 12x12 */
                for (int i = 0; i < 144; i++) {
                    // Rescale INT32 pool output back to INT8 range
                    int32_t v = p1[ki*144 + i] >> CONV2_INPUT_RSHIFT;
                    if (v > 127) v = 127;
                    else if (v < -128) v = -128;
                    ch_in[i] = (int8_t)v;
                }
                const int8_t *kern = &lenet5_conv2_weight[(ko*6+ki)*25];
                int32_t tmp[64];
                nice_conv(ch_in, 12, 12, kern, 5, 0, tmp, 0);
                for (int i = 0; i < 64; i++) fm2[ko*64 + i] += tmp[i];
            }
            /* ReLU */
            for (int i = 0; i < 64; i++)
                if (fm2[ko*64 + i] < 0) fm2[ko*64 + i] = 0;
        }

        /* ---- Pool2: 16x8x8 -> 16x4x4 ---- */
        for (int k = 0; k < 16; k++)
            pool_2x2(&fm2[k*64], 8, 8, &p2[k*16]);

        /* ---- FC1: 256 -> 120 (software, INT64 acc) ---- */
        fc(p2, 256, lenet5_fc1_weight, lenet5_fc1_bias, 120, f1, 1, FC1_OUT_RSHIFT);

        /* ---- FC2: 120 -> 84 ---- */
        fc(f1, 120, lenet5_fc2_weight, lenet5_fc2_bias, 84, f2, 1, FC2_OUT_RSHIFT);

        /* ---- FC3: 84 -> 10 (no ReLU, raw logits) ---- */
        fc(f2, 84, lenet5_fc3_weight, lenet5_fc3_bias, 10, f3, 0, FC3_OUT_RSHIFT);

        /* ---- Classify ---- */
        int pred = argmax(f3, 10);
        int exp  = mnist_labels[n];

        us("Img "); ud(n);
        us(" pred="); ud(pred);
        us(" exp="); ud(exp);
        if (pred == exp) { us(" OK\r\n"); ok++; } else { us(" FAIL\r\n"); }
    }

    us("\r\nResult: "); ud(ok); us("/"); ud(n_img); us(" correct\r\n");
    if (ok == n_img) { us(">>> LeNet-5 DEMO PASSED <<<\r\n"); led(1); }
    else             { us("Accuracy: "); ud(ok*10); us("%\r\n"); }

    us("========================================\r\n");

    while (1) {
        for (volatile int i=0;i<500000;i++);
        led(0);
        for (volatile int i=0;i<500000;i++);
        led(1);
    }
    return 0;
}
