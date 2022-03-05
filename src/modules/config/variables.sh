#!/bin/sh

#==============================================================================
# Parses the module variables from the config file.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] config_path - Relative path to the configuration file.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   One variable definition per line.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm_lib__config__get_variables() {
  module_path="$1"

  prefix="REGISTER"

  dm__debug "dm_lib__config__get_variables" \
    "parsing variables for prefix '${prefix}' from module '${module_path}'.."

  variables="$( \
    _dm_lib__config__get_prefixed_lines_from_config_file "$module_path" "$prefix" | \
      _dm_lib__config__parse_as_list \
  )"

  dm__debug_list "dm_lib__config__get_variables" \
    "variables parsed:" "$variables"

  echo "$variables"
}