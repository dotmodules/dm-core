load $DM_LIB_MUT
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

  test $status -eq 0
  test ${#lines[@]} -eq 3

  test -z "${lines[0]##*module1*}"
  test -z "${lines[1]##*module2*}"
  test -z "${lines[2]##*nested/module3*}"

  test -f "${lines[0]}/${DM__GLOBAL__CONFIG__CONFIG_FILE_NAME}"
  test -f "${lines[1]}/${DM__GLOBAL__CONFIG__CONFIG_FILE_NAME}"
  test -f "${lines[2]}/${DM__GLOBAL__CONFIG__CONFIG_FILE_NAME}"
}
