# Based on the script written by Brian Callahan <bcallah@openbsd.org>
# and released into the Public Domain.

cmake_minimum_required(VERSION 3.12)
project(OM4)

find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)

add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/lex.yy.c
  COMMAND ${FLEX_EXECUTABLE} -l ${CMAKE_CURRENT_SOURCE_DIR}/tokenizer.l
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  )

add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/y.tab.c ${CMAKE_CURRENT_BINARY_DIR}/y.tab.h
  COMMAND ${BISON_EXECUTABLE} -y -d ${CMAKE_CURRENT_SOURCE_DIR}/parser.y
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  )

include(CheckLibraryExists)
check_library_exists(m cos "" HAVE_M_LIBRARY)
if (HAVE_M_LIBRARY)
  set(M_LIBRARY m)
endif (HAVE_M_LIBRARY)

include(CheckCSourceRuns)
set(DEADCHECK_SRC "
#include <stdlib.h>
__dead void usage(void){exit(1);}int main(void){usage();return 0;}
")
if(NOT DEFINED HAVE___DEAD)
  check_c_source_runs("${DEAD_SRC}" HAVE___DEAD)
endif(NOT DEFINED HAVE___DEAD)

if (NOT HAVE___DEAD)
  set(DEAD2CHECK_SRC "
  #include <stdlib.h>
  __dead2 void usage(void){exit(1);}int main(void){usage();return 0;}
  ")
  if(NOT DEFINED HAVE___DEAD2)
    check_c_source_runs("${DEAD2_SRC}" HAVE___DEAD2)
  endif(NOT DEFINED HAVE___DEAD2)
endif (NOT HAVE___DEAD)

if (NOT HAVE___DEAD AND NOT HAVE___DEAD2)
  set(NORETURNCHECK_SRC "
  #include <stdlib.h>
  __attribute__((__noreturn__)) void usage(void){exit(1);}int main(void){usage();return 0;}
  ")
  if(NOT DEFINED HAVE_NORETURN)
    check_c_source_runs("${NORETURN_SRC}" HAVE_NORETURN)
  endif(NOT DEFINED HAVE_NORETURN)
endif (NOT HAVE___DEAD AND NOT HAVE___DEAD2)

set(OHASHINITCHECK_SRC "
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <ohash.h>
int main(void){ohash_init(NULL, 0, NULL);return 0;}
")
if(NOT DEFINED HAVE_OHASHINIT)
  check_c_source_runs("${OHASHINIT_SRC}" HAVE_OHASHINIT)
endif(NOT DEFINED HAVE_OHASHINIT)

set(PLEDGECHECK_SRC "
#include <unistd.h>
int main(void){pledge(NULL,NULL);return 0;}
")
if(NOT DEFINED HAVE_PLEDGE)
  check_c_source_runs("${PLEDGE_SRC}" HAVE_PLEDGE)
endif(NOT DEFINED HAVE_PLEDGE)

set(REALLOCARRAYCHECK_SRC "
#include <stdlib.h>
int main(void){reallocarray(NULL, 0, 0);return 0;}
")
if(NOT DEFINED HAVE_REALLOCARRAY)
  check_c_source_runs("${REALLOCARRAY_SRC}" HAVE_REALLOCARRAY)
endif(NOT DEFINED HAVE_REALLOCARRAY)

set(STRLCPYCHECK_SRC "
#include <string.h>
int main(void){strlcpy(NULL,NULL,0);return 0;}
")
if(NOT DEFINED HAVE_STRLCPY)
  check_c_source_runs("${STRLCPY_SRC}" HAVE_STRLCPY)
endif(NOT DEFINED HAVE_STRLCPY)

set(STRTONUMCHECK_SRC "
#include <stdlib.h>
int main(void){strtonum(NULL, 0, 0, NULL);return 0;}
")
if(NOT DEFINED HAVE_STRTONUM)
  check_c_source_runs("${STRTONUM_SRC}" HAVE_STRTONUM)
endif(NOT DEFINED HAVE_STRTONUM)


include(CheckCCompilerFlag)
check_c_compiler_flag("-w" WFLAG)

configure_file(config.h.in ${CMAKE_CURRENT_BINARY_DIR}/config.h)

set (OM4_SRCS
  ${CMAKE_CURRENT_BINARY_DIR}/lex.yy.c
  ${CMAKE_CURRENT_BINARY_DIR}/y.tab.c
  ${CMAKE_CURRENT_BINARY_DIR}/y.tab.h
  eval.c
  expr.c
  look.c
  main.c
  misc.c
  gnum4.c
  trace.c
  ohash.c
  reallocarray.c
  strlcpy.c
  strtonum.c
  )

include_directories(
  ${CMAKE_CURRENT_BINARY_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}
  )

add_executable(om4 ${OM4_SRCS})
if (M_LIBRARY)
  target_link_libraries(om4 ${M_LIBRARY})
endif (M_LIBRARY)
if (WFLAG)
  target_compile_options(om4 PRIVATE -w)
endif (WFLAG)

install(TARGETS om4 DESTINATION bin)


# Local Variables:
# tab-width: 8
# mode: cmake
# indent-tabs-mode: t
# End:
# ex: shiftwidth=2 tabstop=8
