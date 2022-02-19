#!/bin/sh

export DM__GLOBAL__RUNTIME__REPO_ROOT="../../.."
# shellcheck source=../../../src/init.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/init.sh"

test__line_can_be_selected() {
  input_string="$( \
    dm_tools__echo 'line 1'; \
    dm_tools__echo 'line 2'; \
    dm_tools__echo 'line 3'; \
  )"

  run dm__utils__line_by_index '1' "$input_string"

  assert_no_error
  assert_status 0
  assert_output_line_count 1
  assert_output 'line 1'
}

test__zero_index() {
  input_string="$( \
    dm_tools__echo 'line 1'; \
    dm_tools__echo 'line 2'; \
    dm_tools__echo 'line 3'; \
  )"

  run dm__utils__line_by_index '0' "$input_string"

  assert_no_error
  assert_status 1
  assert_no_output
}

test__negative_index() {
  input_string="$( \
    dm_tools__echo 'line 1'; \
    dm_tools__echo 'line 2'; \
    dm_tools__echo 'line 3'; \
  )"

  run dm__utils__line_by_index '-2' "$input_string"

  assert_no_error
  assert_status 1
  assert_no_output
}

test__invalid_index() {
  input_string="$( \
    dm_tools__echo 'line 1'; \
    dm_tools__echo 'line 2'; \
    dm_tools__echo 'line 3'; \
  )"

  run dm__utils__line_by_index 'invalid' "$input_string"

  assert_no_error
  assert_status 1
  assert_no_output
}
