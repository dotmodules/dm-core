#!/bin/sh

export DM__GLOBAL__RUNTIME__REPO_ROOT="../../../.."
# shellcheck source=../../../../src/load_sources.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/load_sources.sh"

setup_file() {
  dm__debug__init
}

test__header__smaller_padding_than_header__nothing_should_happed() {
  # The global warp limit shouldn't affect this test.
  export DM__CONFIG__CLI__TEXT_WRAP_LIMIT='1000'

  # The header is longer than the header padding length, so no padding and no
  # trimming should happen. The header should appear as is.
  header='header'
  header_padding='1'
  format="%${header_padding}s %s\n"
  lines='value_1 value_2 value_3'

  run dm__cli__display__header_multiline \
      "$header_padding" \
      "$format" \
      "$header" \
      "$lines"

  assert_status 0
  assert_output 'header value_1 value_2 value_3'
  assert_no_error
}

test__header__same_padding_size__nothing_should_happen() {
  # The global warp limit shouldn't affect this test.
  export DM__CONFIG__CLI__TEXT_WRAP_LIMIT='1000'

  # The header is the same size as the header padding length, so no padding and
  # no trimming should happen. The header should appear as is.
  header='header'
  header_padding='6'
  format="%${header_padding}s %s\n"
  lines='value_1 value_2 value_3'

  run dm__cli__display__header_multiline \
      "$header_padding" \
      "$format" \
      "$header" \
      "$lines"

  assert_status 0
  assert_output 'header value_1 value_2 value_3'
  assert_no_error
}

test__header__bigger_padding_size__header_should_be_padded() {
  # The global warp limit shouldn't affect this test.
  export DM__CONFIG__CLI__TEXT_WRAP_LIMIT='1000'

  # The header is shorter than the header padding length, so the header should
  # be left padded by the difference.
  header='header'
  header_padding='7'
  format="%${header_padding}s %s\n"
  lines='value_1 value_2 value_3'

  run dm__cli__display__header_multiline \
      "$header_padding" \
      "$format" \
      "$header" \
      "$lines"

  assert_status 0
  assert_output ' header value_1 value_2 value_3'
  #              ^--- extra padding
  assert_no_error
}

test__wrapping__global_wrapping_is_the_same_size() {
  # The global warp limit is the same as the line lenght: no wrapping should
  # happen. The line is 32 characters long.
  export DM__CONFIG__CLI__TEXT_WRAP_LIMIT='32'

  header='header'
  header_padding='8'
  format="%${header_padding}s %s\n"
  lines='value_1 value_2 value_3'

  run dm__cli__display__header_multiline \
      "$header_padding" \
      "$format" \
      "$header" \
      "$lines"

  assert_status 0
  #             |<-------{32 characters}-------->|
  assert_output '  header value_1 value_2 value_3'
  assert_no_error
}

test__wrapping__global_wrapping_is_smaller() {
  # The global warp limit is smaller than the line size = wrapping should
  # happen! The line is 32 characters long.
  export DM__CONFIG__CLI__TEXT_WRAP_LIMIT='31'

  header='header'
  header_padding='8'
  format="%${header_padding}s %s\n"
  lines='value_1 value_2 value_3'

  run dm__cli__display__header_multiline \
      "$header_padding" \
      "$format" \
      "$header" \
      "$lines"

  assert_status 0
  # |<-------{31 characters}------->| Last word should be wrapped.
  # '  header value_1 value_2 value_3'
  assert_output_line_at_index 1 '  header value_1 value_2'
  assert_output_line_at_index 2 '         value_3'
  assert_no_error
}

test__wrapping__global_wrapping_limit_is_before_a_whitespace() {
  # The global warp limit is smaller than the line size = wrapping should
  # happen! The line is 32 characters long.
  export DM__CONFIG__CLI__TEXT_WRAP_LIMIT='24'

  header='header'
  header_padding='8'
  format="%${header_padding}s %s\n"
  lines='value_1 value_2 value_3'

  run dm__cli__display__header_multiline \
      "$header_padding" \
      "$format" \
      "$header" \
      "$lines"

  assert_status 0
  # |<---{24 characters}---->| The word before the whitespace should be wrapped too.
  # '  header value_1 value_2 value_3'
  # This comes from the behavior of the 'fold' command..
  assert_output_line_at_index 1 '  header value_1'
  assert_output_line_at_index 2 '         value_2 value_3'
  assert_no_error
}

test__wrapping__global_wrapping_limit_is_at_a_whitespace() {
  # The global warp limit is smaller than the line size = wrapping should
  # happen! The line is 32 characters long.
  export DM__CONFIG__CLI__TEXT_WRAP_LIMIT='25'

  header='header'
  header_padding='8'
  format="%${header_padding}s %s\n"
  lines='value_1 value_2 value_3'

  run dm__cli__display__header_multiline \
      "$header_padding" \
      "$format" \
      "$header" \
      "$lines"

  assert_status 0
  # |<---{25 characters}----->| Only the last word should be wrapped.
  # '  header value_1 value_2 value_3'
  assert_output_line_at_index 1 '  header value_1 value_2'
  assert_output_line_at_index 2 '         value_3'
  assert_no_error
}

test__wrapping__multiple_wrappings_can_happen() {
  # The global warp limit is smaller than the line size = wrapping should
  # happen! The line is 32 characters long.
  export DM__CONFIG__CLI__TEXT_WRAP_LIMIT='20'

  header='header'
  header_padding='8'
  format="%${header_padding}s %s\n"
  lines='value_1 value_2 value_3'

  run dm__cli__display__header_multiline \
      "$header_padding" \
      "$format" \
      "$header" \
      "$lines"

  assert_status 0
  # |<--{20 characters}->| Every word should be wrapped.
  # '  header value_1 value_2 value_3'
  assert_output_line_at_index 1 '  header value_1'
  assert_output_line_at_index 2 '         value_2'
  assert_output_line_at_index 3 '         value_3'
  assert_no_error
}

test__wrapping__global_wrapping_limit_is_smaller_than_the_first_word() {
  # If the global wrapping limit is smaller than the first word after the
  # heading, the word will be splitted up.
  export DM__CONFIG__CLI__TEXT_WRAP_LIMIT='12'

  header='header'
  header_padding='8'
  format="%${header_padding}s %s\n"
  lines='value_1 value_2 value_3'

  run dm__cli__display__header_multiline \
      "$header_padding" \
      "$format" \
      "$header" \
      "$lines"

  assert_status 0
  # The wrapped line should start after the header's column.
  assert_output_line_at_index 1 '  header val'
  assert_output_line_at_index 2 '         ue_'
  assert_output_line_at_index 3 '         1'
  assert_output_line_at_index 4 '         val'
  assert_output_line_at_index 5 '         ue_'
  assert_output_line_at_index 6 '         2'
  assert_output_line_at_index 7 '         val'
  assert_output_line_at_index 8 '         ue_'
  assert_output_line_at_index 9 '         3'
  assert_no_error
}

test__wrapping__whitespace_should_be_wrapped_too() {
  export DM__CONFIG__CLI__TEXT_WRAP_LIMIT='31'

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

  run dm__cli__display__header_multiline \
      "$header_padding" \
      "$format" \
      "$header" \
      "$lines"

  assert_status 0
  assert_output_line_at_index 1 '  header value_1'
  assert_output_line_at_index 2 '             value_2'
  assert_output_line_at_index 3 '                value_3'
  assert_no_error
}

test__wrapping__multiline_input_handling() {
  export DM__CONFIG__CLI__TEXT_WRAP_LIMIT='31'

  header='header'
  header_padding='8'
  format="%${header_padding}s %s\n"
  lines="$( \
    dm_tools__echo 'This is line 1.'; \
    dm_tools__echo 'With multiple words that should be wrapped!'; \
    dm_tools__echo 'This a short line 2.'; \
    dm_tools__echo 'Line 3 has some internal    whitespace   !'; \
  )"

  run dm__cli__display__header_multiline \
      "$header_padding" \
      "$format" \
      "$header" \
      "$lines"

  assert_status 0
  # Multiline output should be processable. In this case, multiple lines won't
  # be merged but wrapped line by line, whitespace on wrapping limits will be
  # replaced with a wrapping point, and whitespaces that are not at a wrapping
  # point should be kept.
  assert_output_line_at_index 1 '  header This is line 1.'
  assert_output_line_at_index 2 '         With multiple words'
  assert_output_line_at_index 3 '         that should be'
  assert_output_line_at_index 4 '         wrapped!'
  assert_output_line_at_index 5 '         This a short line 2.'
  assert_output_line_at_index 6 '         Line 3 has some'
  assert_output_line_at_index 7 '         internal'
  assert_output_line_at_index 8 '         whitespace   !'
  assert_no_error
}

test__wrapping__multiline_input_handling_with_indentation() {
  export DM__CONFIG__CLI__TEXT_WRAP_LIMIT='31'

  header='header'
  header_padding='8'
  format="%${header_padding}s %s\n"
  lines="$( \
    dm_tools__echo 'This line is not indented.'; \
    dm_tools__echo '  But this one is indented by two spaces!'; \
    dm_tools__echo '  This line too!'; \
  )"

  run dm__cli__display__header_multiline \
      "$header_padding" \
      "$format" \
      "$header" \
      "$lines"

  assert_status 0
  # Multiline output should be processable. In this case, multiple lines won't
  # be merged but wrapped line by line, whitespace on wrapping limits will be
  # replaced with a wrapping point, and whitespaces that are not at a wrapping
  # point should be kept.
  assert_output_line_at_index 1 '  header This line is not'
  assert_output_line_at_index 2 '         indented.'
  assert_output_line_at_index 3 '           But this one is'
  assert_output_line_at_index 4 '         indented by two'
  assert_output_line_at_index 5 '         spaces!'
  assert_output_line_at_index 6 '           This line too!'
  assert_no_error
}