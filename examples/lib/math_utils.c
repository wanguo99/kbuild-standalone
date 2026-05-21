/* math_utils.c - 数学工具函数 */
#include "math_utils.h"

int gcd(int a, int b)
{
	if (a < 0) a = -a;
	if (b < 0) b = -b;

	while (b != 0) {
		int tmp = b;
		b = a % b;
		a = tmp;
	}
	return a;
}

int lcm(int a, int b)
{
	if (a == 0 || b == 0)
		return 0;

	return (a / gcd(a, b)) * b;
}

int is_prime(int n)
{
	if (n <= 1)
		return 0;
	if (n <= 3)
		return 1;
	if (n % 2 == 0 || n % 3 == 0)
		return 0;

	for (int i = 5; i * i <= n; i += 6) {
		if (n % i == 0 || n % (i + 2) == 0)
			return 0;
	}
	return 1;
}
