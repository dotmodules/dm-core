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
# MODULES
#==============================================================================

#==============================================================================
# Returns the relative path list for all recognized module config files found in
# the given modules root directory. A module is recognized if it contains a dm
# configuration file.
#------------------------------------------------------------------------------
# Globals:
#   DM__CONFIG__RELATIVE_MODULES_PATH
#   DM__CONFIG__CONFIG_FILE_NAME
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Newline separated sorted list of relative paths to the module config files.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_dm__modules__discover() {
  dm__debug '_dm__modules__discover' \
    "loading modules from '${DM__CONFIG__RELATIVE_MODULES_PATH}'"

  dm_tools__find "$DM__CONFIG__RELATIVE_MODULES_PATH" \
      --type 'f' \
      --name "$DM__CONFIG__CONFIG_FILE_NAME" | \
    dm_tools__sort --dictionary-order
    # dm_tools__xargs --replace {} dirname "{}"
}