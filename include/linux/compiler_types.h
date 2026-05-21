/* SPDX-License-Identifier: GPL-2.0 */
#ifndef __LINUX_COMPILER_TYPES_H
#define __LINUX_COMPILER_TYPES_H

/*
 * Minimal compiler_types.h for userspace builds
 * This file is included by the Kbuild system but most kernel-specific
 * compiler attributes are not needed for userspace programs.
 */

#ifndef __ASSEMBLY__

/* Compiler attribute macros - most are no-ops for userspace */
#define __user
#define __kernel
#define __iomem
#define __percpu
#define __rcu
#define __private

#ifndef __always_inline
#define __always_inline inline __attribute__((__always_inline__))
#endif

#ifndef __noinline
#define __noinline __attribute__((__noinline__))
#endif

#ifndef __packed
#define __packed __attribute__((__packed__))
#endif

#ifndef __aligned
#define __aligned(x) __attribute__((__aligned__(x)))
#endif

#ifndef __printf
#define __printf(a, b) __attribute__((__format__(printf, a, b)))
#endif

#ifndef __scanf
#define __scanf(a, b) __attribute__((__format__(scanf, a, b)))
#endif

#ifndef __maybe_unused
#define __maybe_unused __attribute__((__unused__))
#endif

#ifndef __used
#define __used __attribute__((__used__))
#endif

#ifndef __cold
#define __cold __attribute__((__cold__))
#endif

#ifndef __section
#define __section(S) __attribute__((__section__(#S)))
#endif

#endif /* __ASSEMBLY__ */

#endif /* __LINUX_COMPILER_TYPES_H */
