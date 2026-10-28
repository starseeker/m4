foreach(required OM4_EXECUTABLE OM4_INPUT OM4_EXPECTED)
  if (NOT DEFINED ${required})
    message(FATAL_ERROR "${required} is required")
  endif ()
endforeach()

execute_process(
  COMMAND "${OM4_EXECUTABLE}" -g "${OM4_INPUT}"
  RESULT_VARIABLE result
  OUTPUT_VARIABLE actual
  ERROR_VARIABLE error_output
  )
if (result)
  message(FATAL_ERROR "om4 failed for ${OM4_INPUT}:\n${error_output}")
endif ()

file(READ "${OM4_EXPECTED}" expected)
string(REPLACE "\r\n" "\n" actual "${actual}")
string(REPLACE "\r\n" "\n" expected "${expected}")
if (NOT actual STREQUAL expected)
  message(FATAL_ERROR "om4 output differs from GNU m4 for ${OM4_INPUT}")
endif ()
