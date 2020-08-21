load $DM_LIB_MUT
load $BATS_MOCK
load $BATS_ASSERT
load $BATS_SUPPORT
load test_helper

@test "utils - expand_path - home variable can be expanded" {
  HOME='/this/is/a/fake/home'

  input='$HOME/hello/bin'
  expected='/this/is/a/fake/home/hello/bin'

  run _dm_lib__links__expand_path "$input"

  assert test $status -eq 0
  assert_output "$expected"
}

@test "links - expand_path - tilde can be expanded" {
  HOME='/this/is/a/fake/home'

  input='~/hello/bin'
  expected='/this/is/a/fake/home/hello/bin'

  run _dm_lib__links__expand_path "$input"

  assert test $status -eq 0
  assert_output "$expected"
}

@test "links - check_link - link does not exist" {
  base="${DM__TEST__TEST_DIR}/links"
  rm -rf "$base"
  mkdir -p "$base"

  link_name="${base}/link_name"

  expected="$DM__GLOBAL__CONFIG__LINK__NOT_EXISTS"

  run _dm_lib__links__check_link "$target_path" "$link_name"

  assert test $status -eq 0
  assert_output "$expected"
}

@test "links - check_link - link exist but points to different path" {
  base="${DM__TEST__TEST_DIR}/links"
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

  assert test $status -eq 0
  assert_output "$expected"
}

@test "links - check_link - link exist and points to the same target path" {
  base="${DM__TEST__TEST_DIR}/links"
  rm -rf "$base"
  mkdir -p "$base"

  target_path="${base}/target_file"
  touch "$target_path"

  link_name="${base}/link_name"
  ln -s "$target_path" "$link_name"

  expected="$DM__GLOBAL__CONFIG__LINK__EXISTS_WITH_TARGET"

  run _dm_lib__links__check_link "$target_path" "$link_name"

  assert test $status -eq 0
  assert_output "$expected"
}

@test "links - get_link_target_path - link target can be accessed" {
  base="${DM__TEST__TEST_DIR}/links"
  rm -rf "$base"
  mkdir -p "$base"

  target_path="${base}/target_file"
  touch "$target_path"
  absolute_target_path="$(readlink -f "$target_path")"

  link_name="${base}/link_name"
  ln -s "$target_path" "$link_name"

  expected="$target_path"

  run _dm_lib__links__get_link_target_path "$link_name"

  assert test $status -eq 0
  assert_output "$expected"

}

@test "links - get_link_target_path - even broken links can be resolved" {
  dummy_link_target="dummy_link_target"
  link_name="dummy_link"
  ln -s "$dummy_link_target" "$link_name"

  expected="$dummy_link_target"

  run _dm_lib__links__get_link_target_path "$link_name"

  rm "$link_name"

  assert test $status -eq 0
  assert_output "$expected"
}

@test "links - raw link string can be processed" {
  # Mocking readlink
  readlink_mark='resolved'
  readlink() {
    # first parameter should be the '-f' flag
    path="$2"
    echo "${readlink_mark}/${path}"
  }

  # Mocking path expansion
  expand_mark='expanded'
  _dm_lib__links__expand_path() {
    path="$1"
    echo "${expand_mark}/${path}"
  }

  dummy_file='dummy_file'
  dummy_link_path='/dummy/link/path'
  raw_link_string="${dummy_file} ${dummy_link_path}"
  module="dummy_relative_module_path"

  expected_target_file="${readlink_mark}/${module}/${dummy_file}"
  expected_link_name="${expand_mark}/${dummy_link_path}"

  expected="${expected_target_file} ${expected_link_name}"

  run _dm_lib__links__preprocess_raw_link_string "$module" "$raw_link_string"

  assert test $status -eq 0
  assert_output "$expected"
}
