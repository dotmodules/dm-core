DM__GLOBAL__RUNTIME__DM_REPO_ROOT="../../.."
. "${DM__GLOBAL__RUNTIME__DM_REPO_ROOT}/src/dm.lib.sh"

setup() {
  # Creating dummy files that are located in the temp test directory
  _DM__GLOBAL__VARIABLES__CACHE_FILE="${DM_TEST__TMP_TEST_DIR}/var_cache"
  _DM__GLOBAL__VARIABLES__TEMP_FILE="${DM_TEST__TMP_TEST_DIR}/tmp_file"

  touch "$_DM__GLOBAL__VARIABLES__CACHE_FILE"
  touch "$_DM__GLOBAL__VARIABLES__TEMP_FILE"

  DM__GLOBAL__VARIABLES__CACHE_FILE=$( \
    realpath --relative-to="$(pwd)" "$_DM__GLOBAL__VARIABLES__CACHE_FILE" \
  )
  DM__GLOBAL__VARIABLES__TEMP_FILE=$( \
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

test__variables__variables_can_be_loaded() {
  _dm_lib__variables__collect_all_variables_from_modules() {
    echo "VAR1 v11 v12"
    echo "VAR2 v21 v22"
  }
  dm_lib__variables__load
  run cat "$DM__GLOBAL__VARIABLES__CACHE_FILE"

  assert_status 0
  assert_output_line_count 2

  assert_line_at_index 1 "VAR1 v11 v12"
  assert_line_at_index 2 "VAR2 v21 v22"
}

test__variables__variables_can_be_merged() {
  _dm_lib__variables__collect_all_variables_from_modules() {
    echo "VAR1 v1 v2"
    echo "VAR1 v3 v4"
  }
  dm_lib__variables__load
  run cat "$DM__GLOBAL__VARIABLES__CACHE_FILE"

  assert_status 0
  assert_output_line_count 1

  assert_line_at_index 1 "VAR1 v1 v2 v3 v4"
}

test__variables__variables_get_sorted() {
  _dm_lib__variables__collect_all_variables_from_modules() {
    echo "VAR1 v2 v1"
  }
  dm_lib__variables__load
  run cat "$DM__GLOBAL__VARIABLES__CACHE_FILE"

  assert_status 0
  assert_output_line_count 1

  assert_line_at_index 1 "VAR1 v1 v2"
}

test__variables__multiple_merges_could_be_executed() {
  _dm_lib__variables__collect_all_variables_from_modules() {
    echo "VAR2 v24 v23"
    echo "VAR3 v32 v31"
    echo "VAR1 v11"
    echo "VAR2 v22 v21"
  }
  dm_lib__variables__load
  run cat "$DM__GLOBAL__VARIABLES__CACHE_FILE"

  assert_status 0
  assert_output_line_count 3

  assert_line_at_index 1 "VAR1 v11"
  assert_line_at_index 2 "VAR2 v21 v22 v23 v24"
  assert_line_at_index 3 "VAR3 v31 v32"
}

test__variables__variables_gets_deduplicated() {
  _dm_lib__variables__collect_all_variables_from_modules() {
    echo "VAR1 v1"
    echo "VAR1 v1 v2"
  }
  dm_lib__variables__load
  run cat "$DM__GLOBAL__VARIABLES__CACHE_FILE"

  assert_status 0
  assert_output_line_count 1

  assert_line_at_index 1 "VAR1 v1 v2"
}
