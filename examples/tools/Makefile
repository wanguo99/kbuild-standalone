# =============================================================================
# 可执行文件示例 - test_app
# =============================================================================

# 可执行文件名称
bin-y += test_app

# 源文件列表
test_app-y := \
	main.o \
	app_logic.o

# 编译标志
ccflags-y := -I$(srctree)/examples/lib/include

# 链接库
LDLIBS_test_app := -L$(LIB_DIR) -lexample -lm
