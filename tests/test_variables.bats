load $DM_LIB_MUT
load $BATS_MOCK
load $BATS_ASSERT
load $BATS_SUPPORT
load test_helper


@test "variables - variables can be loaded" {
  _dm_lib__variables__init() {
    :  # nop
  }
  _dm_lib__variables__get_variables_from_modules() {
    echo "VAR1 v11 v12"
    echo "VAR2 v21 v22"
  }
  _dm_lib__variables__write_to_cache() {
    merged_variables="$1"
    echo "$merged_variables"
  }
  run dm_lib__variables__load

  assert test $status -eq 0
  assert test ${#lines[@]} -eq 2

  assert_line --index 0 "VAR1 v11 v12"
  assert_line --index 1 "VAR2 v21 v22"
}

@test "variables - variables can be merged" {
  _dm_lib__variables__init() {
    :  # nop
  }
  _dm_lib__variables__get_variables_from_modules() {
    echo "VAR1 v1 v2"
    echo "VAR1 v3 v4"
  }
  _dm_lib__variables__write_to_cache() {
    merged_variables="$1"
    echo "$merged_variables"
  }
  run dm_lib__variables__load

  assert test $status -eq 0
  assert test ${#lines[@]} -eq 1

  assert_line --index 0 "VAR1 v1 v2 v3 v4"
}

@test "variables - variables gets sorted" {
  _dm_lib__variables__init() {
    :  # nop
  }
  _dm_lib__variables__get_variables_from_modules() {
    echo "VAR1 v2 v1"
  }
  _dm_lib__variables__write_to_cache() {
    merged_variables="$1"
    echo "$merged_variables"
  }
  run dm_lib__variables__load

  assert test $status -eq 0
  assert test ${#lines[@]} -eq 1

  assert_line --index 0 "VAR1 v1 v2"
}

@test "variables - multiple merges could be executed" {
  _dm_lib__variables__init() {
    :  # nop
  }
  _dm_lib__variables__get_variables_from_modules() {
    echo "VAR2 v24 v23"
    echo "VAR3 v32 v31"
    echo "VAR1 v11"
    echo "VAR2 v22 v21"
  }
  _dm_lib__variables__write_to_cache() {
    merged_variables="$1"
    echo "$merged_variables" | sort
  }
  run dm_lib__variables__load

  assert test $status -eq 0
  assert test ${#lines[@]} -eq 3

  assert_line --index 0 "VAR1 v11"
  assert_line --index 1 "VAR2 v21 v22 v23 v24"
  assert_line --index 2 "VAR3 v31 v32"
}
