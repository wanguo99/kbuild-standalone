#include "shared.h"

unsigned long long factorial(int n)
{
	if (n <= 1)
		return 1;

	unsigned long long result = 1;
	for (int i = 2; i <= n; i++)
		result *= i;

	return result;
}

int is_even(int n)
{
	return (n % 2) == 0;
}
