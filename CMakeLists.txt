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

# Local Variables:
# tab-width: 8
# mode: cmake
# indent-tabs-mode: t
# End:
# ex: shiftwidth=2 tabstop=8
