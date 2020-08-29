load $DM_LIB_MUT
load $BATS_MOCK
load $BATS_ASSERT
load $BATS_SUPPORT
load test_helper


setup() {
  PARAMETER_FILE="${DM__TEST__TEST_DIR}/paramfile"
  touch "$PARAMETER_FILE"
  export PARAMETER_FILE
  echo "1 41" >> "$PARAMETER_FILE"
  echo "2 42" >> "$PARAMETER_FILE"
  echo "3 43" >> "$PARAMETER_FILE"
  echo "4  extra whitespace" >> "$PARAMETER_FILE"
}

teardown() {
  rm "$PARAMETER_FILE"
}

@test "parameters - parameter can be loaded from the parameter file by index" {
  run dm_lib__config__load_parameter "1" "??" "$PARAMETER_FILE"

  assert test $status -eq 0
  assert_output "41"
}

@test "parameters - default value is returned if no match found" {
  run dm_lib__config__load_parameter "8" "00" "$PARAMETER_FILE"

  assert test $status -eq 0
  assert_output "00"
}

@test "parameters - invalid file, default value returned" {
  run dm_lib__config__load_parameter "8" "00" "invalid_file_path"

  assert test $status -eq 0
  assert_output "00"
}

@test "parameters - extra whitespace is preserved" {
  run dm_lib__config__load_parameter "4" "??" "$PARAMETER_FILE"

  assert test $status -eq 0
  assert_output " extra whitespace"
}
