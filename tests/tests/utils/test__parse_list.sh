#!/bin/sh

export DM__GLOBAL__RUNTIME__REPO_ROOT="../../.."
# shellcheck source=../../../src/load_sources.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/load_sources.sh"

setup_file() {
  dm__debug__init
}

test__messy_line_can_be_normalized() {
  input_string='    item_1     item_2       item_3          '

  dummy_function() {
    dm_tools__echo "$input_string" | dm__utils__parse_list
  }
  run dummy_function

  assert_no_error
  assert_status 0
  assert_output 'item_1 item_2 item_3'
}

test__multiline_input_can_be_handled() {
  input_string="$( \
    dm_tools__echo '    a   b c          '; \
    dm_tools__echo '  d     e      f   '; \
    dm_tools__echo '    g  h  i   '; \
  )"

  dummy_function() {
    dm_tools__echo "$input_string" | dm__utils__parse_list
  }
  run dummy_function

  assert_no_error
  assert_status 0
  assert_output_line_count 3
  assert_output_line_at_index 1 'a b c'
  assert_output_line_at_index 2 'd e f'
  assert_output_line_at_index 3 'g h i'
}
