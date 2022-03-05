#!/bin/sh

#==============================================================================
# DEBUGGING FUNCTIONALITY
#==============================================================================

# Global variable that holds the debug state. It should be initialized. Other
# values than '1' would make the debugging system disabled.
DM__DEBUG__RUNTIME__DEBUG_ENABLED='___INVALID___'

#==============================================================================
# Initializes the debug system. Debugging will be enabled if the current process
# has file descriptor 3 attached to it.
#------------------------------------------------------------------------------
# Globals:
#   DM__DEBUG__RUNTIME__DEBUG_ENABLED
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM__DEBUG__RUNTIME__DEBUG_ENABLED
# STDOUT:
#   None
# STDERR:
#   None
# FD3:
#   Debug message.
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm__debug__init() {
  if command >&3
  then
    DM__DEBUG__RUNTIME__DEBUG_ENABLED='1'
    dm__debug 'dm__debug__init' 'debugging has been enabled'
  # Redirecting standard error to supress the error message if the file
  # descriptor is not available.
  fi 2>/dev/null
}

#==============================================================================
# Prints out the given message to standard error if debug mode is enabled.
#------------------------------------------------------------------------------
# Globals:
#   DM__DEBUG__RUNTIME__DEBUG_ENABLED
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# FD3:
#   Debug message.
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm__debug() {
  if [ "$DM__DEBUG__RUNTIME__DEBUG_ENABLED" = '1' ]
  then
    domain="$1"
    message="$2"
    >&3 printf "${DIM}$(date +"%F %T.%N") | %48s | %s\n${RESET}" "$domain" "$message"
  fi
}

#==============================================================================
# Prints out a given newline separated list to the debug output in a formatted
# line-by-line way if debug mode is enabled.
#------------------------------------------------------------------------------
# Globals:
#   DM__DEBUG__RUNTIME__DEBUG_ENABLED
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# FD3:
#   Debug message.
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm__debug_list() {
  if [ "$DM__DEBUG__RUNTIME__DEBUG_ENABLED" = '1' ]
  then
    domain="$1"
    message="$2"
    list="$3"

    dm__debug "$domain" "$message"

    echo "$list" | while read -r item
    do
      dm__debug "$domain" "- '${item}'"
    done
  fi
}
