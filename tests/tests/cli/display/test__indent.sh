#!/bin/sh

export DM__GLOBAL__RUNTIME__REPO_ROOT="../../../.."
# shellcheck source=../../../../src/load_sources.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/load_sources.sh"

setup_file() {
  dm__debug__init
}

test__empty_line_gets_indented() {
  # Setting up the global variable for this test.
  export DM__CONFIG__CLI__INDENT='  '
  input_string=''

  dummy_function () {
    dm_tools__echo "$input_string" | dm__cli__display__indent
  }
  run dummy_function

  assert_status 0
  assert_output '  '
  assert_no_error
}

test__single_line_can_be_indented() {
  # Setting up the global variable for this test.
  export DM__CONFIG__CLI__INDENT='  '
  input_string='hello'

  dummy_function () {
    dm_tools__echo "$input_string" | dm__cli__display__indent
  }
  run dummy_function

  assert_status 0
  assert_output '  hello'
  assert_no_error
}

test__multi_line_can_be_indented() {
  # Setting up the global variable for this test.
  export DM__CONFIG__CLI__INDENT='  '
  input_string="$( \
    dm_tools__echo 'aaa'; \
    dm_tools__echo 'bbb'; \
    dm_tools__echo 'ccc'; \
  )"

  dummy_function () {
    dm_tools__echo "$input_string" | dm__cli__display__indent
  }
  run dummy_function

  assert_status 0
  assert_output_line_at_index 1 '  aaa'
  assert_output_line_at_index 2 '  bbb'
  assert_output_line_at_index 3 '  ccc'
  assert_no_error
}