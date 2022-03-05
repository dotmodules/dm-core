#!/bin/sh

export DM__GLOBAL__RUNTIME__REPO_ROOT="../../.."
# shellcheck source=../../../src/load_sources.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/load_sources.sh"

setup_file() {
  dm__debug__init
}

test__existing_parameter_can_be_loaded() {
  test_case_dir="$3"
  dummy_file_path="${test_case_dir}/dummy_file.txt"
  dummy_parameter_name='DUMMY_NAME'
  dummy_value="dummy_value"
  dm_tools__echo "${dummy_parameter_name}=${dummy_value}" > "$dummy_file_path"

  run _dm__parameters__load "$dummy_parameter_name" "$dummy_file_path"

  assert_no_error
  assert_status 0
  assert_output_line_count 1
  assert_output "$dummy_value"
}

test__existing_parameter_can_be_selected_From_other_parameters() {
  test_case_dir="$3"
  dummy_file_path="${test_case_dir}/dummy_file.txt"
  dummy_parameter_name='DUMMY_NAME'
  dummy_value="dummy_value"
  {
    dm_tools__echo 'irrelevant line 1';
    dm_tools__echo 'irrelevant line 2';
    dm_tools__echo "${dummy_parameter_name}=${dummy_value}";
    dm_tools__echo 'irrelevant line 3';
  } > "$dummy_file_path"

  run _dm__parameters__load "$dummy_parameter_name" "$dummy_file_path"

  assert_no_error
  assert_status 0
  assert_output_line_count 1
  assert_output "$dummy_value"
}

test__non_existing_parameter_returns_error() {
  test_case_dir="$3"
  dummy_file_path="${test_case_dir}/dummy_file.txt"
  dm_tools__touch "$dummy_file_path"

  run _dm__parameters__load 'INVALID_PARAMETER_NAME' "$dummy_file_path"

  assert_no_output
  assert_no_error
  assert_status 1
  assert_output_line_count 0
}

test__existing_parameter_but_invalid_syntax() {
  test_case_dir="$3"
  dummy_file_path="${test_case_dir}/dummy_file.txt"
  dummy_parameter_name='DUMMY_NAME'
  dummy_value="dummy_value"
  dm_tools__echo "${dummy_parameter_name}     ${dummy_value}" > "$dummy_file_path"

  run _dm__parameters__load "$dummy_parameter_name" "$dummy_file_path"

  assert_no_output
  assert_no_error
  assert_status 1
  assert_output_line_count 0
}