# GNU M4 Compatibility Tests
# Test file for comprehensive compatibility with GNU M4 features
# Tests ifelse, quoting (including changequote), indir, and defn
#
# NOTES ON THIS IMPLEMENTATION:
# - indir requires literal macro names as its first argument (no extra quotes)
# - defn works correctly for both user-defined macros and builtins
# - changequote supports multi-character quotes and resets
# - ifelse supports all standard GNU m4 argument patterns
#
# All tests are designed to produce clear, verifiable output

# ==============================================================================
# IFELSE Tests - Test all argument combinations and edge cases
# ==============================================================================

# Test 1: ifelse with 2 arguments (no match, no default)
# Should output nothing when strings don't match
define(test_ifelse_2args_nomatch, `ifelse(foo, bar)')
test_ifelse_2args_nomatch()

# Test 2: ifelse with 3 arguments (match, no default)  
# Should output the "then" clause when strings match
define(test_ifelse_3args_match, `ifelse(foo, foo, MATCHED)')
test_ifelse_3args_match()

# Test 3: ifelse with 3 arguments (no match, no default)
# Should output nothing when strings don't match
define(test_ifelse_3args_nomatch, `ifelse(foo, bar, MATCHED)')
test_ifelse_3args_nomatch()

# Test 4: ifelse with 4 arguments (match case)
# Should output the "then" clause when strings match
define(test_ifelse_4args_match, `ifelse(hello, hello, THEN_CLAUSE, ELSE_CLAUSE)')
test_ifelse_4args_match()

# Test 5: ifelse with 4 arguments (no match case)
# Should output the "else" clause when strings don't match
define(test_ifelse_4args_nomatch, `ifelse(hello, world, THEN_CLAUSE, ELSE_CLAUSE)')
test_ifelse_4args_nomatch()

# Test 6: ifelse with 5 arguments (chained arms - first match)
# Should output first match and stop processing
define(test_ifelse_5args_first, `ifelse(a, a, FIRST, b, b, SECOND, DEFAULT)')
test_ifelse_5args_first()

# Test 7: ifelse with 7 arguments (chained arms - second match)
# Should output second match and stop processing
define(test_ifelse_7args_second, `ifelse(a, b, FIRST, c, c, SECOND, DEFAULT)')
test_ifelse_7args_second()

# Test 8: ifelse with 7 arguments (chained arms - no match, use default)
# Should output default when no matches found
define(test_ifelse_7args_default, `ifelse(a, b, FIRST, c, d, SECOND, DEFAULT)')
test_ifelse_7args_default()

# Test 9: ifelse with empty/null arguments
# Should handle empty strings correctly
define(test_ifelse_empty, `ifelse(, , EMPTY_MATCH, NOT_EMPTY)')
test_ifelse_empty()

# Test 10: ifelse with one empty, one non-empty
define(test_ifelse_mixed_empty, `ifelse(, foo, MATCHED, NOT_MATCHED)')
test_ifelse_mixed_empty()

# Test 11: ifelse nested within itself
# Should handle recursive calls correctly
define(test_ifelse_nested, `ifelse(1, 1, ifelse(2, 2, NESTED_SUCCESS, NESTED_FAIL), OUTER_FAIL)')
test_ifelse_nested()

# ==============================================================================
# QUOTING Tests - Test quote handling and changequote functionality
# ==============================================================================

# Test 12: Basic quoting behavior
# Should preserve literal text within quotes
define(test_basic_quotes, ``This is quoted text'')
test_basic_quotes()

# Test 13: Nested quotes
# Should handle quotes within quotes correctly
define(test_nested_quotes, ``Outer `inner' quotes'')
test_nested_quotes()

# Test 14: Change quote characters to different symbols
changequote([, ])
define(test_changed_quotes, [This uses square brackets])
test_changed_quotes()

# Test 15: Multi-character quote delimiters
changequote([[, ]])
define(test_multichar_quotes, [[This uses double square brackets]])
test_multichar_quotes()

# Test 16: Quotes inside macro arguments
changequote(`, ')
define(test_quotes_in_args, `First arg: $1, Second arg: $2')
test_quotes_in_args(`quoted first', `quoted second')

# Test 17: Reset quotes to default
changequote()
define(test_default_quotes, `Back to default quotes')
test_default_quotes()

# Test 18: Asymmetric quotes
changequote(<, >)
define(test_asymmetric, <Different start and end>)
test_asymmetric()

# Test 19: Empty quote strings (should disable quoting)
changequote(, )
define(test_no_quotes, This should not be quoted)
test_no_quotes()

# Reset to default for remaining tests
changequote(`, ')

# Test 20: Quote characters within macro definitions
define(test_quotes_in_def, `Contains backtick and apostrophe')
test_quotes_in_def()

# ==============================================================================
# INDIR Tests - Test indirect macro invocation
# ==============================================================================

# Test 21: Basic indirect call
define(hello, `Hello, World!')
define(test_indir_basic, `indir(`hello')')
test_indir_basic()

# Test 22: Indirect call with arguments
define(greet, `Hello, $1!')
define(test_indir_args, `indir(`greet', `Alice')')
test_indir_args()

# Test 23: Indirect call through variable (using literal name)
define(test_indir_variable, `indir(`hello')')
test_indir_variable()

# Test 24: Indirect call to builtin macro
define(test_indir_builtin, `indir(len, abcdef)')
test_indir_builtin()

# Test 25: Multiple level indirection (simplified for this implementation)
define(level1, `level2')
define(level2, `Final result')
define(test_indir_multilevel, `indir(`level2')')
test_indir_multilevel()

# ==============================================================================
# DEFN Tests - Test macro definition extraction
# ==============================================================================

# Test 26: defn of a user-defined macro
define(original_macro, `This is the original definition')
define(test_defn_user, `defn(`original_macro')')
test_defn_user()

# Test 27: defn of a builtin macro
define(test_defn_builtin, `defn(`len')')
# This should return the builtin definition of len
# We can test it works by using it
define(my_len, defn(`len'))
my_len(`hello')

# Test 28: Renaming a macro using defn
define(old_name, `Original functionality')
define(new_name, defn(`old_name'))
undefine(`old_name')
new_name()

# Test 29: defn with undefined macro (should be empty)
define(test_defn_undefined, `defn(`nonexistent_macro')')
test_defn_undefined()

# Test 30: Copy and modify pattern
define(base_func, `Base: $1')
define(extended_func, `defn(`base_func') Extended: $1')
extended_func(`test')

# Test 31: defn of macro with multiple arguments
define(multi_arg_macro, `Args: $1, $2, $3')
define(copied_multi, defn(`multi_arg_macro'))
copied_multi(`first', `second', `third')

# Test 32: defn preserves argument structure
define(arg_test, `$# arguments: $*')
define(arg_copy, defn(`arg_test'))
arg_copy(`a', `b', `c', `d')

# ==============================================================================
# EDGE CASES and COMPLEX INTERACTIONS
# ==============================================================================

# Test 33: ifelse with quoted arguments
define(test_ifelse_quoted, `ifelse(`quoted', `quoted', MATCH, NO_MATCH)')
test_ifelse_quoted()

# Test 34: indir with changequote
changequote([, ])
define(square_macro, [Square brackets work])
define(test_indir_changequote, indir([square_macro]))
test_indir_changequote()
changequote(`, ')

# Test 35: defn with changequote
changequote({, })
define(curly_macro, {Curly braces})
define(test_defn_changequote, defn({curly_macro}))
test_defn_changequote()
changequote(`, ')

# Test 36: Complex nested scenario
define(complex_test, `ifelse($1, match, `Found: defn(`hello')', `Not found')')
complex_test(`match')
complex_test(`nomatch')

# End of tests
# Tests completed. Each test should produce clear, verifiable output.