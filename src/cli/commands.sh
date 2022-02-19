#!/bin/sh
#==============================================================================
# COMMAND MANAGEMENT
#==============================================================================
#    _____                                          _
#   / ____|                                        | |
#  | |     ___  _ __ ___  _ __ ___   __ _ _ __   __| |___
#  | |    / _ \| '_ ` _ \| '_ ` _ \ / _` | '_ \ / _` / __|
#  | |___| (_) | | | | | | | | | | | (_| | | | | (_| \__ \
#   \_____\___/|_| |_| |_|_| |_| |_|\__,_|_| |_|\__,_|___/
#
#==============================================================================

#==============================================================================
# REGISTERING COMMANDS
#==============================================================================
# The dm cli has a completely dynamic command registering system, that
# decouples it completely from the interpreter system. New commands can be
# registered easily alongside with the documentation. The registering system
# offers an interrogation interface to be able to search for the registered
# commands.
#
# Each registered command should be implemented in a callable function. This
# function name gets registered and returned upon command search.

# Global variable to store the registered commands.
DM_CLI__RUNTIME__REGISTERED_COMMANDS=""

# Global variable to store the short documentation for the commands.
DM_CLI__RUNTIME__REGISTERED_COMMAND_DOCS=""

# Global variable to store the default command.
DM_CLI__RUNTIME__DEFAULT_COMMAND=""

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
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM_CLI__RUNTIME__REGISTERED_COMMANDS
# - DM_CLI__RUNTIME__REGISTERED_COMMAND_DOCS
#
# Arguments
# - 1: Pipe character separated list of hotkeys that should trigger the command
#      on search.
# - 2: Function name for the given command.
# - 3: Short documentation for the given command.
#
# StdIn
# - None
#
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
#
# StdOut
# - None
#
# StdErr
# - Error that occured during operation.
#
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_cli__register_command() {
  hotkeys="$1"
  _command="$2"
  doc="$3"

  # Hotkeys can be separated by a pipe character.
  for hotkey in $(echo "$hotkeys" | sed 's/|/ /g')
  do
    dm_lib__debug "dm_cli__register_command" \
      "processing hotkey '${hotkey}'"
    DM_CLI__RUNTIME__REGISTERED_COMMANDS="$( \
      echo "${DM_CLI__RUNTIME__REGISTERED_COMMANDS}"; \
      echo "${hotkey} ${_command}" \
    )"
  done

  DM_CLI__RUNTIME__REGISTERED_COMMAND_DOCS="$( \
    echo "${DM_CLI__RUNTIME__REGISTERED_COMMAND_DOCS}"; \
    echo "${hotkeys} ${doc}" \
  )"

  dm_lib__debug "dm_cli__register_command" \
    "command '${_command}' registered for hotkey '${hotkeys}'"
}

#==============================================================================
# Function to register the function name for the default command.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM_CLI__RUNTIME__DEFAULT_COMMAND
# Arguments
# - 1: Function name for the default command.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - None
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_cli__register_default_command() {
  _command="$1"
  DM_CLI__RUNTIME__DEFAULT_COMMAND="$_command"
  dm_lib__debug "dm_cli__register_default_command" \
    "command '${_command}' registered as the default command"
}

#==============================================================================
# Function to search and return the registered function name for the given
# command. If the given command is not found, the registered default command
# function gets returned.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM_CLI__RUNTIME__DEFAULT_COMMAND
# - DM_CLI__RUNTIME__REGISTERED_COMMANDS
# Arguments
# - 1: Raw command query string. Based on this parameter the function tries to
#      find the command and returns the registered function name.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Registered function name that is matched for the given command query string.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_cli__get_command() {
  raw_command="$1"
  dm_lib__debug "_dm_cli__get_command" \
    "processing raw command: '${raw_command}'"

  hotkey=$(echo "$raw_command" | _dm_lib__utils__trim_list 1)
  dm_lib__debug "_dm_cli__get_command" \
    "hotkey separated: '${hotkey}'"

  word_count=$(echo "$raw_command" | wc -w)
  if [ "$word_count" -gt 1 ]
  then
    params=$(echo "$raw_command" | _dm_lib__utils__trim_list 2-)
    dm_lib__debug "_dm_cli__get_command" \
      "additional paramters: '${params}'"
  else
    params=""
    dm_lib__debug "_dm_cli__get_command" \
      "no additional parameters received"
  fi

  result=$(echo "$DM_CLI__RUNTIME__REGISTERED_COMMANDS" | grep -E "^${hotkey}\s" || true)
  if [ -n "$result" ]
  then
    _command=$(echo "$result" | _dm_lib__utils__trim_list 2)
    dm_lib__debug "_dm_cli__get_command" \
      "command matched for hotkey: '${_command}'"
    _command="$_command $params"
  else
    dm_lib__debug "_dm_cli__get_command" \
      "no match for hotkey, using default command: '${DM_CLI__RUNTIME__DEFAULT_COMMAND}'"
    _command="$DM_CLI__RUNTIME__DEFAULT_COMMAND"
  fi

  echo "$_command" | _dm_lib__utils__remove_surrounding_whitespace
}