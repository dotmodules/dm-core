#!/bin/sh
#==============================================================================
#   _    _             _
#  | |  | |           | |
#  | |__| | ___   ___ | | _____
#  |  __  |/ _ \ / _ \| |/ / __|
#  | |  | | (_) | (_) |   <\__ \
#  |_|  |_|\___/ \___/|_|\_\___/
#
#==============================================================================
# COMMAND: HOOKS
#==============================================================================

export DM__CLI__COMMANDS__HOOKS__NAME='dm__cli__commands__hooks'
export DM__CLI__COMMANDS__HOOKS__DOCS='Prints out all registered hooks sorted by priority.'

#==============================================================================
# Top level interpreter function for the command hooks.
#------------------------------------------------------------------------------
# Globals:
#   None
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
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm__cli__commands__hooks() {
  dm_tools__echo ''
  dm__cli__display__header 'HOOKS'
}