#!/bin/sh

export DM__GLOBAL__RUNTIME__REPO_ROOT="../../.."
# shellcheck source=../../../src/init.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/init.sh"

test__line_can_be_selected() {
  input_string="$( \
    dm_tools__echo 'line_1'; \
    dm_tools__echo 'line_2'; \
    dm_tools__echo 'line_3'; \
  )"

  dummy_function() {
    dm_tools__echo "$input_string" | dm__utils__select_line '2'
  }
  run dummy_function

  assert_no_error
  assert_status 0
  assert_output 'line_2'
}

test__zero_index__error_emitted() {
  input_string="$( \
    dm_tools__echo 'line_1'; \
    dm_tools__echo 'line_2'; \
    dm_tools__echo 'line_3'; \
  )"

  dummy_function() {
    dm_tools__echo "$input_string" | dm__utils__select_line '0'
  }
  run dummy_function

  assert_error
  assert_status 1
  assert_no_output
}

test__negative_index__error_emitted() {
  input_string="$( \
    dm_tools__echo 'line_1'; \
    dm_tools__echo 'line_2'; \
    dm_tools__echo 'line_3'; \
  )"

  dummy_function() {
    dm_tools__echo "$input_string" | dm__utils__select_line '-2'
  }
  run dummy_function

  assert_error
  assert_status 1
  assert_no_output
}

test__index_is_over_the_range__empty_line_should_be_returned() {
  input_string="$( \
    dm_tools__echo 'line_1'; \
    dm_tools__echo 'line_2'; \
    dm_tools__echo 'line_3'; \
  )"

  dummy_function() {
    dm_tools__echo "$input_string" | dm__utils__select_line '42'
  }
  run dummy_function

  assert_no_error
  assert_status 0
  assert_no_output
}