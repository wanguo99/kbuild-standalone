# SPDX-License-Identifier: GPL-2.0
# =============================================================================
# Kbuild Framework - Top-level Makefile
# =============================================================================
# 支持: lib库文件(.a)、共享库(.so)、可执行文件、内核模块(.ko)
# =============================================================================

VERSION = 1
PATCHLEVEL = 0
SUBLEVEL = 0
EXTRAVERSION =
NAME = Kbuild-Framework

# =============================================================================
# 基础设置
# =============================================================================

# 禁用 make 内置规则和变量
MAKEFLAGS += -rR --include-dir=$(CURDIR)

# 避免字符集依赖
unexport LC_ALL
LC_COLLATE=C
LC_NUMERIC=C
export LC_COLLATE LC_NUMERIC

# 避免环境变量干扰
unexport GREP_OPTIONS

# =============================================================================
# 静默构建支持 (V=0 静默, V=1 详细)
# =============================================================================

ifeq ("$(origin V)", "command line")
  KBUILD_VERBOSE = $(V)
endif
ifndef KBUILD_VERBOSE
  KBUILD_VERBOSE = 0
endif

ifeq ($(KBUILD_VERBOSE),1)
  quiet =
  Q =
else
  quiet=quiet_
  Q = @
endif

# 检测 make -s (静默模式)
ifneq ($(filter 4.%,$(MAKE_VERSION)),)
ifneq ($(filter %s ,$(firstword x$(MAKEFLAGS))),)
  quiet=silent_
endif
else
ifneq ($(filter s% -s%,$(MAKEFLAGS)),)
  quiet=silent_
endif
endif

export quiet Q KBUILD_VERBOSE

# =============================================================================
# Out-of-tree 构建支持 (O=dir)
# =============================================================================

ifeq ($(KBUILD_SRC),)

# 在源码目录调用 make
ifeq ("$(origin O)", "command line")
  KBUILD_OUTPUT := $(O)
endif

# 默认目标
PHONY := _all
_all:

# 取消顶层 Makefile 的隐式规则
$(CURDIR)/Makefile Makefile: ;

# 检查目录路径中不能包含空格或冒号
ifneq ($(words $(subst :, ,$(CURDIR))), 1)
  $(error main directory cannot contain spaces nor colons)
endif

# Out-of-tree 构建逻辑
ifneq ($(KBUILD_OUTPUT),)
saved-output := $(KBUILD_OUTPUT)
KBUILD_OUTPUT := $(shell mkdir -p $(KBUILD_OUTPUT) && cd $(KBUILD_OUTPUT) && /bin/pwd)
$(if $(KBUILD_OUTPUT),, \
     $(error failed to create output directory "$(saved-output)"))

PHONY += $(MAKECMDGOALS) sub-make

$(filter-out _all sub-make $(CURDIR)/Makefile, $(MAKECMDGOALS)) _all: sub-make
	@:

sub-make:
	$(Q)$(MAKE) -C $(KBUILD_OUTPUT) KBUILD_SRC=$(CURDIR) \
	-f $(CURDIR)/Makefile $(filter-out _all sub-make,$(MAKECMDGOALS))

skip-makefile := 1
endif # ifneq ($(KBUILD_OUTPUT),)
endif # ifeq ($(KBUILD_SRC),)

# =============================================================================
# 主构建逻辑
# =============================================================================
ifeq ($(skip-makefile),)

# 不打印 "Entering directory ..."
MAKEFLAGS += --no-print-directory

PHONY += all
_all: all

# 设置源码树和对象树路径
ifeq ($(KBUILD_SRC),)
        srctree := .
else
        ifeq ($(KBUILD_SRC)/,$(dir $(CURDIR)))
                srctree := ..
        else
                srctree := $(KBUILD_SRC)
        endif
endif

objtree		:= .
src		:= $(srctree)
obj		:= $(objtree)

VPATH		:= $(srctree)

export srctree objtree VPATH

# Enable built-in and module support
KBUILD_BUILTIN := 1
KBUILD_MODULES := 1

export KBUILD_BUILTIN KBUILD_MODULES

# =============================================================================
# 工具链配置
# =============================================================================

# 架构和交叉编译
ARCH		?= $(shell uname -m)
CROSS_COMPILE	?=

# 工具链
AS		= $(CROSS_COMPILE)as
LD		= $(CROSS_COMPILE)ld
CC		= $(CROSS_COMPILE)gcc
CXX		= $(CROSS_COMPILE)g++
CPP		= $(CC) -E
AR		= $(CROSS_COMPILE)ar
NM		= $(CROSS_COMPILE)nm
STRIP		= $(CROSS_COMPILE)strip
OBJCOPY		= $(CROSS_COMPILE)objcopy
OBJDUMP		= $(CROSS_COMPILE)objdump
AWK		= awk
PERL		= perl
PYTHON		= python3

export ARCH CROSS_COMPILE
export AS LD CC CXX CPP AR NM STRIP OBJCOPY OBJDUMP
export AWK PERL PYTHON

# 主机编译器（用于构建工具）
HOSTCC       = gcc
HOSTCXX      = g++
HOSTCFLAGS   = -Wall -Wmissing-prototypes -Wstrict-prototypes -O2 \
               -fomit-frame-pointer -std=gnu11
HOSTCXXFLAGS = -O2

export HOSTCC HOSTCXX HOSTCFLAGS HOSTCXXFLAGS

# =============================================================================
# 编译标志
# =============================================================================

# 头文件包含路径
KBUILD_INCLUDE := -I$(srctree)/include \
                  $(if $(KBUILD_SRC), -I$(srctree)/include) \
                  -I$(objtree)/include/generated

# C 编译标志
KBUILD_CFLAGS   := -Wall -Wundef -Werror-implicit-function-declaration \
                   -Wno-trigraphs -fno-strict-aliasing -fno-common \
                   -Wno-format-security -std=gnu11

# C++ 编译标志
KBUILD_CXXFLAGS := -Wall -Wundef -fno-strict-aliasing -fno-common -std=c++11

# 汇编标志
KBUILD_AFLAGS   := -D__ASSEMBLY__

# 链接标志
KBUILD_LDFLAGS  :=

# 模块编译标志
KBUILD_CFLAGS_MODULE := -fPIC -DMODULE
KBUILD_LDFLAGS_MODULE := -r

# 共享库编译标志
KBUILD_CFLAGS_SO := -fPIC
KBUILD_LDFLAGS_SO := -shared

# 可执行文件编译标志
KBUILD_CFLAGS_BIN := -fPIE
KBUILD_LDFLAGS_BIN := -pie

export KBUILD_INCLUDE KBUILD_CFLAGS KBUILD_CXXFLAGS KBUILD_AFLAGS KBUILD_LDFLAGS
export KBUILD_CFLAGS_MODULE KBUILD_LDFLAGS_MODULE
export KBUILD_CFLAGS_SO KBUILD_LDFLAGS_SO
export KBUILD_CFLAGS_BIN KBUILD_LDFLAGS_BIN

# =============================================================================
# 输出目录配置
# =============================================================================

BIN_DIR := $(objtree)/bin
LIB_DIR := $(objtree)/lib
KO_DIR  := $(objtree)/ko

export BIN_DIR LIB_DIR KO_DIR

# =============================================================================
# 包含核心定义
# =============================================================================

scripts/Kbuild.include: ;
include scripts/Kbuild.include

# =============================================================================
# 构建目标
# =============================================================================

# 需要构建的子目录
core-y		:= examples/

# 默认目标
PHONY += all
all: scripts_basic $(core-y)
	@echo "  Build complete"

# 构建基础工具（fixdep）
PHONY += scripts_basic
scripts_basic:
	$(Q)$(MAKE) $(build)=scripts/basic

# 递归构建子目录
$(core-y): scripts_basic
	$(Q)$(MAKE) $(build)=$@

# =============================================================================
# 清理目标
# =============================================================================

PHONY += clean
clean:
	$(Q)$(MAKE) $(clean)=examples
	$(Q)rm -rf $(BIN_DIR) $(LIB_DIR) $(KO_DIR)
	$(Q)find . \( -name '*.[oas]' -o -name '*.ko' -o -name '.*.cmd' \
		-o -name '.*.d' -o -name '.*.tmp' -o -name '*.mod' \
		-o -name '*.mod.c' -o -name 'modules.order' \
		-o -name '.tmp_*.o.*' \) -type f -print | xargs rm -f

PHONY += mrproper
mrproper: clean
	$(Q)rm -rf include/generated

# =============================================================================
# 帮助信息
# =============================================================================

PHONY += help
help:
	@echo  'Cleaning targets:'
	@echo  '  clean           - Remove most generated files'
	@echo  '  mrproper        - Remove all generated files'
	@echo  ''
	@echo  'Build targets:'
	@echo  '  all             - Build all targets'
	@echo  ''
	@echo  'Configuration:'
	@echo  '  ARCH=<arch>           - Target architecture (default: $(ARCH))'
	@echo  '  CROSS_COMPILE=<prefix> - Cross compiler prefix'
	@echo  '  V=1                   - Verbose build'
	@echo  '  O=dir                 - Output directory for out-of-tree build'
	@echo  ''
	@echo  'Examples:'
	@echo  '  make                                    - Build all'
	@echo  '  make V=1                                - Verbose build'
	@echo  '  make O=/tmp/build                       - Out-of-tree build'
	@echo  '  make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-'
	@echo  '  make clean                              - Clean build artifacts'

.PHONY: $(PHONY)

endif # skip-makefile
