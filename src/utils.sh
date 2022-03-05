#!/bin/sh

#==============================================================================
# Function that squeezes every whitespace in the given lines.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   None
# STDIN:
#   Lines to be normalized.
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Normalized lines.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm__utils__normalize_whitespace() {
  dm_tools__cat - | dm_tools__tr --squeeze-repeats '[:space:]'
}

#==============================================================================
# Function that removes the surrounding whitespace from the given lines.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   None
# STDIN:
#   Lines to be normalized.
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Normalized lines.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm__utils__remove_surrounding_whitespace() {
  dm_tools__cat - | \
    dm_tools__sed --expression 's/^\s*//' | \
    dm_tools__sed --expression 's/\s*$//'
}

#==============================================================================
# Function that performs a list trimmig based on the given position string in
# every given line..
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] items - Position string that has to be compatible with the 'cut'
#       command's '--fields' argument values.
# STDIN:
#   Lines that needs to be trimmed.
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Trimmed lines.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm__utils__trim_list() {
  items="$1"
  cat - | \
    dm__utils__parse_list | \
    cut --delimiter=' ' --fields="${items}"
}

#==============================================================================
# Function that selects an indexed line from the given lines.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] line_index - One based index that should index the line that should be
#       returned.
# STDIN:
#   Lines that from which the indexed line should be selected
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Selected line.
# STDERR:
#   None
# Status:
#   0 - Index is valid, line returned.
#   1 - Invalid index.
#==============================================================================
dm__utils__select_line() {
  line_index="$1"
  dm_tools__cat - | dm_tools__sed --expression "${line_index}q;d"
}

#==============================================================================
# Function that will parse the given lines as a list by removing all
# unecessary whitespace.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   None
# STDIN:
#   Lines that needs to be parsed.
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Parsed lines.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm__utils__parse_list() {
  cat - | \
    dm__utils__normalize_whitespace | \
    dm__utils__remove_surrounding_whitespace
}

#==============================================================================
# Returns the selected line from a multiline text, after the index got
# validated.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] index - Line index started from 1.
#   [2] lines - Multiline text the indexed line should be selected from.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Selected lines.
# STDERR:
#   None
# Status:
#   0 - Index is valid, line returned.
#   1 - Invalid index.
#==============================================================================
dm__utils__line_by_index() {
  selected_index="$1"
  lines="$2"

  dm__debug_list 'dm__utils__line_by_index' \
    "getting line for index '${selected_index}' from lines:" "$lines"

  line_count="$(dm_tools__echo "$lines" | dm_tools__wc --lines)"
  dm__debug 'dm__utils__line_by_index' "line count: ${line_count}"

  case "$selected_index" in
      ''|*[!0-9]*)
        dm__debug 'dm__utils__line_by_index' \
          "given index '${selected_index}' is not a positive number, aborting.."
        return 1
        ;;
      *) ;;
  esac

  if [ "$selected_index" -le "0" ] || [ "$selected_index" -gt "$line_count" ]
  then
    dm__debug 'dm__utils__line_by_index' 'index is out of range, aborting..'
    return 1
  else
    dm__debug 'dm__utils__line_by_index' "index '${selected_index}' is valid"
  fi
  line="$(echo "$lines" | dm__utils__select_line "$selected_index")"

  dm__debug 'dm__utils__line_by_index' "returning line: '${line}'"

  dm_tools__echo "$line"
}

#==============================================================================
# Normalizes the piped string by replacing the newline characters with spaces
# and removes the repeated whitespace characters. This could be useful if a
# longer text needs to be stored in a single variable. At the variable
# definition the text could be broken into multiple lines to have a more cleaner
# source file. This function will normalize the long text as if it was defined
# in a continous line.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   None
# STDIN:
#   Text to be normalized.
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Normalized text as a single line.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm__utils__normalize_multiline_string() {
  dm_tools__cat - | \
    dm_tools__tr --replace '\n' ' ' | \
    dm_tools__tr --squeeze-repeats '[:space:]' | \
    dm_tools__sed --expression 's/^\s*//g;s/\s*$//g' | dm_tools__cat
}

#==============================================================================
# Function that removes empty lines that contains only whitespace from the input
# lines.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   None
# STDIN:
#   Lines to be normalized.
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Normalized lines.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm__utils__remove_empty_lines() {
  dm_tools__cat - | dm_tools__sed --expression '/^[[:space:]]*$/d'
}