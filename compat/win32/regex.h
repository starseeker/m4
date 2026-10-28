#ifndef OM4_WIN32_REGEX_H
#define OM4_WIN32_REGEX_H

#include <stddef.h>

#define REG_EXTENDED 0x01
#define REG_ICASE 0x02
#define REG_NOSUB 0x04
#define REG_NEWLINE 0x08
#define REG_NOTBOL 0x10
#define REG_NOTEOL 0x20
#define REG_NOMATCH 1
#define REG_BADPAT 2

typedef struct {
    size_t re_nsub;
    void *implementation;
    char *error_message;
} regex_t;

typedef struct {
    ptrdiff_t rm_so;
    ptrdiff_t rm_eo;
} regmatch_t;

#ifdef __cplusplus
extern "C" {
#endif

int regcomp(regex_t *expression, const char *pattern, int flags);
int regexec(const regex_t *expression, const char *text, size_t match_count,
    regmatch_t matches[], int flags);
size_t regerror(int error_code, const regex_t *expression, char *buffer,
    size_t buffer_size);
void regfree(regex_t *expression);

#ifdef __cplusplus
}
#endif

#endif
