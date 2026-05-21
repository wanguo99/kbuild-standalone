/* main.c - 测试应用主程序 */
#include <stdio.h>
#include <string.h>
#include "example.h"

extern void app_logic_test(void);

int main(int argc, char *argv[])
{
	printf("=== Kbuild Framework Test Application ===\n");
	printf("Version: %s\n\n", EXAMPLE_VERSION);

	/* 测试字符串工具 */
	char str[100];
	strcpy(str, "hello world");
	printf("Original: %s\n", str);

	str_to_upper(str);
	printf("Upper: %s\n", str);

	str_reverse(str);
	printf("Reversed: %s\n\n", str);

	/* 测试数学工具 */
	printf("GCD(48, 18) = %d\n", gcd(48, 18));
	printf("LCM(12, 18) = %d\n", lcm(12, 18));
	printf("Is 17 prime? %s\n\n", is_prime(17) ? "Yes" : "No");

	/* 调用应用逻辑 */
	app_logic_test();

	printf("\n=== Test Complete ===\n");
	return 0;
}
