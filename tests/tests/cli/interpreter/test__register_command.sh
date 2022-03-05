#!/bin/sh

export DM__GLOBAL__RUNTIME__REPO_ROOT="../../../.."
# shellcheck source=../../../../src/load_sources.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/load_sources.sh"

setup_file() {
  dm__debug__init
}

test__default_command_can_be_registered_and_returned() {
  run dm__cli__commands__register_default 'default_function'
  assert_no_error
  assert_no_output
  assert_status 0

  run dm__cli__commands__query 'non_existent_hotkey'
  assert_no_error
  assert_output 'default_function'
  assert_status 0
}

test__registered_command_can_be_selected() {
  run dm__cli__commands__register \
      'hotkey_1' \
      'function_name_1' \
      'docs_1'
  assert_no_error
  assert_no_output
  assert_status 0

  run dm__cli__commands__query 'hotkey_1'
  assert_no_error
  assert_output 'function_name_1'
  assert_status 0
}

test__multiple_commands_can_be_registered() {
  run dm__cli__commands__register \
      'hotkey_1' \
      'function_name_1' \
      'docs_1'
  assert_no_error
  assert_no_output
  assert_status 0

  run dm__cli__commands__register \
      'hotkey_2' \
      'function_name_2' \
      'docs_2'
  assert_no_error
  assert_no_output
  assert_status 0

  run dm__cli__commands__query 'hotkey_1'
  assert_no_error
  assert_output 'function_name_1'
  assert_status 0

  run dm__cli__commands__query 'hotkey_2'
  assert_no_error
  assert_output 'function_name_2'
  assert_status 0
}

test__default_command_gets_returned_on_no_match() {
  run dm__cli__commands__register_default 'default_function'
  assert_no_error
  assert_no_output
  assert_status 0

  run dm__cli__commands__register \
      'hotkey_1' \
      'function_name_1' \
      'docs_1'
  assert_no_error
  assert_no_output
  assert_status 0

  run dm__cli__commands__query 'non_existent_hotkey'
  assert_no_error
  assert_output 'default_function'
  assert_status 0
}

test__multiple_hotkeys_can_be_used_for_a_command() {
  run dm__cli__commands__register_default 'default_function'
  assert_no_error
  assert_no_output
  assert_status 0

  run dm__cli__commands__register \
      'hotkey_1|h|hot' \
      'function_name_1' \
      'docs_1'
  assert_no_error
  assert_no_output
  assert_status 0

  run dm__cli__commands__query 'hotkey_1'
  assert_no_error
  assert_output 'function_name_1'
  assert_status 0

  run dm__cli__commands__query 'h'
  assert_no_error
  assert_output 'function_name_1'
  assert_status 0

  run dm__cli__commands__query 'hot'
  assert_no_error
  assert_output 'function_name_1'
  assert_status 0

  # Partial matches should not find the function.
  run dm__cli__commands__query 'ho'
  assert_no_error
  assert_output 'default_function'
  assert_status 0
}