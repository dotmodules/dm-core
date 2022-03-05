#!/bin/sh

#==============================================================================
# Parses the module name from the config file.
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
#   Name of the module as single line.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm_lib__config__get_name() {
  module_path="$1"

  prefix="NAME"

  dm__debug "dm_lib__config__get_name" \
    "parsing name for prefix '${prefix}' from module '${module_path}'.."

  name="$( \
    _dm_lib__config__get_prefixed_lines_from_config_file "$module_path" "$prefix" | \
      _dm_lib__config__parse_as_line | \
      _dm_lib__utils__select_line "1" \
  )"

  dm__debug "dm_lib__config__get_name" \
    "name parsed: '${name}'"

  echo "$name"
}