load $DM_LIB_MUT
load $BATS_MOCK
load $BATS_ASSERT
load $BATS_SUPPORT
load test_helper


setup() {
  PARAMTER_FILE="${DM__TEST__TEST_DIR}/paramfile"
  touch "$PARAMTER_FILE"
  export PARAMTER_FILE
  echo "1 41" >> "$PARAMTER_FILE"
  echo "2 42" >> "$PARAMTER_FILE"
  echo "3 43" >> "$PARAMTER_FILE"
}

teardown() {
  rm "$PARAMTER_FILE"
}

@test "parameters - parameter can be loaded from the parameter file by index" {
  run dm_lib__config__load_parameter "1" "??" "$PARAMTER_FILE"

  assert test $status -eq 0
  assert_output "41"
}

@test "parameters - default value is returned if no match found" {
  run dm_lib__config__load_parameter "8" "00" "$PARAMTER_FILE"

  assert test $status -eq 0
  assert_output "00"
}

@test "parameters - invalid file, default value returned" {
  run dm_lib__config__load_parameter "8" "00" "invalid_file_path"

  assert test $status -eq 0
  assert_output "00"
}
