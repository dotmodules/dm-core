DM__GLOBAL__RUNTIME__DM_REPO_ROOT="../../.."
# shellcheck source=../../../src/dm.lib.sh
. "${DM__GLOBAL__RUNTIME__DM_REPO_ROOT}/src/dm.lib.sh"

test__expand_path__home_variable_can_be_expanded() {
  HOME='/this/is/a/fake/home'

  input='$HOME/hello/bin'
  expected='/this/is/a/fake/home/hello/bin'

  run _dm_lib__links__expand_path "$input"

  assert_status 0
  assert_output "$expected"
}

test__expand_path__tilde_can_be_expanded() {
  HOME='/this/is/a/fake/home'

  input='~/hello/bin'
  expected='/this/is/a/fake/home/hello/bin'

  run _dm_lib__links__expand_path "$input"

  assert_status 0
  assert_output "$expected"
}

test__check_link__link_does_not_exist() {
  base="${DM_TEST__TMP_TEST_DIR}/links"
  rm -rf "$base"
  mkdir -p "$base"

  link_name="${base}/link_name"

  expected="$DM__GLOBAL__CONFIG__LINK__NOT_EXISTS"

  target_path="${base}/target_file"
  touch "$target_path"

  run _dm_lib__links__check_link "$target_path" "$link_name"

  assert_status 0
  assert_output "$expected"
}

test__check_link__link_exist_but_points_to_different_path() {
  base="${DM_TEST__TMP_TEST_DIR}/links"
  rm -rf "$base"
  mkdir -p "$base"

  target_path="${base}/target_file"
  touch "$target_path"

  other_target_path="${base}/other_target_file"
  touch "$other_target_path"

  link_name="${base}/link_name"
  ln -s "$other_target_path" "$link_name"

  expected="$DM__GLOBAL__CONFIG__LINK__EXISTS_BUT_TARGET_MISMATCH"

  run _dm_lib__links__check_link "$target_path" "$link_name"

  assert_status 0
  assert_output "$expected"
}

test__check_link__link_exist_and_points_to_the_same_target_path() {
  base="${DM_TEST__TMP_TEST_DIR}/links"
  rm -rf "$base"
  mkdir -p "$base"

  target_path="${base}/target_file"
  touch "$target_path"

  link_name="${base}/link_name"
  ln -s "$target_path" "$link_name"

  expected="$DM__GLOBAL__CONFIG__LINK__EXISTS_WITH_TARGET"

  run _dm_lib__links__check_link "$target_path" "$link_name"

  assert_status 0
  assert_output "$expected"
}

test__get_link_target_path__link_target_can_be_accessed() {
  base="${DM_TEST__TMP_TEST_DIR}/links"
  rm -rf "$base"
  mkdir -p "$base"

  target_path="${base}/target_file"
  touch "$target_path"
  absolute_target_path="$(readlink -f "$target_path")"

  link_name="${base}/link_name"
  ln -s "$target_path" "$link_name"

  expected="$target_path"

  run _dm_lib__links__get_link_target_path "$link_name"

  assert_status 0
  assert_output "$expected"

}

test__get_link_target_path__even_broken_links_can_be_resolved() {
  dummy_link_target="dummy_link_target"
  link_name="dummy_link"
  ln -s "$dummy_link_target" "$link_name"

  expected="$dummy_link_target"

  run _dm_lib__links__get_link_target_path "$link_name"

  rm "$link_name"

  assert_status 0
  assert_output "$expected"
}

# test__raw_link__string_can_be_processed() {
#   # Mocking readlink
#   readlink_mark='resolved'
#   readlink() {
#     # first parameter should be the '-f' flag
#     path="$2"
#     echo "${readlink_mark}/${path}"
#   }

#   echo "imre"
#   # Mocking path expansion
#   expand_mark='expanded'
#   _dm_lib__links__expand_path() {
#     path="$1"
#     echo "${expand_mark}/${path}"
#   }
#   echo "hello"

#   dummy_file='dummy_file'
#   dummy_link_path='/dummy/link/path'
#   raw_link_string="${dummy_file} ${dummy_link_path}"
#   module="dummy_relative_module_path"

#   expected_target_file="${readlink_mark}/${module}/${dummy_file}"
#   expected_link_name="${expand_mark}/${dummy_link_path}"

#   expected="${expected_target_file} ${expected_link_name}"

#   run _dm_lib__links__preprocess_raw_link_string "$module" "$raw_link_string"

#   assert_status 1
#   assert_output "$expected"
# }
