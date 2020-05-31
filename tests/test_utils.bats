load $DM_LIB_MUT
load test_helper


@test "utils - normalize_whitespace - whitespace gets squished" {
  input="dummy         content      item"
  expected="dummy content item"
  dummy_function() {
    echo "$input" | _dm_lib__utils__normalize_whitespace
  }
  run dummy_function

  test $status -eq 0
  test "$output" = "$expected"
}

@test "utils - remove_surrounding_whitespace - whitespace gets removed" {
  input="        dummy  content   "
  expected="dummy  content"
  dummy_function() {
    echo "$input" | _dm_lib__utils__remove_surrounding_whitespace
  }
  run dummy_function

  test $status -eq 0
  test "$output" = "$expected"
}

@test "utils - trim_list - first item can be acuired" {
  input="item1 item2 item3"
  expected="item1"
  dummy_function() {
    echo "$input" | _dm_lib__utils__trim_list 1
  }
  run dummy_function

  test $status -eq 0
  test "$output" = "$expected"
}

@test "utils - trim_list - itervals can be used" {
  input="item1 item2 item3"
  expected="item1 item2"
  dummy_function() {
    echo "$input" | _dm_lib__utils__trim_list 1-2
  }
  run dummy_function

  test $status -eq 0
  test "$output" = "$expected"
}

@test "utils - trim_list - endless interval can be used" {
  input="item1 item2 item3"
  expected="item2 item3"
  dummy_function() {
    echo "$input" | _dm_lib__utils__trim_list 2-
  }
  run dummy_function

  test $status -eq 0
  test "$output" = "$expected"
}

@test "utils - trim_list - messy list gets normalized" {
  input="     item1     item2  item3                "
  expected="item1 item2"
  dummy_function() {
    echo "$input" | _dm_lib__utils__trim_list 1-2
  }
  run dummy_function

  test $status -eq 0
  test "$output" = "$expected"
}

@test "utils - select_line - line can be selected case 1" {
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

  test $status -eq 0
  test "$output" = "$expected"
}

@test "utils - select_line - line can be selected case 2" {
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

  test $status -eq 0
  test "$output" = "$expected"
}

@test "utils - parse_list - messy list gets normalized" {
  input="     item1     item2  item3                "
  expected="item1 item2 item3"
  dummy_function() {
    echo "$input" | _dm_lib__utils__parse_list
  }
  run dummy_function

  test $status -eq 0
  test "$output" = "$expected"
}
