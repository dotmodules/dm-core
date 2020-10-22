DM__GLOBAL__RUNTIME__DM_REPO_ROOT="../../.."
. "${DM__GLOBAL__RUNTIME__DM_REPO_ROOT}/src/dm.lib.sh"

setup() {
  PARAMETER_FILE="${DM_TEST__TMP_TEST_DIR}/paramfile"
  echo "1 41" >> "$PARAMETER_FILE"
  echo "2 42" >> "$PARAMETER_FILE"
  echo "3 43" >> "$PARAMETER_FILE"
  echo "4  extra whitespace" >> "$PARAMETER_FILE"
}

teardown() {
  rm "$PARAMETER_FILE"
}

test__parameter_can_be_loaded_from_the_parameter_file_by_index() {
  run dm_lib__config__load_parameter "1" "??" "$PARAMETER_FILE"

  assert_status 0
  assert_output 41
}

test__default_value_is_returned_if_no_match_found() {
  run dm_lib__config__load_parameter "8" "00" "$PARAMETER_FILE"

  assert_status 0
  assert_output 00
}

test__invalid_file__default_value_returned() {
  run dm_lib__config__load_parameter "8" "00" "invalid_file_path"

  assert_status 0
  assert_output 00
}

test__extra_whitespace_is_preserved() {
  run dm_lib__config__load_parameter "4" "??" "$PARAMETER_FILE"

  assert_status 0
  assert_output ' extra whitespace'
}
