# ISA 扩展定义

> 版本: 1.0 | 更新: 2026-03-26

---

## 4.1 指令概览

使用 RISC-V `custom0` (opcode=`0x0b`) 指令空间。

| 指令 | funct7 | 操作 | rd | rs1 | rs2 |
|------|--------|------|-----|-----|-----|
| **CLEAR** | `7'b0000100` | 清零累加器 | - | - | - |
| **WLOAD** | `7'b0000000` | 加载权重 | - | data | index |
| **DLOAD** | `7'b0000001` | 加载激活值 | - | data | index |
| **COMP** | `7'b0000010` | 触发计算 | - | - | - |
| **RSTAT** | `7'b0000011` | 读取结果 | dest | - | - |

---

## 4.2 指令编码

### RISC-V R-Type 格式

```
  31        25  24  20  19  15  14  12  11     7   6      0
┌──────────────┬───────┬───────┬────────┬────────┬─────────────┐
│   funct7     │  rs2  │  rs1  │ xs2/xs1/xd │  rd   │   opcode    │
│    7bit      │ 5bit  │ 5bit  │   3bit    │ 5bit  │   7bit      │
└──────────────┴───────┴───────┴────────┴────────┴─────────────┘

E203 NICE 特殊约定: bits[14:12] = xd/xs1/xs2 (不是 funct3!)
```

### CLEAR

```c
// .insn r 0x0b, 0, 4, x0, x0, x0
// opcode=0x0b, funct7=4, xd=0, xs1=0, xs2=0, rd=0, rs1=0, rs2=0
// Machine code: 0000000_00000_00000_000_00000_0001011
```

### WLOAD

```c
// .insn r 0x0b, 0, 0, x0, rs1, rs2
// opcode=0x0b, funct7=0, xd=0, xs1=1, xs2=1, rd=0
// rs1 = weight data (32bit, 4个INT8打包)
// rs2 = index (0-3，选择哪一列)
// Machine code: 0000000_rs2_rs1_011_00000_0001011
```

### DLOAD

```c
// .insn r 0x0b, 0, 1, x0, rs1, rs2
// opcode=0x0b, funct7=1, xd=0, xs1=1, xs2=1
// rs1 = activation data
// rs2 = index (0-3，选择哪一行)
```

### COMP

```c
// .insn r 0x0b, 0, 2, x0, x0, x0
// opcode=0x0b, funct7=2, xd=0, xs1=0, xs2=0
```

### RSTAT

```c
// .insn r 0x0b, 0, 3, rd, x0, x0
// opcode=0x0b, funct7=3, xd=1, xs1=0, xs2=0, rd=目标寄存器
```

---

## 4.3 软件驱动接口

### 头文件定义 (`sw/inc/cnn_accel.h`)

```c
#ifndef CNN_ACCEL_H
#define CNN_ACCEL_H

// NICE 指令宏 (使用 .insn r 格式)
#define CNN_CLEAR() do { \
    __asm__ volatile(".insn r 0x0b, 0, 4, x0, x0, x0" ::: "memory"); \
} while(0)

#define CNN_WLOAD(data, idx) do { \
    __asm__ volatile(".insn r 0x0b, 0, 0, x0, %0, %1" :: "r"(data), "r"(idx)); \
} while(0)

#define CNN_DLOAD(data, idx) do { \
    __asm__ volatile(".insn r 0x0b, 0, 1, x0, %0, %1" :: "r"(data), "r"(idx)); \
} while(0)

#define CNN_COMP() do { \
    __asm__ volatile(".insn r 0x0b, 0, 2, x0, x0, x0" ::: "memory"); \
} while(0)

#define CNN_RSTAT(rd) do { \
    __asm__ volatile(".insn r 0x0b, 0, 3, %0, x0, x0" : "=r"(rd)); \
} while(0)

#endif
```

### 使用示例

```c
#include "cnn_accel.h"

void cnn_conv4x4(int8_t* weights, int8_t* activations, int32_t* output) {
    int i;
    int32_t result;
    
    // 1. 清零
    CNN_CLEAR();
    
    // 2. 加载权重 (4列)
    for (i = 0; i < 4; i++) {
        CNN_WLOAD(*(int32_t*)(weights + i*4), i);
    }
    
    // 3. 加载激活值 (4行)
    for (i = 0; i < 4; i++) {
        CNN_DLOAD(*(int32_t*)(activations + i*4), i);
    }
    
    // 4. 计算
    CNN_COMP();
    
    // 5. 读取结果
    CNN_RSTAT(result);
    *output = result;
}
```

---

## 4.4 编码修正历史

| 日期 | 问题 | 修正 |
|------|------|------|
| 2026-03-20 | 最初用 funct3 编码 | 发现 E203 NICE 用 bits[14:12] 作为 xd/xs1/xs2 |
| 2026-03-20 | 修正后 | 将操作码从 funct3 移到 funct7 |

**教训**: E203 NICE 的编码约定和标准 RISC-V 不同，必须看官方文档!

---

## 4.5 funct7 操作码表

| funct7 | 操作 |
|--------|------|
| 0 | WLOAD |
| 1 | DLOAD |
| 2 | COMP |
| 3 | RSTAT |
| 4 | CLEAR |
| 5-127 | 保留 / 非法 |

---

*相关文档: `02_NICE_PROTOCOL.md`, `05_INTEGRATION.md`*
