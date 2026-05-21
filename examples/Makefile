# =============================================================================
# Examples 顶层 Makefile
# =============================================================================

# 子目录
obj-y += lib/
obj-y += shared/
obj-y += tools/

# Ensure tools is built after lib (for parallel builds)
# Note: Use directory names without trailing slash for dependencies
tools: lib
shared: lib
