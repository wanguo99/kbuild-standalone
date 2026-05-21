# Kbuild Framework 使用指南

## 概述

这是从Linux内核提取的通用构建框架，支持构建：
- 静态库（.a）
- 共享库（.so）
- 可执行文件
- 内核模块（.ko）

## 核心特性

### 1. 完整的依赖跟踪
- 使用fixdep工具精确跟踪头文件依赖
- 自动检测编译选项变化
- 支持CONFIG_变量依赖（如果使用Kconfig）

### 2. Out-of-tree构建
```bash
make O=/tmp/build
```
所有构建产物生成在指定目录，保持源码树干净。

### 3. 交叉编译支持
```bash
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-
```

### 4. 并行构建
```bash
make -j$(nproc)
```

### 5. 静默/详细输出
```bash
make          # 静默模式
make V=1      # 详细模式
```

## 语法参考

### 静态库（lib-y）

```makefile
# 库名称
lib-y += mylib

# 源文件列表
mylib-y := \
    file1.o \
    file2.o \
    file3.o

# 条件编译
mylib-$(CONFIG_FEATURE_A) += feature_a.o

# 编译标志
ccflags-y := -I$(src)/include

# 链接标志
LDLIBS_libmylib.a := -lpthread
```

**输出**：`lib/libmylib.a`

### 共享库（so-y）

```makefile
# 库名称
so-y += mylib

# 源文件列表（可与静态库共享）
mylib-y := \
    api.o \
    impl.o

# SONAME设置
LDFLAGS_libmylib.so := -Wl,-soname,libmylib.so.1

# 链接库
LDLIBS_libmylib.so := -lpthread -lrt
```

**输出**：`lib/libmylib.so`

### 可执行文件（bin-y）

```makefile
# 程序名称
bin-y += myapp

# 源文件列表
myapp-y := \
    main.o \
    logic.o \
    utils.o

# 编译标志
ccflags-y := -I$(srctree)/include

# 链接库
LDLIBS_myapp := -L$(LIB_DIR) -lmylib -lm

# 链接标志
LDFLAGS_myapp := -pie
```

**输出**：`bin/myapp`

### 内核模块（obj-m）

```makefile
# 模块名称
obj-m += mydriver.o

# 源文件列表
mydriver-y := \
    main.o \
    device.o \
    ops.o

# 编译标志
ccflags-y := -I$(src)/include
```

**输出**：`ko/mydriver.ko`

### 子目录递归

```makefile
# 总是递归
obj-y += subdir/

# 条件递归
obj-$(CONFIG_FEATURE) += feature_subdir/
```

## 变量参考

### 编译标志

| 变量 | 作用域 | 说明 |
|------|--------|------|
| `ccflags-y` | 当前目录 | C编译标志 |
| `asflags-y` | 当前目录 | 汇编标志 |
| `ldflags-y` | 当前目录 | 链接标志 |
| `CFLAGS_file.o` | 单个文件 | 特定文件的编译标志 |

### 链接选项

| 变量 | 说明 |
|------|------|
| `LDFLAGS_target` | 特定目标的链接标志 |
| `LDLIBS_target` | 特定目标的链接库 |

### 路径变量

| 变量 | 说明 |
|------|------|
| `$(srctree)` | 源码树根目录 |
| `$(objtree)` | 对象树根目录 |
| `$(src)` | 当前源码目录 |
| `$(obj)` | 当前对象目录 |
| `$(LIB_DIR)` | 库输出目录 |
| `$(BIN_DIR)` | 可执行文件输出目录 |
| `$(KO_DIR)` | 内核模块输出目录 |

## 完整示例

### 示例1：简单静态库

```makefile
# mylib/Makefile

lib-y += utils

utils-y := \
    string.o \
    math.o

ccflags-y := -I$(src)/include
```

### 示例2：带条件编译的库

```makefile
# mylib/Makefile

lib-y += mylib

mylib-y := core.o

# 条件编译
mylib-$(CONFIG_FEATURE_NET) += network.o
mylib-$(CONFIG_FEATURE_FILE) += file.o

ccflags-y := -I$(src)/include
ccflags-$(CONFIG_DEBUG) += -DDEBUG
```

### 示例3：可执行文件链接库

```makefile
# myapp/Makefile

bin-y += myapp

myapp-y := \
    main.o \
    app_logic.o

ccflags-y := -I$(srctree)/mylib/include
LDLIBS_myapp := -L$(LIB_DIR) -lmylib -lpthread
```

### 示例4：混合项目

```makefile
# 顶层Makefile

# 先构建库
obj-y += lib/

# 再构建应用（依赖库）
obj-y += app/

# 可选的驱动模块
obj-$(CONFIG_DRIVER) += drivers/
```

## 构建流程

### 1. 首次构建
```bash
cd /home/wanguo/kbuild
make
```

### 2. 增量构建
修改源文件后直接运行：
```bash
make
```
只会重新编译变化的文件。

### 3. 清理
```bash
make clean      # 清理构建产物
make mrproper   # 完全清理（包括生成的文件）
```

### 4. 查看帮助
```bash
make help
```

## 高级用法

### 1. 调试构建过程
```bash
make V=1        # 显示完整命令
make V=2        # 显示更多调试信息
```

### 2. 只构建特定目标
```bash
make examples/lib/      # 只构建lib
make examples/tools/    # 只构建tools
```

### 3. 并行构建
```bash
make -j8        # 使用8个并行任务
make -j$(nproc) # 使用所有CPU核心
```

### 4. Out-of-tree构建
```bash
make O=/tmp/build defconfig
make O=/tmp/build -j$(nproc)
```

## 最佳实践

### 1. 目录组织
```
project/
├── Makefile              # 顶层Makefile
├── lib/                  # 库
│   ├── Makefile
│   ├── include/          # 公共头文件
│   └── *.c
├── app/                  # 应用
│   ├── Makefile
│   └── *.c
└── drivers/              # 驱动（可选）
    ├── Makefile
    └── *.c
```

### 2. 头文件管理
- 公共头文件放在 `include/` 目录
- 私有头文件放在源码目录
- 使用 `ccflags-y` 添加包含路径

### 3. 库依赖管理
- 先构建被依赖的库
- 使用 `LDLIBS_target` 指定链接库
- 使用 `-L$(LIB_DIR)` 指定库搜索路径

### 4. 条件编译
- 优先使用 `xxx-$(CONFIG_YYY)` 语法
- 避免使用 `ifeq` 判断
- 保持Makefile简洁

## 故障排查

### 问题1：找不到头文件
**解决**：检查 `ccflags-y` 是否正确设置包含路径

### 问题2：链接时找不到库
**解决**：
1. 确保库已经构建
2. 检查 `LDLIBS_target` 是否正确
3. 检查 `-L$(LIB_DIR)` 路径

### 问题3：修改头文件后没有重新编译
**解决**：这不应该发生，fixdep会自动跟踪。如果发生，运行 `make clean && make`

### 问题4：Out-of-tree构建失败
**解决**：确保使用绝对路径：`make O=/absolute/path`

## 与EMS项目集成

如果要将此框架集成到EMS项目：

1. **复制核心脚本**
```bash
cp -r /home/wanguo/kbuild/scripts /home/wanguo/EMS/
```

2. **更新顶层Makefile**
参考 `/home/wanguo/kbuild/Makefile`

3. **迁移模块Makefile**
使用迁移脚本或手动转换：
- `obj-s` → `lib-y`
- `obj-d` → `so-y`
- `obj-e` → `bin-y`

4. **测试验证**
```bash
cd /home/wanguo/EMS
make clean
make -j$(nproc)
```

## 参考资料

- Linux内核Kbuild文档：`Documentation/kbuild/`
- 示例项目：`/home/wanguo/kbuild/examples/`
- EMS优化方案：`/home/wanguo/.claude/plans/ems-kbuild-optimization.md`
