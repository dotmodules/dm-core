#!/bin/sh

export DM__GLOBAL__RUNTIME__REPO_ROOT="../../.."
# shellcheck source=../../../src/load_sources.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/load_sources.sh"

setup_file() {
  dm__debug__init
}

test__whitespace_will_be_squeezed() {
  input_string='a b  c     d'

  dummy_function() {
    dm_tools__echo "$input_string" | dm__utils__normalize_whitespace
  }
  run dummy_function

  assert_no_error
  assert_status 0
  assert_output 'a b c d'
}

test__multiline_input_will_be_squeezed_too() {
  input_string="$( \
    dm_tools__echo ' a  a   a  '; \
    dm_tools__echo '  b   b       b   '; \
    dm_tools__echo '    c   c     c    '; \
  )"

  dummy_function() {
    dm_tools__echo "$input_string" | dm__utils__normalize_whitespace
  }
  run dummy_function

  assert_no_error
  assert_status 0
  assert_output_line_count 3
  assert_output_line_at_index 1 ' a a a '
  assert_output_line_at_index 2 ' b b b '
  assert_output_line_at_index 3 ' c c c '
}