. ../../../src/dm.lib.sh

test__normalize_whitespace__whitespace_gets_squished() {
  input="dummy         content      item"
  expected="dummy content item"
  dummy_function() {
    echo "$input" | _dm_lib__utils__normalize_whitespace
  }
  run dummy_function

  assert_status 0
  assert_output "$expected"
}

test__remove_surrounding_whitespace__whitespace_gets_removed() {
  input="        dummy  content   "
  expected="dummy  content"
  dummy_function() {
    echo "$input" | _dm_lib__utils__remove_surrounding_whitespace
  }
  run dummy_function

  assert_status 0
  assert_output "$expected"
}

test__trim_list__first_item_can_be_acuired() {
  input="item1 item2 item3"
  expected="item1"
  dummy_function() {
    echo "$input" | _dm_lib__utils__trim_list 1
  }
  run dummy_function

  assert_status 0
  assert_output "$expected"
}

test__trim_list__intervals_can_be_used() {
  input="item1 item2 item3"
  expected="item1 item2"
  dummy_function() {
    echo "$input" | _dm_lib__utils__trim_list 1-2
  }
  run dummy_function

  assert_status 0
  assert_output "$expected"
}

test__trim_list__endless_interval_can_be_used() {
  input="item1 item2 item3"
  expected="item2 item3"
  dummy_function() {
    echo "$input" | _dm_lib__utils__trim_list 2-
  }
  run dummy_function

  assert_status 0
  assert_output "$expected"
}

test__trim_list__whitespace_gets_squeezed() {
  input="item1     item2  item3"
  expected="item1 item2"
  dummy_function() {
    echo "$input" | _dm_lib__utils__trim_list 1-2
  }
  run dummy_function

  assert_status 0
  assert_output "$expected"
}

test__select_line__line_can_be_selected_case_1() {
  generator_function() {
    echo "dummy line 1"
    echo "dummy line 2"
    echo "dummy line 3"
  }
  expected="dummy line 1"

  dummy_function() {
    generator_function | _dm_lib__utils__select_line 1
  }
  run dummy_function

  assert_status 0
  assert_output "$expected"
}

test__select_line__line_can_be_selected_case_2() {
  generator_function() {
    echo "dummy line 1"
    echo "dummy line 2"
    echo "dummy line 3"
  }
  expected="dummy line 3"

  dummy_function() {
    generator_function | _dm_lib__utils__select_line 3
  }
  run dummy_function

  assert_status 0
  assert_output "$expected"
}

test__parse_list__messy_list_gets_normalized() {
  input="     item1     item2  item3                "
  expected="item1 item2 item3"
  dummy_function() {
    echo "$input" | _dm_lib__utils__parse_list
  }
  run dummy_function

  assert_status 0
  assert_output "$expected"
}
