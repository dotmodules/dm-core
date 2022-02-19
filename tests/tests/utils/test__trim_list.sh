#!/bin/sh

export DM__GLOBAL__RUNTIME__REPO_ROOT="../../.."
# shellcheck source=../../../src/init.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/init.sh"

test__line_can_be_trimmed() {
  input_string='item_1 item_2 item_3'

  dummy_function() {
    dm_tools__echo "$input_string" | dm__utils__trim_list '2'
  }
  run dummy_function

  assert_no_error
  assert_status 0
  assert_output 'item_2'
}

test__range_can_be_selected() {
  input_string='item_1 item_2 item_3'

  dummy_function() {
    dm_tools__echo "$input_string" | dm__utils__trim_list '2-3'
  }
  run dummy_function

  assert_no_error
  assert_status 0
  assert_output 'item_2 item_3'
}

test__over_the_range_item_should_be_empty() {
  input_string='item_1 item_2 item_3'

  dummy_function() {
    dm_tools__echo "$input_string" | dm__utils__trim_list '4'
  }
  run dummy_function

  assert_no_error
  assert_status 0
  assert_output ''
}

test__messy_list_can_be_handled() {
  input_string='   item_1     item_2  item_3   '

  dummy_function() {
    dm_tools__echo "$input_string" | dm__utils__trim_list '3'
  }
  run dummy_function

  assert_no_error
  assert_status 0
  assert_output 'item_3'
}

test__multiline_input__can_be_trimmed() {
  input_string="$( \
    dm_tools__echo 'item_1 item_2 item_3'; \
    dm_tools__echo 'item_1 item_2 item_3'; \
    dm_tools__echo 'item_1 item_2 item_3'; \
  )"

  dummy_function() {
    dm_tools__echo "$input_string" | dm__utils__trim_list '2'
  }
  run dummy_function

  assert_no_error
  assert_status 0
  assert_output_line_count 3
  assert_output_line_at_index 1 'item_2'
  assert_output_line_at_index 2 'item_2'
  assert_output_line_at_index 3 'item_2'
}

test__multiline_input__range_can_be_selected() {
  input_string="$( \
    dm_tools__echo 'item_1 item_2 item_3'; \
    dm_tools__echo 'item_1 item_2 item_3'; \
    dm_tools__echo 'item_1 item_2 item_3'; \
  )"

  dummy_function() {
    dm_tools__echo "$input_string" | dm__utils__trim_list '1-2'
  }
  run dummy_function

  assert_no_error
  assert_status 0
  assert_output_line_count 3
  assert_output_line_at_index 1 'item_1 item_2'
  assert_output_line_at_index 2 'item_1 item_2'
  assert_output_line_at_index 3 'item_1 item_2'
}

test__multiline_input__over_the_range_should_be_empty() {
  input_string="$( \
    dm_tools__echo 'item_1 item_2 item_3'; \
    dm_tools__echo 'item_1 item_2 item_3'; \
    dm_tools__echo 'item_1 item_2 item_3'; \
  )"

  dummy_function() {
    dm_tools__echo "$input_string" | dm__utils__trim_list '42'
  }
  run dummy_function

  assert_no_error
  assert_status 0
  assert_output_line_count 3
  assert_output_line_at_index 1 ''
  assert_output_line_at_index 2 ''
  assert_output_line_at_index 3 ''
}

test__multiline_input__messy_list_can_be_handled() {
  input_string="$( \
    dm_tools__echo '     item_1    item_2                 item_3    '; \
    dm_tools__echo '   item_1    item_2           item_3    '; \
    dm_tools__echo '      item_1    item_2      item_3    '; \
  )"

  dummy_function() {
    dm_tools__echo "$input_string" | dm__utils__trim_list '1'
  }
  run dummy_function

  assert_no_error
  assert_status 0
  assert_output_line_count 3
  assert_output_line_at_index 1 'item_1'
  assert_output_line_at_index 2 'item_1'
  assert_output_line_at_index 3 'item_1'
}

test__invalid_items_definition() {
  input_string='item_1 item_2 item_3'

  dummy_function() {
    dm_tools__echo "$input_string" | dm__utils__trim_list 'invalid'
  }
  run dummy_function

  assert_error
  assert_status 1
  assert_no_output
}

test__multiline_input__invalid_items_definition() {
  input_string="$( \
    dm_tools__echo 'item_1 item_2 item_3'; \
    dm_tools__echo 'item_1 item_2 item_3'; \
    dm_tools__echo 'item_1 item_2 item_3'; \
  )"

  dummy_function() {
    dm_tools__echo "$input_string" | dm__utils__trim_list 'invalid'
  }
  run dummy_function

  assert_error
  assert_status 1
  assert_no_output
}