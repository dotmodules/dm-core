load $DM_LIB_MUT
load $BATS_MOCK
load $BATS_ASSERT
load $BATS_SUPPORT
load test_helper


setup_modules() {
  # Simulating the relative path here ot the modules root directory.
  export DM__GLOBAL__RUNTIME__MODULES_ROOT=$( \
    realpath --relative-to="$(pwd)" "${DM__TEST__TEST_DIR}/modules" \
  )
  # Helper variable for shorter lines..
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
}

@test "modules - modules can be discovered inside the modules root" {
  setup_modules

  run dm_lib__modules__list

  assert test $status -eq 0
  assert test ${#lines[@]} -eq 3

  assert_line --index 0 --partial "module1"
  assert_line --index 1 --partial "module2"
  assert_line --index 2 --partial "nested/module3"

  assert test -f "${lines[0]}/${DM__GLOBAL__CONFIG__CONFIG_FILE_NAME}"
  assert test -f "${lines[1]}/${DM__GLOBAL__CONFIG__CONFIG_FILE_NAME}"
  assert test -f "${lines[2]}/${DM__GLOBAL__CONFIG__CONFIG_FILE_NAME}"
}

@test "modules - module can be selected by index" {
  dm_lib__modules__list() {
    echo "one"
    echo "two"
    echo "three"
  }

  selected_index="2"
  expected="two"

  run dm_lib__modules__module_by_index "$selected_index"

  assert test $status -eq 0
  assert_output "$expected"
}

@test "modules - index is over the range" {
  dm_lib__modules__list() {
    echo "one"
    echo "two"
    echo "three"
  }

  selected_index="4"

  run dm_lib__modules__module_by_index "$selected_index"

  assert test $status -eq 1
}

@test "modules - index is below the range" {
  dm_lib__modules__list() {
    echo "one"
    echo "two"
    echo "three"
  }

  selected_index="0"

  run dm_lib__modules__module_by_index "$selected_index"

  assert test $status -eq 1
}

@test "modules - index is not a number" {
  dm_lib__modules__list() {
    echo "one"
    echo "two"
    echo "three"
  }

  selected_index="not an index"

  run dm_lib__modules__module_by_index "$selected_index"

  assert test $status -eq 1
}
