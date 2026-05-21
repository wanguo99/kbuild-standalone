/* app_logic.c - 应用逻辑 */
#include <stdio.h>
#include "example.h"

void app_logic_test(void)
{
	printf("=== Application Logic Test ===\n");

	/* 测试安全字符串复制 */
	char buf[10];
	const char *long_str = "This is a very long string";

	size_t copied = str_copy_safe(buf, long_str, sizeof(buf));
	printf("Copied %zu bytes: %s\n", copied, buf);

	/* 测试素数检测 */
	printf("\nPrime numbers from 1 to 20:\n");
	for (int i = 1; i <= 20; i++) {
		if (is_prime(i))
			printf("%d ", i);
	}
	printf("\n");
}
