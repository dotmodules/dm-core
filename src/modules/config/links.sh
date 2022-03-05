#!/bin/sh

#==============================================================================
# Parses the module registered links from the config file.
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
#   One link definition per line.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm_lib__config__get_links() {
  module_path="$1"

  prefix="LINK"

  dm__debug "dm_lib__config__get_links" \
    "parsing links for prefix '${prefix}' from module '${module_path}'.."

  links="$( \
    _dm_lib__config__get_prefixed_lines_from_config_file "$module_path" "$prefix" | \
      _dm_lib__config__parse_as_list | \
      _dm_lib__utils__trim_list "1-2"
  )"

  dm__debug_list "dm_lib__config__get_links" \
    "links parsed:" "$links"

  echo "$links"
}

