# Test file for GNU m4 multi-digit argument compatibility
# Tests macro definitions using $10, $11, $12 and verifies correct expansion

# Define a macro that uses twelve arguments, including multi-digit ones
define(test_twelve_args, `Arguments: $1 $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12')

# Test the macro with twelve arguments
test_twelve_args(One, Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten, Eleven, Twelve)

# Define a macro specifically testing high argument numbers
define(test_high_args, `High args: $10=$10, $11=$11, $12=$12')
test_high_args(1,2,3,4,5,6,7,8,9,10,11,12)

# Test mixing single and multi-digit arguments
define(test_mixed, `Mixed: $1 and $10 and $2 and $11')
test_mixed(A,B,C,D,E,F,G,H,I,J,K,L)

# Test edge case with argument 99 (maximum supported)
define(test_arg99, `Arg 99: $99')
test_arg99(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,NINETY_NINE)

# Test that non-existent high arguments are handled correctly
define(test_nonexist, `Non-exist: $50')
test_nonexist(A,B,C)