#ifndef SHARED_H
#define SHARED_H

/* Shared library API */

/**
 * Calculate factorial
 * @param n: input number
 * @return: factorial of n
 */
unsigned long long factorial(int n);

/**
 * Check if a number is even
 * @param n: input number
 * @return: 1 if even, 0 if odd
 */
int is_even(int n);

/**
 * Calculate power
 * @param base: base number
 * @param exp: exponent
 * @return: base^exp
 */
double power(double base, int exp);

#endif /* SHARED_H */
