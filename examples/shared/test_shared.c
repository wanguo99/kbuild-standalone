#include <stdio.h>
#include "shared.h"

int main(void)
{
	printf("=== Shared Library Test ===\n\n");

	// Test factorial
	printf("Factorial tests:\n");
	for (int i = 0; i <= 10; i++) {
		printf("  %d! = %llu\n", i, factorial(i));
	}
	printf("\n");

	// Test is_even
	printf("Even/Odd tests:\n");
	for (int i = 0; i <= 10; i++) {
		printf("  %d is %s\n", i, is_even(i) ? "even" : "odd");
	}
	printf("\n");

	// Test power
	printf("Power tests:\n");
	printf("  2^8 = %.0f\n", power(2.0, 8));
	printf("  3^4 = %.0f\n", power(3.0, 4));
	printf("  5^3 = %.0f\n", power(5.0, 3));
	printf("  10^2 = %.0f\n", power(10.0, 2));
	printf("\n");

	printf("=== Test Complete ===\n");
	return 0;
}
