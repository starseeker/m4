# ISPC Macro Compatibility Test Files

This directory contains macro files from the Intel SPMD Program Compiler (ISPC) project, used for testing compatibility between GNU m4 and starseeker/m4 implementations.

## Files

- **util-xe.m4**: Utility macros for Intel Xe (GPU) code generation
- **svml.m4**: Short Vector Math Library (SVML) macro definitions for vectorized mathematical functions

## Origin

These files were obtained unmodified from the ISPC project:
- Repository: https://github.com/ispc/ispc
- Original paths: 
  - `builtins/util..m4`
  - `builtins/util-xe.m4`
  - `builtins/svml.m4`
- License: BSD-3-Clause (Intel Corporation)

## Purpose

These files serve as real-world compatibility test cases to verify that starseeker/m4 processes complex macro definitions in the same way as GNU m4. The ISPC project uses sophisticated m4 macros for code generation, making these excellent test specimens for macro processor compatibility.

## Usage

To test compatibility between GNU m4 and starseeker/m4:

### Basic Processing Test
```bash
# Test with GNU m4
m4 util.m4 > output_gnu_util.txt
m4 util-xe.m4 > output_gnu_util-xe.txt
m4 svml.m4 > output_gnu_svml.txt

# Test with starseeker/m4 (om4)
om4 util.m4 > output_gnu_util.txt
om4 util-xe.m4 > output_om4_util-xe.txt
om4 svml.m4 > output_om4_svml.txt

# Compare outputs
diff output_gnu_util.txt output_om4_util.txt
diff output_gnu_util-xe.txt output_om4_util-xe.txt
diff output_gnu_svml.txt output_om4_svml.txt
```

### Macro Expansion Test
```bash
# Test specific macro expansions
echo 'include(`util-xe.m4')print_xe_result_declaration(result, float)' | m4
echo 'include(`util-xe.m4')print_xe_result_declaration(result, float)' | om4

echo 'include(`svml.m4')svml_stubs(float, f, 4)' | m4  
echo 'include(`svml.m4')svml_stubs(float, f, 4)' | om4
```

## Expected Behavior

Both GNU m4 and starseeker/m4 should:
1. Process these files without syntax errors
2. Produce identical output for equivalent macro invocations
3. Handle complex nested macro definitions correctly
4. Support the advanced m4 features used by ISPC (ifelse, define, etc.)

Any differences in output indicate potential compatibility issues that should be investigated.

## Notes

- These files contain LLVM IR generation macros and may produce output that looks like assembly code
- The macros use advanced m4 features including conditional expansion, nested macro calls, and complex parameter substitution
- These files are not included in the build process and serve purely as test cases
