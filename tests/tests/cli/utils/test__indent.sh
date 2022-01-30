#!/bin/sh

DM__GLOBAL__RUNTIME__DM_REPO_ROOT="../../../.."
# shellcheck source=../../../../src/cli/utils.sh
. "${DM__GLOBAL__RUNTIME__DM_REPO_ROOT}/src/cli/utils.sh"


test__repeated_spaces_will_be_squeezed() {
  # Setting up the global variable for this test.
  DM__GLOBAL__CONFIG__CLI__INDENT='  '

  input_string='hello'
  expected='  hello'
  result="$(dm_tools__echo "$input_string" | _dm_cli__utils__indent)"
  assert_equal "$expected" "$result"
}
