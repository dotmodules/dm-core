#!/bin/sh

#==============================================================================
# Helper function that indents every line sent to its standard input with a
# predefined amount.
#------------------------------------------------------------------------------
# Globals:
#   DM__CONFIG__CLI__INDENT
# Arguments:
#   None
# STDIN:
#   Lines that needs to be indented.
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Indented lines.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm__cli__display__indent() {
  # Indents the given message to a common level.
  dm_tools__cat - | \
    dm_tools__sed --expression "s/^/${DM__CONFIG__CLI__INDENT}/"
}

#==============================================================================
# Display function that takes a multiline text and a header name alongside with
# formatting information and prints out the header followed by the multiline
# text. It also respects the global wrapping limit, and breaks up the
# overhanging lines by formatting the lines not to hang bafore the header. This
# function can be used to display dynamic summary pages in a clear, formatted
# way. The header will be printed only in the first line.
#
# Example:
#
#  |<-{global_wrapping_limit}---------------------------------------->|
#  |<-{header_padding}---->|                                          |
#  |                 Header Lorem ipsum dolor sit amet, consectetur   |
#  |                        adipiscing elit, sed do eiusmod tempor    |
#  |                        incididunt ut labore et dolore magna      |
#  |                        aliqua.                                   |
#
# A common format for this function:
#   "%${header_padding}s %s\n"
#            |            |
#            |            `-- Second placeholder of the text.
#            `--------------- First padded placeholder for the header.
#
# Internally it uses two named pipes that gets removed right after the usage.
# On error these named pipes could be left on your disk, but after a clean run,
# they will be cleaned up.
#------------------------------------------------------------------------------
# Globals:
#   DM__CONFIG__CLI__TEXT_WRAP_LIMIT
# Arguments:
#   [1] header_padding - This parameter is used to calculate the wrapping point
#       for the multiline text. This size will be subtracted from the global
#        wrapping limit.
#   [2] format - Format for the whole line with position based placeholders for
#       the header and the data rows. This format will be directly passed to the
#       'printf' command so you need to respect its formatting rules.
#   [3] header - Header string that will be printed in the first line only.
#   [4] lines - Multiline data lines. This lines will be wrapped to the global
#       wrapping limit. Leading and trailing whitespace will be kept.
#   [5] highlight_color - Optional coloring escape sequence to be able to change
#       the coloring of the first word of every lines. This can be useful if you
#       want to print out named vales for a common key. The key gets empathized.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Formatted lines.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm__cli__display__header_multiline() {
  header_padding="$1"
  format="$2"
  header="$3"
  lines="$4"

  # Optional fifth coloring parameter for the leading words for every line.
  if [ "$#" = 5 ]
  then
    highlight_color="$5"
  else
    highlight_color=""
  fi

  # This function fill be mostly used to display text sections where the
  # section headers are usually a right aligned words with a fix width. This
  # width is passed to the function to be able to take into account for the
  # global width calculation. Without this the global text wrap limit will be
  # probably passed by this function. The additional -1 is accounted for the
  # fact that the folding would only happen on the text after the header and a
  # space.
  wrap_limit="$((DM__CONFIG__CLI__TEXT_WRAP_LIMIT - header_padding - 1))"

  # With named pipes we can feed the while loops to read the lines while being
  # able to access the outer context. The usual piped approach won't work as
  # the pipe operator creates a subshell. Beside this solution we could have
  # also used temporary files but this is a more elegant approach. Reaching the
  # outside context is necessary as the function relies on flags that stored
  # outside the loops.
  dm_tools__rm --force outer_temp_pipe
  dm_tools__mkfifo outer_temp_pipe
  dm_tools__echo "$lines" > outer_temp_pipe &

  header_line_passed="0"

  # The outer while loop is responsible for looping through the input lines
  # passed to the function. The internal while loop is responsible for wrapping
  # the given lines to a predefined maximum width. By doing this the internal
  # loop has to pay attention to the header printout as it needs to be printed
  # only once.

  # The outer named pipe will be fed to the loop at the end.
  while IFS= read -r line
  do
    dm_tools__rm --force inner_temp_pipe
    dm_tools__mkfifo inner_temp_pipe
    # Folding the given line and removing the trailing whitespaces.
    dm_tools__echo "$line" | \
      dm_tools__fold --spaces --width "$wrap_limit"  | \
      dm_tools__sed  --expression 's/\s*$//' > inner_temp_pipe &

    first_wrapped_line_has_passed="0"
    # Inner named pipe will be fed to the loop at the end.
    while IFS= read -r wrapped_line
    do
      # Highlighting the first word of the first wrapped line. If there is a 5th
      # formatting parameter given, it will be used here. We assume that there
      # is only one space between the first and second word.
      if [ -n "$highlight_color" ] && [ "$first_wrapped_line_has_passed" = "0" ]
      then
        # We need to separate the case when the wrapped line contains only one
        # word, otherwise that word would be printed twice, as the first item
        # and the latter items would be the same.
        word_count="$(dm_tools__echo "$wrapped_line" | dm_tools__wc --words)"

        if [ "$word_count" -eq "1" ]
        then
          wrapped_line="${highlight_color}${wrapped_line}${RESET}"
          first_wrapped_line_has_passed="1"
        else
          first="${wrapped_line%% *}"  # getting the first element from the list
          rest="${wrapped_line#* }"  # getting all items but the first
          wrapped_line="${highlight_color}${first}${RESET} ${rest}"
          first_wrapped_line_has_passed="1"
        fi
      fi

      # The header should be printed only in the first line being it wrapped or
      # not. Setting the 'header_line_passed' outer variable here in the wrapped
      # line level will ensure that the header will be printed once. This is the
      # exact reason of the complicated looping setup to be able to reach the
      # outer scope from the inner loop.
      if [ "$header_line_passed" = "0" ]
      then
        target_header="$header"
        header_line_passed="1"
      else
        target_header=""
      fi

      # Te point here is to be able to receive dynamic formats so we need to
      # allow the dynamic templated format here.
      # shellcheck disable=SC2059
      dm_tools__printf "$format" "$target_header" "$wrapped_line"

    done < inner_temp_pipe
    dm_tools__rm --force inner_temp_pipe

  done < outer_temp_pipe
  dm_tools__rm --force outer_temp_pipe
}

#==============================================================================
# Print the passed string as a header.
#------------------------------------------------------------------------------
# Globals:
#   DM__CONFIG__CLI__INDENT
#   BOLD
#   RESET
# Arguments:
#   [1] text - Text to be pronted as a header.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Formatted text
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm__cli__display__header() {
  header="$1"
  dm_tools__echo "${DM__CONFIG__CLI__INDENT}${BOLD}${header}${RESET}"
  dm_tools__echo ''
}