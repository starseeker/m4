# Based on the script written by Brian Callahan <bcallah@openbsd.org>
# and released into the Public Domain.

cmake_minimum_required(VERSION 3.12)
project(OM4 VERSION 6.6 LANGUAGES C CXX)

find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)

set(OM4_FLEX_OPTIONS -l)
if (MSVC)
  list(APPEND OM4_FLEX_OPTIONS --wincompat)
endif ()

add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/lex.yy.c
  COMMAND ${FLEX_EXECUTABLE} ${OM4_FLEX_OPTIONS} ${CMAKE_CURRENT_SOURCE_DIR}/tokenizer.l
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
  check_c_source_runs("${DEADCHECK_SRC}" HAVE___DEAD)
endif(NOT DEFINED HAVE___DEAD)

if (NOT HAVE___DEAD)
  set(DEAD2CHECK_SRC "
  #include <stdlib.h>
  __dead2 void usage(void){exit(1);}int main(void){usage();return 0;}
  ")
  if(NOT DEFINED HAVE___DEAD2)
    check_c_source_runs("${DEAD2CHECK_SRC}" HAVE___DEAD2)
  endif(NOT DEFINED HAVE___DEAD2)
endif (NOT HAVE___DEAD)

if (NOT HAVE___DEAD AND NOT HAVE___DEAD2)
  set(NORETURNCHECK_SRC "
  #include <stdlib.h>
  __attribute__((__noreturn__)) void usage(void){exit(1);}int main(void){usage();return 0;}
  ")
  if(NOT DEFINED HAVE_NORETURN)
    check_c_source_runs("${NORETURNCHECK_SRC}" HAVE_NORETURN)
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

if (MSVC)
  list(APPEND OM4_SRCS
    compat/win32/compat.c
    compat/win32/regex.cpp
    )
endif ()

include_directories(
  ${CMAKE_CURRENT_BINARY_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}
  )

add_executable(om4 ${OM4_SRCS})
target_compile_definitions(om4 PRIVATE OM4_VERSION="${PROJECT_VERSION}")
if (MSVC)
  target_include_directories(om4 PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/compat/win32)
  set_target_properties(om4 PROPERTIES CXX_STANDARD 17 CXX_STANDARD_REQUIRED ON)
endif ()
set(OM4_PROGRAM_NAME om4 CACHE STRING "Installed m4 executable name")
set_target_properties(om4 PROPERTIES OUTPUT_NAME "${OM4_PROGRAM_NAME}")
option(OM4_GNU_COMPAT_DEFAULT "Enable GNU m4 compatibility mode by default" OFF)
if (OM4_GNU_COMPAT_DEFAULT)
  target_compile_definitions(om4 PRIVATE OM4_GNU_COMPAT_DEFAULT)
endif ()
if (M_LIBRARY)
  target_link_libraries(om4 ${M_LIBRARY})
endif (M_LIBRARY)
if (WFLAG)
  target_compile_options(om4 PRIVATE -w)
endif (WFLAG)
# Enable extended GNU m4 compatibility features
target_compile_definitions(om4 PRIVATE -DEXTENDED)

install(TARGETS om4 DESTINATION bin)

include(CTest)
if (BUILD_TESTING)
  add_test(NAME om4-version COMMAND om4 --version)
  set_tests_properties(om4-version PROPERTIES
    PASS_REGULAR_EXPRESSION "m4 \\(OpenBSD portable\\) ${PROJECT_VERSION}")
  foreach(OM4_TEST IN ITEMS ack gnu_compat gnuargs hanoi hash sqroot string test)
    add_test(NAME "om4-${OM4_TEST}"
      COMMAND om4 -g "${CMAKE_CURRENT_SOURCE_DIR}/tests/${OM4_TEST}.m4")
    set_tests_properties("om4-${OM4_TEST}" PROPERTIES
      WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/tests")
  endforeach()
  foreach(OM4_ISPC_TEST IN ITEMS util util-xe svml)
    add_test(NAME "om4-ispc-${OM4_ISPC_TEST}"
      COMMAND om4 -g "${CMAKE_CURRENT_SOURCE_DIR}/tests/ispc/${OM4_ISPC_TEST}.m4")
    add_test(NAME "om4-ispc-gnu-${OM4_ISPC_TEST}"
      COMMAND ${CMAKE_COMMAND}
        -DOM4_EXECUTABLE=$<TARGET_FILE:om4>
        -DOM4_INPUT=${CMAKE_CURRENT_SOURCE_DIR}/tests/ispc/${OM4_ISPC_TEST}.m4
        -DOM4_EXPECTED=${CMAKE_CURRENT_SOURCE_DIR}/tests/ispc/expected/${OM4_ISPC_TEST}.out
        -P ${CMAKE_CURRENT_SOURCE_DIR}/tests/compare.cmake)
  endforeach()
endif ()


# Local Variables:
# tab-width: 8
# mode: cmake
# indent-tabs-mode: t
# End:
# ex: shiftwidth=2 tabstop=8
