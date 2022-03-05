#!/bin/sh

export DM__GLOBAL__RUNTIME__REPO_ROOT="../../.."
# shellcheck source=../../../src/load_sources.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/load_sources.sh"

setup_file() {
  dm__debug__init
}

test__surrounding_whitespace_can_be_removed() {
  input_string='    dummy content          '

  dummy_function() {
    dm_tools__echo "$input_string" | dm__utils__remove_surrounding_whitespace
  }
  run dummy_function

  assert_no_error
  assert_status 0
  assert_output 'dummy content'
}

test__multiline_input_can_be_handled() {
  input_string="$( \
    dm_tools__echo ' line 1 '; \
    dm_tools__echo '  line  2   '; \
    dm_tools__echo '    line   3    '; \
  )"

  dummy_function() {
    dm_tools__echo "$input_string" | dm__utils__remove_surrounding_whitespace
  }
  run dummy_function

  assert_no_error
  assert_status 0
  assert_output_line_count 3
  assert_output_line_at_index 1 'line 1'
  assert_output_line_at_index 2 'line  2'
  assert_output_line_at_index 3 'line   3'
}