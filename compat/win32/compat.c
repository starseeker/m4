#include <errno.h>
#include <fcntl.h>
#include <io.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#include "err.h"
#include "unistd.h"

char *optarg;
int optind = 1;
int opterr = 1;
int optopt;
char *__progname = "m4";

static void
report(const char *format, va_list arguments, int include_error)
{
	vfprintf(stderr, format, arguments);
	if (include_error)
		fprintf(stderr, ": %s", strerror(errno));
	fputc('\n', stderr);
}

void
err(int status, const char *format, ...)
{
	va_list arguments;

	va_start(arguments, format);
	report(format, arguments, 1);
	va_end(arguments);
	exit(status);
}

void
errx(int status, const char *format, ...)
{
	va_list arguments;

	va_start(arguments, format);
	report(format, arguments, 0);
	va_end(arguments);
	exit(status);
}

void
verr(int status, const char *format, va_list arguments)
{
	report(format, arguments, 1);
	exit(status);
}

void
warn(const char *format, ...)
{
	va_list arguments;

	va_start(arguments, format);
	report(format, arguments, 1);
	va_end(arguments);
}

void
warnx(const char *format, ...)
{
	va_list arguments;

	va_start(arguments, format);
	report(format, arguments, 0);
	va_end(arguments);
}

void
vwarnx(const char *format, va_list arguments)
{
	report(format, arguments, 0);
}

int
getopt(int argc, char *const argv[], const char *options)
{
	static const char *next;
	const char *option;

	optarg = NULL;
	if (next == NULL || *next == '\0') {
		if (optind >= argc || argv[optind][0] != '-' || argv[optind][1] == '\0')
			return -1;
		if (strcmp(argv[optind], "--") == 0) {
			optind++;
			return -1;
		}
		next = argv[optind++] + 1;
	}

	optopt = (unsigned char)*next++;
	option = strchr(options, optopt);
	if (option == NULL) {
		if (opterr)
			fprintf(stderr, "unknown option -- %c\n", optopt);
		return '?';
	}
	if (option[1] == ':') {
		if (*next != '\0') {
			optarg = (char *)next;
			next = NULL;
		} else if (optind < argc) {
			optarg = argv[optind++];
			next = NULL;
		} else {
			if (opterr)
				fprintf(stderr, "option requires an argument -- %c\n", optopt);
			return '?';
		}
	}
	return optopt;
}

int
mkstemp(char *path_template)
{
	if (_mktemp_s(path_template, strlen(path_template) + 1) != 0) {
		errno = EINVAL;
		return -1;
	}
	return _open(path_template, _O_CREAT | _O_EXCL | _O_RDWR | _O_BINARY,
	    _S_IREAD | _S_IWRITE);
}

char *
strsep(char **string, const char *delimiters)
{
	char *start;
	char *end;

	if (string == NULL || *string == NULL)
		return NULL;
	start = *string;
	end = start + strcspn(start, delimiters);
	if (*end == '\0')
		*string = NULL;
	else {
		*end = '\0';
		*string = end + 1;
	}
	return start;
}
