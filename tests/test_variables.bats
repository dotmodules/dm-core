load $DM_LIB_MUT
load $BATS_MOCK
load $BATS_ASSERT
load $BATS_SUPPORT
load test_helper

setup() {
  # Creating dummy files that are located in the temp test directory
  _DM__GLOBAL__VARIABLES__CACHE_FILE="${DM__TEST__TEST_DIR}/var_cache"
  _DM__GLOBAL__VARIABLES__TEMP_FILE="${DM__TEST__TEST_DIR}/tmp_file"

  touch "$_DM__GLOBAL__VARIABLES__CACHE_FILE"
  touch "$_DM__GLOBAL__VARIABLES__TEMP_FILE"

  export DM__GLOBAL__VARIABLES__CACHE_FILE=$( \
    realpath --relative-to="$(pwd)" "$_DM__GLOBAL__VARIABLES__CACHE_FILE" \
  )
  export DM__GLOBAL__VARIABLES__TEMP_FILE=$( \
    realpath --relative-to="$(pwd)" "$_DM__GLOBAL__VARIABLES__TEMP_FILE" \
  )

  dm_lib__cache__init

  # Prevent to writing to the cache file. Sort is added explicitly as this
  # feature is implemented in the cache writer function that we are mocking
  # here.
  _dm_lib__variables__write_to_cache() {
    merged_variables="$1"
    echo "$merged_variables" | sort
  }
}

@test "variables - variables can be loaded" {
  _dm_lib__variables__collect_all_variables_from_modules() {
    echo "VAR1 v11 v12"
    echo "VAR2 v21 v22"
  }
  dm_lib__variables__load
  run cat "$DM__GLOBAL__VARIABLES__CACHE_FILE"

  assert test $status -eq 0
  assert test ${#lines[@]} -eq 2

  assert_line --index 0 "VAR1 v11 v12"
  assert_line --index 1 "VAR2 v21 v22"
}

@test "variables - variables can be merged" {
  _dm_lib__variables__collect_all_variables_from_modules() {
    echo "VAR1 v1 v2"
    echo "VAR1 v3 v4"
  }
  dm_lib__variables__load
  run cat "$DM__GLOBAL__VARIABLES__CACHE_FILE"

  assert test $status -eq 0
  assert test ${#lines[@]} -eq 1

  assert_line --index 0 "VAR1 v1 v2 v3 v4"
}

@test "variables - variables gets sorted" {
  _dm_lib__variables__collect_all_variables_from_modules() {
    echo "VAR1 v2 v1"
  }
  dm_lib__variables__load
  run cat "$DM__GLOBAL__VARIABLES__CACHE_FILE"

  assert test $status -eq 0
  assert test ${#lines[@]} -eq 1

  assert_line --index 0 "VAR1 v1 v2"
}

@test "variables - multiple merges could be executed" {
  _dm_lib__variables__collect_all_variables_from_modules() {
    echo "VAR2 v24 v23"
    echo "VAR3 v32 v31"
    echo "VAR1 v11"
    echo "VAR2 v22 v21"
  }
  dm_lib__variables__load
  run cat "$DM__GLOBAL__VARIABLES__CACHE_FILE"

  assert test $status -eq 0
  assert test ${#lines[@]} -eq 3

  assert_line --index 0 "VAR1 v11"
  assert_line --index 1 "VAR2 v21 v22 v23 v24"
  assert_line --index 2 "VAR3 v31 v32"
}

@test "variables - variables gets deduplicated" {
  _dm_lib__variables__collect_all_variables_from_modules() {
    echo "VAR1 v1"
    echo "VAR1 v1 v2"
  }
  dm_lib__variables__load
  run cat "$DM__GLOBAL__VARIABLES__CACHE_FILE"

  assert test $status -eq 0
  assert test ${#lines[@]} -eq 1

  assert_line --index 0 "VAR1 v1 v2"
}
