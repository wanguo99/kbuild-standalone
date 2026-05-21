/* string_utils.h */
#ifndef _STRING_UTILS_H_
#define _STRING_UTILS_H_

#include <stddef.h>

/* 字符串反转 */
char *str_reverse(char *str);

/* 字符串复制（安全版本） */
size_t str_copy_safe(char *dst, const char *src, size_t size);

/* 字符串转大写 */
char *str_to_upper(char *str);

#endif /* _STRING_UTILS_H_ */
