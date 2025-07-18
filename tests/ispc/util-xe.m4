dnl This file was obtained from the ISPC project (https://github.com/ispc/ispc)
dnl Original path: builtins/util-xe.m4
dnl Added to starseeker/m4 repository for compatibility testing purposes
dnl
dnl Copyright (c) 2013-2025, Intel Corporation
dnl
dnl SPDX-License-Identifier: BSD-3-Clause

;; util-xe.m4 - macros for Xe (Intel GPU) code generation

;; print_xe_result_declaration : print declaration of the result variable for Xe
;; if it is struct type, call utility function.
;; $1 - variable name
;; $2 - type, llvm type, like float, <4 x float>, double, <2 x double>, etc.
define(`print_xe_result_declaration',`
  %$1 = alloca $2, align 4
')

;; load_xe_result : load result for Xe
;; $1 - variable name
;; $2 - type
define(`load_xe_result',`
  %$1_final = load $2, $2* %$1, align 4
')

;; load_xe_result_wide : load result for Xe, uses 16 byte alignment
;; $1 - variable name
;; $2 - type
define(`load_xe_result_wide',`
  %$1_final = load $2, $2* %$1, align 16
')

;; mask_to_i8_xe : convert llvm bool vector to i8 vector for Xe ISA
;; $1 - variable name to store result
;; $2 - bool type, like <4 x i1>, <8 x i1>, <16 x i1>, etc.
;; $3 - variable name to convert
define(`mask_to_i8_xe',`
  %$1 = zext $2 %$3 to <ifelse(substr($2,1,2),`<4',`4 x i8>,',substr($2,1,2),`<8',`8 x i8>,',substr($2,1,3),`<16',`16 x i8>,',substr($2,1,3),`<32',`32 x i8>,',substr($2,1,3),`<64',`64 x i8>,')')
')

;; i8_to_mask_xe : convert i8 vector to llvm bool vector for Xe ISA
;; $1 - variable name to store result  
;; $2 - i8 type, like <4 x i8>, <8 x i8>, <16 x i8>, etc.
;; $3 - variable name to convert
define(`i8_to_mask_xe',`
  %$1 = icmp ne $2 %$3, zeroinitializer
')

;; kn1_binop_xe : apply binary operation for knightsmill masks for Xe
;; $1 - operation (and, or, xor)  
;; $2 - mask width (32 or 64)
;; $3 - first operand variable name
;; $4 - second operand variable name
;; $5 - result variable name
define(`kn1_binop_xe',`
  %$5 = $1 <$2 x i1> %$3, %$4
')

;; kn1_notmask_xe : apply not operation to mask for Xe
;; $1 - mask width (32 or 64)
;; $2 - operand variable name  
;; $3 - result variable name
define(`kn1_notmask_xe',`
  %$3 = xor <$1 x i1> %$2, <ifelse($1,32,`i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true',`i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true')>
')

;; xe_svml_unary_func : unary function call for Xe SVML
;; $1 - result variable name
;; $2 - function call, like "call <8 x float> @__svml_exp8(...)"
define(`xe_svml_unary_func',`
  %$1 = $2
')

;; xe_svml_binary_func : binary function call for Xe SVML
;; $1 - result variable name  
;; $2 - function call, like "call <8 x float> @__svml_pow8(...)"
define(`xe_svml_binary_func',`
  %$1 = $2
')

;; stdlib_strided_load_xe : perform strided load using stdlib for Xe
;; $1 - result variable name
;; $2 - return type
;; $3 - variable arguments (pointer, stride, etc.)
define(`stdlib_strided_load_xe',`
  %$1 = call $2 @__stdlib_strided_load_xe($3)
')

;; stdlib_strided_store_xe : perform strided store using stdlib for Xe  
;; $1 - variable arguments (value, pointer, stride, etc.)
define(`stdlib_strided_store_xe',`
  call void @__stdlib_strided_store_xe($1)
')

;; packed_load_xe : perform packed load for Xe
;; $1 - result variable name
;; $2 - return type
;; $3 - variable arguments
define(`packed_load_xe',`
  %$1 = call $2 @__packed_load_xe($3)
')

;; packed_store_xe : perform packed store for Xe
;; $1 - variable arguments
define(`packed_store_xe',`
  call void @__packed_store_xe($1)
')

;; gather_xe : perform gather operation for Xe
;; $1 - result variable name
;; $2 - return type
;; $3 - variable arguments
define(`gather_xe',`
  %$1 = call $2 @__gather_xe($3)
')

;; scatter_xe : perform scatter operation for Xe
;; $1 - variable arguments
define(`scatter_xe',`
  call void @__scatter_xe($1)
')
