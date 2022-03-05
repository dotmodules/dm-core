#!/bin/sh

#==============================================================================
# Parses the module registered hooks from the config file.
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
#   One normalized hook definition per line.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm_lib__config__get_hooks() {
  module_path="$1"

  prefix="HOOK"

  dm__debug "dm_lib__config__get_hooks" \
    "parsing hooks for prefix '${prefix}' from module '${module_path}'.."

  hooks="$( \
    _dm_lib__config__get_prefixed_lines_from_config_file "$module_path" "$prefix" | \
      _dm_lib__config__parse_as_list \
  )"

  dm__debug_list "dm_lib__config__get_hooks" \
    "hooks parsed:" "$hooks"

  normalized_hooks="$( \
    echo "$hooks" | _dm_lib__config__hooks__normalize \
  )"

  dm__debug_list "dm_lib__config__get_hooks" \
    "hooks normalized:" "$normalized_hooks"

  echo "$normalized_hooks"
}

#==============================================================================
# Main hook token normalization function. It's task is to limit the hook tokens
# to 3 and calling the appropriate sub normalization function based on the
# remained token count. If there is only one token remains, it will gets
# ignored.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   None
# STDIN:
#   Hooks to be normalized. One hook per line.
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Normalized hooks per line.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_dm_lib__config__hooks__normalize() {
  dm__debug \
    "_dm_lib__config__hooks__normalize" \
    "normalization started by limiting the tokens to max 3"

  cat - | _dm_lib__utils__trim_list "1-3" | while read -r hook
  do
    dm__debug \
      "_dm_lib__config__hooks__normalize" \
      "normalizing hook '${hook}':"

    count="$(echo "$hook" | wc -w)"

    dm__debug \
      "_dm_lib__config__hooks__normalize" \
      "- token count: ${count}"

    if [ "$count" -eq "3" ]
    then
      normalized_hook="$(_dm_lib__config__hooks__normalize_3_tokens "$hook")"
    elif [ "$count" -eq "2" ]
    then
      normalized_hook="$(_dm_lib__config__normalize_hooks__2_tokens "$hook")"
    else
      dm__debug \
        "_dm_lib__config__hooks__normalize" \
        "- missing mandatory script path, ignoring hook!"
      continue
    fi

    dm__debug \
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
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] hook_tokens
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Normalized hook tokens.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_dm_lib__config__hooks__normalize_3_tokens() {
  hook="$1"

  if echo "$hook" | grep -q -P '^[^\s]+\s\d+\s[^\s]+$'
  then
    dm__debug \
      "_dm_lib__config__hooks__normalize_3_tokens" \
      "- hook matches to the '<signal> <priotity> <path>' pattern, nothing to do"

    echo "$hook"

  else
    dm__debug \
      "_dm_lib__config__hooks__normalize_3_tokens" \
      "- priority is not an integer in '<signal> <priotity> <path>' pattern"
    dm__debug \
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
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] hook_tokens
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Normalized hook tokens.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_dm_lib__config__normalize_hooks__2_tokens() {
  hook="$1"

  dm__debug \
    "_dm_lib__config__normalize_hooks__2_tokens" \
    "- priority missing, inserting the default one"

  echo "$hook" | _dm_lib__config__hooks__insert_priority
}

#==============================================================================
# Inserts the default priority between the 1st and 2nd token.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   None
# STDIN:
#   Token stream. It expects to got 2 tokens per line.
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Modified token stream.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_dm_lib__config__hooks__insert_priority() {
  dm__debug \
    "_dm_lib__config__hooks__insert_priority" \
    "- inserting default priority"

  cat - | sed -E 's/^[^\s]+\s/&0 /'
}

#==============================================================================
# Returns a list of scripts that configured to be run during a selected hook.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   None
#   [1] module_path - this is the path to the module the hooks should be
#       loaded from.
#   [2] hook_name - the hook we are searching for.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Script name per line.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm_lib__config__get_scripts_for_hook() {
  # ????????????????????????????????
  module_path="$1"
  hook="$2"

  dm__debug "dm_lib__config__get_scripts_for_hook" \
    "getting scripts for hook '${hook}' from module '${module_path}'.."

  dm_lib__config__get_hooks "$module"| \
    grep "$hook" | \
    _dm_lib__utils__trim_list "2"
}
