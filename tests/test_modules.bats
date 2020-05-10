load $DM_LIB_MUT
load $BATS_MOCK
load $BATS_ASSERT
load $BATS_SUPPORT
load test_helper


setup() {
  # Simulating the relative path here ot the modules root directory.
  export DM__GLOBAL__RUNTIME__MODULES_ROOT=$(\
    realpath --relative-to="$(pwd)" "${DM__TEST__TEST_DIR}/modules"\
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
