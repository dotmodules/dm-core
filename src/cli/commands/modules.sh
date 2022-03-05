#!/bin/sh
#==============================================================================
#   __  __           _       _
#  |  \/  |         | |     | |
#  | \  / | ___   __| |_   _| | ___  ___
#  | |\/| |/ _ \ / _` | | | | |/ _ \/ __|
#  | |  | | (_) | (_| | |_| | |  __/\__ \
#  |_|  |_|\___/ \__,_|\__,_|_|\___||___/
#
#==============================================================================
# COMMAND: MODULES
#==============================================================================

export DM__CLI__COMMANDS__MODULES__NAME='dm__cli__commands__modules'
export DM__CLI__COMMANDS__MODULES__DOCS='Lists all detected modules by default. In the list there is an assigned index for each module that can be used as a parameter to show the given module details.'

#==============================================================================
# Top level interpreter function for the command modules.
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
dm__cli__commands__modules() {
  dm_tools__echo ''
  dm__cli__display__header 'MODULES'
  _dm__modules__discover
}
