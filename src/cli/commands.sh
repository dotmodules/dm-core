#!/bin/sh
#==============================================================================
#    _____                                          _
#   / ____|                                        | |
#  | |     ___  _ __ ___  _ __ ___   __ _ _ __   __| |___
#  | |    / _ \| '_ ` _ \| '_ ` _ \ / _` | '_ \ / _` / __|
#  | |___| (_) | | | | | | | | | | | (_| | | | | (_| \__ \
#   \_____\___/|_| |_| |_|_| |_| |_|\__,_|_| |_|\__,_|___/
#
#==============================================================================
# COMMANDS
#==============================================================================

# Global variable to store the registered commands.
DM__CLI__REGISTERED_COMMANDS=""

# Global variable to store the short documentation for the commands.
DM__CLI__REGISTERED_COMMAND_DOCS=""

# Global variable to store the default command.
DM__CLI__DEFAULT_COMMAND=""

#==============================================================================
# Function to retrieve the registered commands and the related documentation.
#------------------------------------------------------------------------------
# Globals:
#   DM__CLI__REGISTERED_COMMAND_DOCS
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Registered commands and related docs per line.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm__cli__commands__get_docs() {
  dm_tools__echo "${DM__CLI__REGISTERED_COMMAND_DOCS}" | \
    dm__utils__remove_empty_lines
}


#==============================================================================
# Function to register the function name for a command with a hotkey list and a
# short documentation for the command that will be displayed in the help menu.
#
# Each command keyword gets written to a separate line followed by the
# registered command's function name providing an easily searchable list for
# later usage.
#
# Short documentation is handled similarly to the function names. For ech
# keyword the full short documentation is written into a separate line.
#------------------------------------------------------------------------------
# Globals:
#   DM__CLI__REGISTERED_COMMANDS
#   DM__CLI__REGISTERED_COMMAND_DOCS
# Arguments:
#   [1] hotkeys - Pipe character separated list of hotkeys that should trigger
#       the command on search.
#   [2] function_name - Function name for the given command.
#   [3] docs - Short documentation for the given command.
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
dm__cli__commands__register() {
  hotkeys="$1"
  function_name="$2"
  docs="$3"

  # Hotkeys are separated with a pipe character.
  for hotkey in $(dm_tools__echo "$hotkeys" | dm_tools__sed --expression 's/|/ /g')
  do
    dm__debug 'dm__cli__commands__register' "processing hotkey '${hotkey}'"
    DM__CLI__REGISTERED_COMMANDS="$( \
      dm_tools__echo "${DM__CLI__REGISTERED_COMMANDS}"; \
      dm_tools__echo "${hotkey} ${function_name}" \
    )"
  done

  DM__CLI__REGISTERED_COMMAND_DOCS="$( \
    dm_tools__echo "${DM__CLI__REGISTERED_COMMAND_DOCS}"; \
    dm_tools__echo "${hotkeys} ${docs}" \
  )"

  dm__debug 'dm__cli__commands__register' \
    "command '${function_name}' registered for hotkey '${hotkeys}'"
}

#==============================================================================
# Function to register the function name for the default command.
#------------------------------------------------------------------------------
# Globals:
#   DM__CLI__DEFAULT_COMMAND
# Arguments:
#   [1] function_name - Function name for the default command.
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
dm__cli__commands__register_default() {
  function_name="$1"

  DM__CLI__DEFAULT_COMMAND="$function_name"
  dm__debug 'dm__cli__commands__register_default' \
    "command '${function_name}' registered as the default command"
}

#==============================================================================
# Function to search and return the registered function name for the given
# command. If the given command is not found, the registered default command
# function gets returned.
#------------------------------------------------------------------------------
# Globals:
#   DM__CLI__DEFAULT_COMMAND
#   DM__CLI__REGISTERED_COMMANDS
# Arguments:
#   [1] query_string - Raw command query string. Based on this parameter the
#       function tries to find the command and returns the registered function
#       name.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Registered function name that is matched for the given command query string.
#   If no match found the default command will be returned.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm__cli__commands__query() {
  query_string="$1"

  dm__debug 'dm__cli__commands__query' \
    "processing raw command: '${query_string}'"

  hotkey=$(dm_tools__echo "$query_string" | dm__utils__trim_list '1')
  dm__debug 'dm__cli__commands__query' \
    "hotkey separated: '${hotkey}'"

  word_count=$(dm_tools__echo "$query_string" | dm_tools__wc --words)
  if [ "$word_count" -gt 1 ]
  then
    params=$(dm_tools__echo "$query_string" | dm__utils__trim_list '2-')
    dm__debug 'dm__cli__commands__query' \
      "additional paramters: '${params}'"
  else
    params=''
    dm__debug 'dm__cli__commands__query' \
      "no additional parameters received"
  fi

  result=$(dm_tools__echo "$DM__CLI__REGISTERED_COMMANDS" | dm_tools__grep --extended "^${hotkey}\s" || true)
  if [ -n "$result" ]
  then
    function_name=$(dm_tools__echo "$result" | dm__utils__trim_list '2')
    dm__debug 'dm__cli__commands__query' \
      "command matched for hotkey: '${function_name}'"
    function_name="${function_name} ${params}"
  else
    dm__debug 'dm__cli__commands__query' \
      "no match for hotkey, using default command: '${DM__CLI__DEFAULT_COMMAND}'"
    function_name="$DM__CLI__DEFAULT_COMMAND"
  fi

  dm_tools__echo "$function_name" | dm__utils__remove_surrounding_whitespace
}