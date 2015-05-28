#ifndef LIB_ATTR_H_
#define LIB_ATTR_H_

/*
 * Annotation defines
 */

#define packed __attribute__((packed))
#define unused __attribute__((unused))
#define weak __attribute__((weak))

/*
 * Annotation macros
 */

#define section(spot) __attribute__((section(spot)))

#endif
