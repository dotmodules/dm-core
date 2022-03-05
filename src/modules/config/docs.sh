#!/bin/sh

#==============================================================================
# Parses the module documentation from the config file.
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
#   Documentation of the module as single line.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm_lib__config__get_docs() {
  module_path="$1"

  prefix="DOC"

  dm__debug "dm_lib__config__get_docs" \
    "parsing documentation for prefix '${prefix}' from module '${module_path}'.."

  docs="$( \
    _dm_lib__config__get_prefixed_lines_from_config_file "$module_path" "$prefix" | \
      _dm_lib__config__parse_as_line | \
      _dm_lib__config__remove_leading_pipe
  )"

  dm__debug_list "dm_lib__config__get_docs" \
    "documentation parsed:" "$docs"

  echo "$docs"
}

#==============================================================================
# Removes the leading pipe character from the lines. This can be used to have a
# way to preserve indentation for the docs section.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   None
# STDIN:
#   Lines that potentially contains the pipe character.
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Lines without the leading pipe prefix.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_dm_lib__config__remove_leading_pipe() {
  cat - | sed -E "s/^\|//"
}