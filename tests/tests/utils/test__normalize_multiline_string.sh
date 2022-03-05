#!/bin/sh

export DM__GLOBAL__RUNTIME__REPO_ROOT="../../.."
# shellcheck source=../../../src/load_sources.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/load_sources.sh"

setup_file() {
  dm__debug__init
}

test__repeated_spaces_will_be_squeezed() {
  input_string='a b  c     d'

  dummy_function() {
    dm_tools__echo "$input_string" | dm__utils__normalize_multiline_string
  }
  run dummy_function

  assert_status 0
  assert_output 'a b c d'
  assert_no_error
}

test__leading_and_trailing_whitespace_will_be_removed() {
  input_string='    a b c     '
  expected='a b c'
  result="$( \
    dm_tools__echo "$input_string" | dm__utils__normalize_multiline_string \
  )"
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

  dummy_function() {
    dm_tools__echo "$input_string" | dm__utils__normalize_multiline_string
  }
  run dummy_function

  assert_status 0
  assert_output 'This is a multiline text'
  assert_no_error
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
    ' | dm__utils__normalize_multiline_string \
  )"
  expected='This is a multiline text'
  assert_equal "$expected" "$result"
}