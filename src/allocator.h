#pragma once

#include <stddef.h>

// C11's _Thread_local, else GNU C's __thread (gcc before 4.9, or C99 mode)

#if !USE_THREADS
#define pl_thread_local
#elif (__STDC_VERSION__ >= 201112L) && !(defined(__GNUC__) && !defined(__clang__) && ((__GNUC__ * 100 + __GNUC_MINOR__) < 409))
#define pl_thread_local _Thread_local
#else
#define pl_thread_local __thread
#endif

void *tpl_malloc(size_t size);
void *tpl_calloc(size_t count, size_t size);
void *tpl_realloc(void *ptr, size_t size);
void tpl_free(void *ptr);
char *tpl_strdup(const char *src);

#define TPL_malloc tpl_malloc
#define TPL_calloc tpl_calloc
#define TPL_realloc tpl_realloc
#define TPL_free tpl_free
#define TPL_strdup tpl_strdup
