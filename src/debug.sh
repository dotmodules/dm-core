#!/bin/sh

#==============================================================================
# DEBUGGING FUNCTIONALITY
#==============================================================================

#==============================================================================
# Prints out the given message to standard error if debug mode is enabled.
#==============================================================================
dm__debug() {
  if command >&3
  then
    domain="$1"
    message="$2"
    >&3 printf "${DIM}$(date +"%F %T.%N") | %48s | %s\n${RESET}" "$domain" "$message"
  fi 2>/dev/null
  # Redirecting standard error to supress the error message if the file
  # descriptor is not available.
}

#==============================================================================
# Prints out a given newline separated list to the debug output in a
# formatted line-by-line way if debug mode is enabled.
#==============================================================================
dm__debug_list() {
  if command >&3
  then
    domain="$1"
    message="$2"
    list="$3"

    dm__debug "$domain" "$message"

    echo "$list" | while read -r item
    do
      dm__debug "$domain" "- '${item}'"
    done
  fi 2>/dev/null
  # Redirecting standard error to supress the error message if the file
  # descriptor is not available.
}
