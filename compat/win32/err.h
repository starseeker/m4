#ifndef OM4_WIN32_ERR_H
#define OM4_WIN32_ERR_H

#include <stdarg.h>

#ifdef __cplusplus
extern "C" {
#endif

void err(int status, const char *format, ...);
void errx(int status, const char *format, ...);
void verr(int status, const char *format, va_list arguments);
void warn(const char *format, ...);
void warnx(const char *format, ...);
void vwarnx(const char *format, va_list arguments);

extern char *__progname;

#ifdef __cplusplus
}
#endif

#endif
