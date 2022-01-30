#!/bin/sh

DM__GLOBAL__RUNTIME__DM_REPO_ROOT="../../../.."
# shellcheck source=../../../../src/cli/utils.sh
. "${DM__GLOBAL__RUNTIME__DM_REPO_ROOT}/src/cli/utils.sh"


test__header__smaller_padding_than_header__nothing_should_happed() {
  # The global warp limit shouldn't affect this test.
  DM__GLOBAL__CONFIG__CLI__TEXT_WRAP_LIMIT='1000'

  # The header is longer than the header padding length, so no padding and no
  # trimming should happen. The header should appear as is.
  header='header'
  header_padding='1'
  format="%${header_padding}s %s\n"
  lines='value_1 value_2 value_3'

  expected='header value_1 value_2 value_3'

  result="$( \
    _dm_cli__utils__header_multiline \
      "$header_padding" \
      "$format" \
      "$header" \
      "$lines" \
  )"
  assert_equal "$expected" "$result"
}

test__header__same_padding_size__nothing_should_happen() {
  # The global warp limit shouldn't affect this test.
  DM__GLOBAL__CONFIG__CLI__TEXT_WRAP_LIMIT='1000'

  # The header is the same size as the header padding length, so no padding and
  # no trimming should happen. The header should appear as is.
  header='header'
  header_padding='6'
  format="%${header_padding}s %s\n"
  lines='value_1 value_2 value_3'

  expected='header value_1 value_2 value_3'

  result="$( \
    _dm_cli__utils__header_multiline \
      "$header_padding" \
      "$format" \
      "$header" \
      "$lines" \
  )"
  assert_equal "$expected" "$result"
}

test__header__bigger_padding_size__header_should_be_padded() {
  # The global warp limit shouldn't affect this test.
  DM__GLOBAL__CONFIG__CLI__TEXT_WRAP_LIMIT='1000'

  # The header is shorter than the header padding length, so the header should
  # be left padded by the difference.
  header='header'
  header_padding='7'
  format="%${header_padding}s %s\n"
  lines='value_1 value_2 value_3'

  expected=' header value_1 value_2 value_3'
  #         ^--- extra padding

  result="$( \
    _dm_cli__utils__header_multiline \
      "$header_padding" \
      "$format" \
      "$header" \
      "$lines" \
  )"
  assert_equal "$expected" "$result"
}

test__wrapping__global_wrapping_is_the_same_size() {
  # The global warp limit is the same as the line lenght: no wrapping should
  # happen. The line is 32 characters long.
  DM__GLOBAL__CONFIG__CLI__TEXT_WRAP_LIMIT='32'

  header='header'
  header_padding='8'
  format="%${header_padding}s %s\n"
  lines='value_1 value_2 value_3'

  #        |<-------{32 characters}-------->|
  expected='  header value_1 value_2 value_3'

  result="$( \
    _dm_cli__utils__header_multiline \
      "$header_padding" \
      "$format" \
      "$header" \
      "$lines" \
  )"
  assert_equal "$expected" "$result"
}

test__wrapping__global_wrapping_is_smaller() {
  # The global warp limit is smaller than the line size = wrapping should
  # happen! The line is 32 characters long.
  DM__GLOBAL__CONFIG__CLI__TEXT_WRAP_LIMIT='31'

  header='header'
  header_padding='8'
  format="%${header_padding}s %s\n"
  lines='value_1 value_2 value_3'

  # |<-------{31 characters}------->| Last word should be wrapped.
  # '  header value_1 value_2 value_3'
  expected="$( \
    dm_tools__echo '  header value_1 value_2'; \
    dm_tools__echo '         value_3'; \
  )"

  result="$( \
    _dm_cli__utils__header_multiline \
      "$header_padding" \
      "$format" \
      "$header" \
      "$lines" \
  )"
  assert_equal "$expected" "$result"
}

test__wrapping__global_wrapping_limit_is_before_a_whitespace() {
  # The global warp limit is smaller than the line size = wrapping should
  # happen! The line is 32 characters long.
  DM__GLOBAL__CONFIG__CLI__TEXT_WRAP_LIMIT='24'

  header='header'
  header_padding='8'
  format="%${header_padding}s %s\n"
  lines='value_1 value_2 value_3'

  # |<---{24 characters}---->| The word before the whitespace should be wrapped too.
  # '  header value_1 value_2 value_3'
  # This comes from the behavior of the 'fold' command..
  expected="$( \
    dm_tools__echo '  header value_1'; \
    dm_tools__echo '         value_2 value_3'; \
  )"

  result="$( \
    _dm_cli__utils__header_multiline \
      "$header_padding" \
      "$format" \
      "$header" \
      "$lines" \
  )"
  assert_equal "$expected" "$result"
}

test__wrapping__global_wrapping_limit_is_at_a_whitespace() {
  # The global warp limit is smaller than the line size = wrapping should
  # happen! The line is 32 characters long.
  DM__GLOBAL__CONFIG__CLI__TEXT_WRAP_LIMIT='25'

  header='header'
  header_padding='8'
  format="%${header_padding}s %s\n"
  lines='value_1 value_2 value_3'

  # |<---{25 characters}----->| Only the last word should be wrapped.
  # '  header value_1 value_2 value_3'
  expected="$( \
    dm_tools__echo '  header value_1 value_2'; \
    dm_tools__echo '         value_3'; \
  )"

  result="$( \
    _dm_cli__utils__header_multiline \
      "$header_padding" \
      "$format" \
      "$header" \
      "$lines" \
  )"
  assert_equal "$expected" "$result"
}

test__wrapping__multiple_wrappings_can_happen() {
  # The global warp limit is smaller than the line size = wrapping should
  # happen! The line is 32 characters long.
  DM__GLOBAL__CONFIG__CLI__TEXT_WRAP_LIMIT='20'

  header='header'
  header_padding='8'
  format="%${header_padding}s %s\n"
  lines='value_1 value_2 value_3'

  # |<--{20 characters}->| Every word should be wrapped.
  # '  header value_1 value_2 value_3'
  expected="$( \
    dm_tools__echo '  header value_1'; \
    dm_tools__echo '         value_2'; \
    dm_tools__echo '         value_3'; \
  )"

  result="$( \
    _dm_cli__utils__header_multiline \
      "$header_padding" \
      "$format" \
      "$header" \
      "$lines" \
  )"
  assert_equal "$expected" "$result"
}

test__wrapping__global_wrapping_limit_is_smaller_than_the_first_word() {
  # If the global wrapping limit is smaller than the first word after the
  # heading, the word will be splitted up.
  DM__GLOBAL__CONFIG__CLI__TEXT_WRAP_LIMIT='12'

  header='header'
  header_padding='8'
  format="%${header_padding}s %s\n"
  lines='value_1 value_2 value_3'

  # The wrapped line should start after the header's column.
  expected="$( \
    dm_tools__echo '  header val'; \
    dm_tools__echo '         ue_'; \
    dm_tools__echo '         1'; \
    dm_tools__echo '         val'; \
    dm_tools__echo '         ue_'; \
    dm_tools__echo '         2'; \
    dm_tools__echo '         val'; \
    dm_tools__echo '         ue_'; \
    dm_tools__echo '         3'; \
  )"

  result="$( \
    _dm_cli__utils__header_multiline \
      "$header_padding" \
      "$format" \
      "$header" \
      "$lines" \
  )"
  assert_equal "$expected" "$result"
}

test__wrapping__whitespace_should_be_wrapped_too() {
  DM__GLOBAL__CONFIG__CLI__TEXT_WRAP_LIMIT='31'

  header='header'
  header_padding='8'
  format="%${header_padding}s %s\n"
  lines='value_1                   value_2                  value_3'
  #                           ^                         ^
  # Wrapping limits should be hit in these points. The header with the padding
  # and the next whitespace is 9 characters long. The whitespace should be used
  # for wrapping limit calculation in a way that leading whitespace is kept, but
  # the trailing whitespace is removed if present. In this way, indented lines
  # can be persisted.

  expected="$( \
    dm_tools__echo '  header value_1'; \
    dm_tools__echo '             value_2'; \
    dm_tools__echo '                value_3'; \
  )"

  result="$( \
    _dm_cli__utils__header_multiline \
      "$header_padding" \
      "$format" \
      "$header" \
      "$lines" \
  )"
  assert_equal "$expected" "$result"
}

test__wrapping__multiline_input_handling() {
  DM__GLOBAL__CONFIG__CLI__TEXT_WRAP_LIMIT='31'

  header='header'
  header_padding='8'
  format="%${header_padding}s %s\n"
  lines="$( \
    dm_tools__echo 'This is line 1.'; \
    dm_tools__echo 'With multiple words that should be wrapped!'; \
    dm_tools__echo 'This a short line 2.'; \
    dm_tools__echo 'Line 3 has some internal    whitespace   !'; \
  )"

  # Multiline output should be processable. In this case, multiple lines won't
  # be merged but wrapped line by line, whitespace on wrapping limits will be
  # replaced with a wrapping point, and whitespaces that are not at a wrapping
  # point should be kept.
  expected="$( \
    dm_tools__echo '  header This is line 1.'; \
    dm_tools__echo '         With multiple words'; \
    dm_tools__echo '         that should be'; \
    dm_tools__echo '         wrapped!'; \
    dm_tools__echo '         This a short line 2.'; \
    dm_tools__echo '         Line 3 has some'; \
    dm_tools__echo '         internal'; \
    dm_tools__echo '         whitespace   !'; \
  )"

  result="$( \
    _dm_cli__utils__header_multiline \
      "$header_padding" \
      "$format" \
      "$header" \
      "$lines" \
  )"
  assert_equal "$expected" "$result"
}

test__wrapping__multiline_input_handling_with_indentation() {
  DM__GLOBAL__CONFIG__CLI__TEXT_WRAP_LIMIT='31'

  header='header'
  header_padding='8'
  format="%${header_padding}s %s\n"
  lines="$( \
    dm_tools__echo 'This line is not indented.'; \
    dm_tools__echo '  But this one is indented by two spaces!'; \
    dm_tools__echo '  This line too!'; \
  )"

  # Multiline output should be processable. In this case, multiple lines won't
  # be merged but wrapped line by line, whitespace on wrapping limits will be
  # replaced with a wrapping point, and whitespaces that are not at a wrapping
  # point should be kept.
  expected="$( \
    dm_tools__echo '  header This line is not'; \
    dm_tools__echo '         indented.'; \
    dm_tools__echo '           But this one is'; \
    dm_tools__echo '         indented by two'; \
    dm_tools__echo '         spaces!'; \
    dm_tools__echo '           This line too!'; \
  )"

  result="$( \
    _dm_cli__utils__header_multiline \
      "$header_padding" \
      "$format" \
      "$header" \
      "$lines" \
  )"
  assert_equal "$expected" "$result"
}