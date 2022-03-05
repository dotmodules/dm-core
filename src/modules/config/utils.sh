#!/bin/sh

#==============================================================================
# Reads the config file and returns the related lines based on the given
# prefix.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] config_file_path
#   [2] prefix - this is used for related line identification.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Matched related lines based on the prefix.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_dm_lib__config__get_lines_for_prefix() {
  config_file="$1"
  prefix="$2"
  grep --color=never --regexp="^\s*$prefix" "$config_file"
}

#==============================================================================
# Removes the prefix part from the given line.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] prefix - Prefix that should be removed from the given input lines.
# STDIN:
#   Lines that should be cleaned from the prefix part.
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Cleaned lines.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_dm_lib__config__remove_prefix_from_lines() {
  prefix="$1"
  cat - | sed -E "s/\s*${prefix}\s+//"
}

#==============================================================================
# Helper function that reads the related config lines and removes it's prefix
# parts.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] Module path.
#   [2] Prefix - this is used for related line identification.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Matched and prefix-stripped related lines based on the prefix.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_dm_lib__config__get_prefixed_lines_from_config_file() {
  module_path="$1"
  prefix="$2"

  config_file="$(_dm_lib__config__get_config_file_path "$module_path")"

  _dm_lib__config__get_lines_for_prefix "$config_file" "$prefix" | \
    _dm_lib__config__remove_prefix_from_lines "$prefix"
}

#==============================================================================
# Function that will parse the given lines as a list by removing all
# unecessary whitespace.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   None
# STDIN:
#   Lines that needs to be parsed.
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Parsed lines.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_dm_lib__config__parse_as_list() {
  cat - | _dm_lib__utils__parse_list
}

#==============================================================================
# Function that will parse the given lines as text lines keepeing every inner
# whitespace while stripping the surrounding whitespace.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   None
# STDIN:
#   Lines that needs to be parsed.
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Parsed lines.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_dm_lib__config__parse_as_line() {
  cat - | _dm_lib__utils__remove_surrounding_whitespace
}