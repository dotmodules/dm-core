#==============================================================================
# SUBMODULE: UTILS
#==============================================================================
#   _    _ _   _ _
#  | |  | | | (_) |
#  | |  | | |_ _| |___
#  | |  | | __| | / __|
#  | |__| | |_| | \__ \
#   \____/ \__|_|_|___/
#
#==============================================================================

#==============================================================================
# Function that squeezes every whitespace in the given lines.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - None
# StdIn
# - Lines that needs to be parsed.
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Parsed lines.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__utils__normalize_whitespace() {
  cat - | tr --squeeze-repeats '[:space:]'
}

#==============================================================================
# Function that removes the surrounding whitespace from the given lines.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - None
# StdIn
# - Lines that needs to be parsed.
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Parsed lines.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__utils__remove_surrounding_whitespace() {
  cat - | \
    sed -E 's/^\s*//' | \
    sed -E 's/\s*$//'
}

#==============================================================================
# Function that performs a list trimmig based on the given position string in
# every given line..
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: Items - Position string that has to be compatible with the `cut`
#      command's `--fields` argument values.
# StdIn
# - Lines that needs to be trimmed.
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Trimmed lines.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__utils__trim_list() {
  items="$1"
  cat - |\
    _dm_lib__utils__normalize_whitespace | \
    cut --delimiter=' ' --fields="${items}"
}

#==============================================================================
# Function that selects an indexed line from the given lines.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: Line - Line index that should only be returned.
# StdIn
# - Lines that needs to be trimmed.
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - the selected line.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__utils__select_line() {
  line="$1"
  cat - | sed "${line}q;d"
}

#==============================================================================
# Function that will parse the given lines as a list by removing all
# unecessary whitespace.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - None
# StdIn
# - Lines that needs to be parsed.
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Parsed lines.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__utils__parse_list() {
  cat - | \
    _dm_lib__utils__normalize_whitespace | \
    _dm_lib__utils__remove_surrounding_whitespace
}

#==============================================================================
# Returns the selected line from a multiline text, after the index got
# validated.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1 - index - line index started from 1.
# - 2 - lines - multiline text the indexed line should be selected from.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Selected line.
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error and the returned number is the max number of the index
#==============================================================================
_dm_lib__utils__line_by_index() {
  selected_index="$1"
  lines="$2"

  dm_lib__debug_list "_dm_lib__utils__line_by_index" \
    "getting line for index '${selected_index}' from lines:" "$lines"

  line_count="$(echo "$lines" | wc -l)"
  dm_lib__debug \
    "_dm_lib__utils__line_by_index" \
    "line count: ${line_count}"

  case "$selected_index" in
      ''|*[!0-9]*)
        dm_lib__debug \
          "_dm_lib__utils__line_by_index" \
          "given index '${selected_index}' is not a number, aborting.."
        return 1
        ;;
      *) ;;
  esac

  if [ "$selected_index" -le "0" ] || [ "$selected_index" -gt "$line_count" ]
  then
    dm_lib__debug \
      "_dm_lib__utils__line_by_index" \
      "index is out of range, aborting.."
    return 1
  else
    dm_lib__debug \
      "_dm_lib__utils__line_by_index" \
      "index '${selected_index}' is valid"
  fi
  line="$( \
    echo "$lines" | \
      _dm_lib__utils__select_line "$selected_index" \
  )"

  dm_lib__debug \
    "_dm_lib__utils__line_by_index" \
    "returning line: '${line}'"

  echo "$line"
}
