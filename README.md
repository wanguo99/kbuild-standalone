# Kbuild Framework

从Linux内核提取的通用构建框架，支持：
- ✅ 静态库（lib-y）
- ✅ 共享库（so-y）
- ✅ 可执行文件（bin-y）
- ✅ 内核模块（obj-m）

## 快速开始

```bash
# 编译所有示例
make

# 详细输出
make V=1

# Out-of-tree构建
make O=/tmp/build

# 交叉编译
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-

# 清理
make clean
```

## 目录结构

```
kbuild/
├── Makefile                    # 顶层Makefile
├── scripts/
│   ├── Kbuild.include         # 核心辅助函数
│   ├── Makefile.build         # 递归构建引擎
│   ├── Makefile.lib           # 通用规则和函数
│   ├── Makefile.clean         # 清理规则
│   ├── Makefile.host          # 主机工具编译
│   ├── basic/
│   │   ├── fixdep             # 依赖跟踪工具
│   │   └── Makefile
│   └── include/               # 辅助头文件
├── examples/
│   ├── lib/                   # 静态库示例
│   └── tools/                 # 可执行文件示例
├── bin/                       # 可执行文件输出
├── lib/                       # 库文件输出
└── ko/                        # 内核模块输出
```

## 语法示例

### 静态库

```makefile
# examples/lib/Makefile

lib-y += mylib

mylib-y := \
    file1.o \
    file2.o

ccflags-y := -I$(src)/include
```

### 可执行文件

```makefile
# examples/tools/Makefile

bin-y += myapp

myapp-y := \
    main.o \
    logic.o

ccflags-y := -I$(srctree)/examples/lib/include
LDLIBS_myapp := -L$(LIB_DIR) -lmylib
```

### 共享库

```makefile
so-y += mylib

mylib-y := \
    api.o \
    impl.o

LDFLAGS_libmylib.so := -Wl,-soname,libmylib.so.1
```

### 内核模块

```makefile
obj-m += mydriver.o

mydriver-y := \
    main.o \
    device.o
```

## 特性

- ✅ 完整的依赖跟踪（fixdep）
- ✅ Out-of-tree构建支持
- ✅ 交叉编译支持
- ✅ 并行构建支持（make -j）
- ✅ 静默/详细输出切换
- ✅ 与Linux内核Kbuild语法100%兼容

## 文档

详细文档请参考 `Documentation/` 目录。
