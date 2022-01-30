#==============================================================================
# SUBMODULE: CONFIG
#==============================================================================
#    _____             __ _
#   / ____|           / _(_)
#  | |     ___  _ __ | |_ _  __ _
#  | |    / _ \| '_ \|  _| |/ _` |
#  | |___| (_) | | | | | | | (_| |
#   \_____\___/|_| |_|_| |_|\__, |
#                            __/ |
#===========================|___/=============================================

#==============================================================================
# Parses the module name from the config file.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: Module path - this is the path to the module the name should be
#      loaded from.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Name of the module in a single line.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__config__get_name() {
  module_path="$1"

  prefix="NAME"

  dm_lib__debug "dm_lib__config__get_name" \
    "parsing name for prefix '${prefix}' from module '${module_path}'.."

  name="$( \
    _dm_lib__config__get_prefixed_lines_from_config_file "$module_path" "$prefix" | \
      _dm_lib__config__parse_as_line | \
      _dm_lib__utils__select_line "1" \
  )"

  dm_lib__debug "dm_lib__config__get_name" \
    "name parsed: '${name}'"

  echo "$name"
}

#==============================================================================
# Parses the module version from the config file.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: Module path - this is the path to the module the version should be
#      loaded from.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Version of the module in a single line.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__config__get_version() {
  module_path="$1"

  prefix="VERSION"

  dm_lib__debug "dm_lib__config__get_version" \
    "parsing version for prefix '${prefix}' from module '${module_path}'.."

  version="$( \
    _dm_lib__config__get_prefixed_lines_from_config_file "$module_path" "$prefix" | \
      _dm_lib__config__parse_as_list | \
      _dm_lib__utils__trim_list "1" | \
      _dm_lib__utils__select_line "1" \
  )"

  dm_lib__debug "dm_lib__config__get_version" \
    "version parsed: '${version}'"

  echo "$version"
}

#==============================================================================
# Parses the module documentation from the config file.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: Module path - this is the path to the module the docs should be
#      loaded from.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Module documentation optionally in multiple lines.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__config__get_docs() {
  module_path="$1"

  prefix="DOC"

  dm_lib__debug "dm_lib__config__get_docs" \
    "parsing documentation for prefix '${prefix}' from module '${module_path}'.."

  docs="$( \
    _dm_lib__config__get_prefixed_lines_from_config_file "$module_path" "$prefix" | \
      _dm_lib__config__parse_as_line | \
      _dm_lib__config__remove_leading_pipe
  )"

  dm_lib__debug_list "dm_lib__config__get_docs" \
    "documentation parsed:" "$docs"

  echo "$docs"
}

#==============================================================================
# Removes the leading pipe character from the lines. This can be used to have a
# way to preserve indentation for the docs section.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - None
# StdIn
# - Lines that potentially contains the pipe character.
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Lines without the leading pipe prefix.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__config__remove_leading_pipe() {
  cat - | sed -E "s/^\|//"
}

#==============================================================================
# Parses the module registered variables from the config file.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: Module path - this is the path to the module the variables should be
#      loaded from.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - One variable definition per line.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__config__get_variables() {
  module_path="$1"

  prefix="REGISTER"

  dm_lib__debug "dm_lib__config__get_variables" \
    "parsing variables for prefix '${prefix}' from module '${module_path}'.."

  variables="$( \
    _dm_lib__config__get_prefixed_lines_from_config_file "$module_path" "$prefix" | \
      _dm_lib__config__parse_as_list \
  )"

  dm_lib__debug_list "dm_lib__config__get_variables" \
    "variables parsed:" "$variables"

  echo "$variables"
}

#==============================================================================
# Parses the module registered links from the config file.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: Module path - this is the path to the module the links should be
#      loaded from.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - One link definition per line.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__config__get_links() {
  module_path="$1"

  prefix="LINK"

  dm_lib__debug "dm_lib__config__get_links" \
    "parsing links for prefix '${prefix}' from module '${module_path}'.."

  links="$( \
    _dm_lib__config__get_prefixed_lines_from_config_file "$module_path" "$prefix" | \
      _dm_lib__config__parse_as_list | \
      _dm_lib__utils__trim_list "1-2"
  )"

  dm_lib__debug_list "dm_lib__config__get_links" \
    "links parsed:" "$links"

  echo "$links"
}

#==============================================================================
# Parses the module registered hooks from the config file.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: Module path - this is the path to the module the hooks should be
#      loaded from.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - One normalized hook definition per line.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__config__get_hooks() {
  module_path="$1"

  prefix="HOOK"

  dm_lib__debug "dm_lib__config__get_hooks" \
    "parsing hooks for prefix '${prefix}' from module '${module_path}'.."

  hooks="$( \
    _dm_lib__config__get_prefixed_lines_from_config_file "$module_path" "$prefix" | \
      _dm_lib__config__parse_as_list \
  )"

  dm_lib__debug_list "dm_lib__config__get_hooks" \
    "hooks parsed:" "$hooks"

  normalized_hooks="$( \
    echo "$hooks" | _dm_lib__config__hooks__normalize \
  )"

  dm_lib__debug_list "dm_lib__config__get_hooks" \
    "hooks normalized:" "$normalized_hooks"

  echo "$normalized_hooks"
}

#==============================================================================
# Main hook token normalization function. It's task is to limit the hook tokens
# to 3 and calling the appropriate sub normalization function based on the
# remained token count. If there is only one token remains, it will gets
# ignored.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - None
# StdIn
# - Hooks to be normalized. One hook per line.
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Normalized hooks per line.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__config__hooks__normalize() {
  dm_lib__debug \
    "_dm_lib__config__hooks__normalize" \
    "normalization started by limiting the tokens to max 3"

  cat - | _dm_lib__utils__trim_list "1-3" | while read -r hook
  do
    dm_lib__debug \
      "_dm_lib__config__hooks__normalize" \
      "normalizing hook '${hook}':"

    count="$(echo "$hook" | wc -w)"

    dm_lib__debug \
      "_dm_lib__config__hooks__normalize" \
      "- token count: ${count}"

    if [ "$count" -eq "3" ]
    then
      normalized_hook="$(_dm_lib__config__hooks__normalize_3_tokens "$hook")"
    elif [ "$count" -eq "2" ]
    then
      normalized_hook="$(_dm_lib__config__normalize_hooks__2_tokens "$hook")"
    else
      dm_lib__debug \
        "_dm_lib__config__hooks__normalize" \
        "- missing mandatory script path, ignoring hook!"
      continue
    fi

    dm_lib__debug \
      "_dm_lib__config__hooks__normalize" \
      "- hook normalized: '${normalized_hook}'"

    echo "$normalized_hook"
  done
}

#==============================================================================
# Normalizes the hook that contains 3 tokens. If the tokens match to the
# expected '<signal> <priotity> <path>' pattern then there is nothing to do. If
# the priority is not an integer, then it is assumed that the third token is
# not important, and it gets removed, and the default priority will be inserted
# betwen the 1st and 2nd tokens, thus forcing out the valid pattern.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: hook tokens
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Normalized hook tokens.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__config__hooks__normalize_3_tokens() {
  hook="$1"

  if echo "$hook" | grep -q -P '^[^\s]+\s\d+\s[^\s]+$'
  then
    dm_lib__debug \
      "_dm_lib__config__hooks__normalize_3_tokens" \
      "- hook matches to the '<signal> <priotity> <path>' pattern, nothing to do"

    echo "$hook"

  else
    dm_lib__debug \
      "_dm_lib__config__hooks__normalize_3_tokens" \
      "- priority is not an integer in '<signal> <priotity> <path>' pattern"
    dm_lib__debug \
      "_dm_lib__config__hooks__normalize_3_tokens" \
      "- assuming it is missing, removing 3rd token"

    echo "$hook" | \
      _dm_lib__utils__trim_list "1-2" | \
      _dm_lib__config__hooks__insert_priority
  fi
}

#==============================================================================
# Normalizes the hook that contains 2 tokens. It will insert the default
# priority between the 1st and 2nd token.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: hook tokens
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Normalized hook tokens.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__config__normalize_hooks__2_tokens() {
  hook="$1"

  dm_lib__debug \
    "_dm_lib__config__normalize_hooks__2_tokens" \
    "- priority missing, inserting the default one"

  echo "$hook" | _dm_lib__config__hooks__insert_priority
}

#==============================================================================
# Inserts the default priority between the 1st and 2nd token.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - None
# StdIn
# - Token stream. It expects to got 2 tokens per line.
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Modified token stream.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__config__hooks__insert_priority() {
  dm_lib__debug \
    "_dm_lib__config__hooks__insert_priority" \
    "- inserting default priority"

  cat - | sed -E 's/^[^\s]+\s/&0 /'
}

#==============================================================================
# Returns a list of scripts that configured to be run during a selected hook.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: Module path - this is the path to the module the hooks should be
#      loaded from.
# - 2: Hook name - the hook we are searching for.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Script name per line.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__config__get_scripts_for_hook() {
  # ????????????????????????????????
  module_path="$1"
  hook="$2"

  dm_lib__debug "dm_lib__config__get_scripts_for_hook" \
    "getting scripts for hook '${hook}' from module '${module_path}'.."

  dm_lib__config__get_hooks "$module"| \
    grep "$hook" | \
    _dm_lib__utils__trim_list "2"
}

#==============================================================================
# Assembles the config file path given the module's root path.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__CONFIG__CONFIG_FILE_NAME
# Arguments
# - 1: Module path - this is the path to the module.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - The path to the config file.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__config__get_config_file_path() {
  module_path="$1"
  config_file="${module_path}/${DM__GLOBAL__CONFIG__CONFIG_FILE_NAME}"
  echo "$config_file"
}

#==============================================================================
# Reads the config file and returns the related lines based on the given
# prefix.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: Config file path.
# - 2: Prefix - this is used for related line identification.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Matched related lines based on the prefix.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__config__get_lines_for_prefix() {
  config_file="$1"
  prefix="$2"
  grep --color=never --regexp="^\s*$prefix" "$config_file"
}

#==============================================================================
# Removes the prefix part from the given line.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: Prefix - the prefix that should be removed from the given input lines.
# StdIn
# - Lines that should be cleaned from the prefix part.
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Cleaned lines.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__config__remove_prefix_from_lines() {
  prefix="$1"
  cat - | sed -E "s/\s*${prefix}\s+//"
}

#==============================================================================
# Helper function that reads the related config lines and removes it's prefix
# parts.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: Module path.
# - 2: Prefix - this is used for related line identification.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Matched and prefix-stripped related lines based on the prefix.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
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
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - None
# StdIn
# - Lines that needs to be parsed.
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Parsed lines.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__config__parse_as_list() {
  cat - | _dm_lib__utils__parse_list
}

#==============================================================================
# Function that will parse the given lines as text lines keepeing every inner
# whitespace while stripping the surrounding whitespace.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - None
# StdIn
# - Lines that needs to be parsed.
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Parsed lines.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__config__parse_as_line() {
  cat - | _dm_lib__utils__remove_surrounding_whitespace
}
