dnl This file was obtained from the ISPC project (https://github.com/ispc/ispc)
dnl Original path: builtins/util.m4
dnl Added to starseeker/m4 repository for compatibility testing purposes
dnl
;;  Copyright (c) 2010-2025, Intel Corporation
;;
;;  SPDX-License-Identifier: BSD-3-Clause

;; This file provides a variety of macros used to generate LLVM bitcode
;; parametrized in various ways.  Implementations of the standard library
;; builtins for various targets can use macros from this file to simplify
;; generating code for their implementations of those builtins.

;; argn allows to portably select greater than ninth argument without relying
;; on the GNU extension of multi-digit arguments.
define(`argn', `ifelse(`$1', 1, ``$2'', `argn(decr(`$1'), shift(shift($@)))')')

;; Helper macro to generate the element list recursively
define(`_VECTOR_ELEMENTS', `ifelse($3, $1, `$2 0', `$2 $3, _VECTOR_ELEMENTS($1, $2, eval($3 + 1))')')

;; M4 macro to generate LLVM IR vector constant with pattern <1, 2, 3, ..., WIDTH-1, 0>
;; Usage: ROTATE_1_CONST(width, type)
;; Example: ROTATE_1_CONST(8, i32) generates <8 x i32> <i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 0>
define(`ROTATE_1_CONST', `<$1 x $2> <ifelse($1, 1, `$2 0', `_VECTOR_ELEMENTS($1, $2, 1)')>')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; It is a bit of a pain to compute this in m4 for 32 and 64-wide targets...
define(`ALL_ON_MASK',
`ifelse(WIDTH, `64', `-1',
        WIDTH, `32', `4294967295',
                     `eval((1<<WIDTH)-1)')')

define(`MASK_HIGH_BIT_ON',
`ifelse(WIDTH, `64', `-9223372036854775808',
        WIDTH, `32', `2147483648',
                     `eval(1<<(WIDTH-1))')')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define(`PTR_OP_ARGS',
    `$1 , $1 *'
)

define(`MdORi64',
  ``i64''
)

define(`MfORi32',
  ``i32''
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper functions for mangling overloaded LLVM intrinsics
define(`LLVM_OVERLOADED_TYPE',
`ifelse($1, `i1', `i1',
        $1, `i8', `i8',
        $1, `i16', `i16',
        $1, `half', `f16',
        $1, `i32', `i32',
        $1, `float', `f32',
        $1, `double', `f64',
        $1, `i64', `i64')')

define(`SIZEOF',
`ifelse($1, `i1', 1,
        $1, `i8', 1,
        $1, `i16', 2,
        $1, `half', 2,
        $1, `i32', 4,
        $1, `float', 4,
        $1, `double', 8,
        $1, `i64', 8)')

define(`CONCAT',`$1$2')
define(`TYPE_SUFFIX',`CONCAT(`v', CONCAT(WIDTH, LLVM_OVERLOADED_TYPE($1)))')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reduce function based on the WIDTH
define(`reduce_func',
`ifelse(WIDTH, `64', `reduce64($1, $2, $3)',
        WIDTH, `32', `reduce32($1, $2, $3)',
        WIDTH, `16', `reduce16($1, $2, $3)',
        WIDTH, `8',  `reduce8($1, $2, $3)',
        WIDTH, `4',  `reduce4($1, $2, $3)',
                     `errprint(`ERROR: reduce_func() macro called with unsupported width = 'WIDTH
)
                      m4exit(`1')')
')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
[...file truncated for brevity; full file matches ISPC util.m4 as referenced...]
