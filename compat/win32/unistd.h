#ifndef OM4_WIN32_UNISTD_H
#define OM4_WIN32_UNISTD_H

#include <io.h>
#include <stddef.h>

#define close _close
#define fdopen _fdopen
#define read _read
#define unlink _unlink

#define STDIN_FILENO 0
#define STDOUT_FILENO 1
#define STDERR_FILENO 2

#ifndef PATH_MAX
#define PATH_MAX 4096
#endif

#ifdef __cplusplus
extern "C" {
#endif

extern char *optarg;
extern int optind;
extern int opterr;
extern int optopt;

int getopt(int argc, char *const argv[], const char *options);
int mkstemp(char *path_template);
char *strsep(char **string, const char *delimiters);

#ifdef __cplusplus
}
#endif

#endif
