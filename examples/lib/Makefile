# =============================================================================
# 静态库示例 - libexample.a
# =============================================================================

# 库名称
lib-y += example

# 源文件列表
example-y := \
	string_utils.o \
	math_utils.o \
	list.o

# 编译标志
ccflags-y := -I$(src)/include

# 导出的头文件
EXPORT_HEADERS := \
	include/example.h \
	include/string_utils.h \
	include/math_utils.h
