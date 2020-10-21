. ../../../src/dm.lib.sh

setup_modules_test() {
  # Simulating the relative path here to the modules root directory.
  DM__GLOBAL__RUNTIME__MODULES_ROOT=$( \
    realpath --relative-to="$(pwd)" "${DM_TEST__TMP_TEST_DIR}/modules" \
  )
  # Helper variable to have shorter lines.
  CONF_FILE="$DM__GLOBAL__CONFIG__CONFIG_FILE_NAME"

  mkdir -p "${DM__GLOBAL__RUNTIME__MODULES_ROOT}"

  mkdir -p "${DM__GLOBAL__RUNTIME__MODULES_ROOT}/module1"
  touch    "${DM__GLOBAL__RUNTIME__MODULES_ROOT}/module1/${CONF_FILE}"

  mkdir -p "${DM__GLOBAL__RUNTIME__MODULES_ROOT}/module2"
  touch    "${DM__GLOBAL__RUNTIME__MODULES_ROOT}/module2/${CONF_FILE}"

  mkdir -p "${DM__GLOBAL__RUNTIME__MODULES_ROOT}/nested/module3"
  touch    "${DM__GLOBAL__RUNTIME__MODULES_ROOT}/nested/module3/${CONF_FILE}"

  # This should be not detected as a module.
  mkdir -p "${DM__GLOBAL__RUNTIME__MODULES_ROOT}/nested/module4"
  touch    "${DM__GLOBAL__RUNTIME__MODULES_ROOT}/nested/module4/some_file"

  dm_lib__cache__init
  dm_lib__modules__load
}

test__discovery__modules_can_be_discovered_inside_the_modules_root() {
  setup_modules_test

  run dm_lib__modules__list

  assert_status 0
  assert_output_line_count 3

  assert_line_partially_at_index 1 "module1"
  assert_line_partially_at_index 2 "module2"
  assert_line_partially_at_index 3 "nested/module3"


  assert_file "$(dm_test__utils__get_line_from_output_by_index 1)/${DM__GLOBAL__CONFIG__CONFIG_FILE_NAME}"
  assert_file "$(dm_test__utils__get_line_from_output_by_index 2)/${DM__GLOBAL__CONFIG__CONFIG_FILE_NAME}"
  assert_file "$(dm_test__utils__get_line_from_output_by_index 3)/${DM__GLOBAL__CONFIG__CONFIG_FILE_NAME}"
}

test__selection__module_can_be_selected_by_index() {
  dm_lib__modules__list() {
    echo "one"
    echo "two"
    echo "three"
  }

  selected_index="2"
  expected="two"

  run dm_lib__modules__module_for_index "$selected_index"

  assert_status 0
  assert_output "$expected"
}

test__selection__index_is_over_the_range() {
  dm_lib__modules__list() {
    echo "one"
    echo "two"
    echo "three"
  }

  selected_index="4"

  run dm_lib__modules__module_for_index "$selected_index"

  assert_status 1
}

test__selection__index_is_below_the_range() {
  dm_lib__modules__list() {
    echo "one"
    echo "two"
    echo "three"
  }

  selected_index="0"

  run dm_lib__modules__module_for_index "$selected_index"

  assert_status 1
}

test__selection__index_is_not_a_number() {
  dm_lib__modules__list() {
    echo "one"
    echo "two"
    echo "three"
  }

  selected_index="not an index"

  run dm_lib__modules__module_for_index "$selected_index"

  assert_status 1
}
