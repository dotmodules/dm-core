#!/bin/sh

#==============================================================================
# Parses the module version from the config file.
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
#   Version of the module as single line.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm_lib__config__get_version() {
  module_path="$1"

  prefix="VERSION"

  dm__debug "dm_lib__config__get_version" \
    "parsing version for prefix '${prefix}' from module '${module_path}'.."

  version="$( \
    _dm_lib__config__get_prefixed_lines_from_config_file "$module_path" "$prefix" | \
      _dm_lib__config__parse_as_list | \
      _dm_lib__utils__trim_list "1" | \
      _dm_lib__utils__select_line "1" \
  )"

  dm__debug "dm_lib__config__get_version" \
    "version parsed: '${version}'"

  echo "$version"
}