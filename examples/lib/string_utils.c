/* string_utils.c - 字符串工具函数 */
#include "string_utils.h"
#include <string.h>
#include <ctype.h>

char *str_reverse(char *str)
{
	if (!str)
		return NULL;

	int len = strlen(str);
	for (int i = 0; i < len / 2; i++) {
		char tmp = str[i];
		str[i] = str[len - 1 - i];
		str[len - 1 - i] = tmp;
	}
	return str;
}

size_t str_copy_safe(char *dst, const char *src, size_t size)
{
	if (!dst || !src || size == 0)
		return 0;

	size_t len = strlen(src);
	if (len >= size)
		len = size - 1;

	memcpy(dst, src, len);
	dst[len] = '\0';
	return len;
}

char *str_to_upper(char *str)
{
	if (!str)
		return NULL;

	for (char *p = str; *p; p++)
		*p = toupper(*p);

	return str;
}
