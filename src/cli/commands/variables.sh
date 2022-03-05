#!/bin/sh
#==============================================================================
# __      __        _       _     _
# \ \    / /       (_)     | |   | |
#  \ \  / /_ _ _ __ _  __ _| |__ | | ___  ___
#   \ \/ / _` | '__| |/ _` | '_ \| |/ _ \/ __|
#    \  / (_| | |  | | (_| | |_) | |  __/\__ \
#     \/ \__,_|_|  |_|\__,_|_.__/|_|\___||___/
#==============================================================================
# COMMAND: VARIABLES
#==============================================================================

export DM__CLI__COMMANDS__VARIABLES__NAME='dm__cli__commands__variables'
export DM__CLI__COMMANDS__VARIABLES__DOCS='Prints out all collected variables.'

#==============================================================================
# Top level interpreter function for the command variables.
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
dm__cli__commands__variables() {
  dm_tools__echo ''
  dm__cli__display__header 'VARIABLES'
}
