# =============================================================================
# 共享库示例 - libshared.so
# =============================================================================

# 共享库名称（不需要lib前缀和.so后缀）
so-y += shared

# 源文件列表
shared-y := \
	utils.o \
	api.o

# 编译标志（共享库需要-fPIC）
ccflags-y := -I$(src)/include

# 链接标志
LDFLAGS_libshared.so := -Wl,-soname,libshared.so.1

# 链接库（如果需要依赖其他库）
LDLIBS_libshared.so := -lm

# =============================================================================
# 测试程序 - test_shared
# =============================================================================

bin-y += test_shared

test_shared-y := test_shared.o

# 链接共享库
LDLIBS_test_shared := -L$(LIB_DIR) -lshared -lm

# 声明对共享库的依赖
LIBS_test_shared := $(LIB_DIR)/libshared.so
