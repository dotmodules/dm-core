#!/bin/sh

DM__GLOBAL__RUNTIME__DM_REPO_ROOT="../../../.."
# shellcheck source=../../../../src/cli/utils.sh
. "${DM__GLOBAL__RUNTIME__DM_REPO_ROOT}/src/cli/utils.sh"


test__repeated_spaces_will_be_squeezed() {
  input_string='a b  c     d'
  expected='a b c d'
  result="$(dm_tools__echo "$input_string" | _dm_cli__utils__normalize_multiline_string)"
  assert_equal "$expected" "$result"
}

test__leading_and_trailing_whitespace_will_be_removed() {
  input_string='    a b c     '
  expected='a b c'
  result="$(dm_tools__echo "$input_string" | _dm_cli__utils__normalize_multiline_string)"
  assert_equal "$expected" "$result"
}

test__line_breaks_will_be_converted_to_spaces() {
  input_string="$( \
    dm_tools__echo '
    This
    is a
    multiline
    text
    ' \
  )"
  expected='This is a multiline text'
  result="$(dm_tools__echo "$input_string" | _dm_cli__utils__normalize_multiline_string)"
  assert_equal "$expected" "$result"
}

test__intended_use_case() {
  # This utility function is mainly intended to be used for generating longer
  # string constants that might require multiple lines to define. This function
  # would transform those multiline string definitions into a single line
  # definition.
  result="$( \
    dm_tools__echo '
       This
    is a
    multiline
    text
    ' | _dm_cli__utils__normalize_multiline_string \
  )"
  expected='This is a multiline text'
  assert_equal "$expected" "$result"
}