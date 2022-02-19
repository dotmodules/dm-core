#!/bin/sh
#==============================================================================
#   _____       _                           _
#  |_   _|     | |                         | |
#    | |  _ __ | |_ ___ _ __ _ __  _ __ ___| |_ ___ _ __
#    | | | '_ \| __/ _ \ '__| '_ \| '__/ _ \ __/ _ \ '__|
#   _| |_| | | | ||  __/ |  | |_) | | |  __/ ||  __/ |
#  |_____|_| |_|\__\___|_|  | .__/|_|  \___|\__\___|_|
#                           | |
#===========================|_|================================================
# INTERPRETER
#==============================================================================

DM__GLOBAL__CLI__EXIT_CONDITION="0"

#==============================================================================
# Interpreter implementation that waits for the user's input and tries to find
# the commands for the input.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__CLI__EXIT_CONDITION
# - DM__GLOBAL__CLI__PROMPT
# Arguments
# - None
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Prints out the interpreted commands output.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_cli__start_interpreter() {
  dm_lib__debug "dm_cli__interpreter" "interpreter starting.."
  while [ "$DM__GLOBAL__CLI__EXIT_CONDITION" -eq "0" ]
  do
    dm_lib__debug "dm_cli__interpreter" "waiting for user input.."

    # POSIX does not define the prompt section of the read command, this is why
    # we need to use an explicit printf before the read.
    # Read more: https://github.com/koalaman/shellcheck/wiki/SC2039
    printf "%s" "$DM__GLOBAL__CLI__PROMPT"

    # TODO: add arrow key handling with history
    read -r raw_command

    if [ -z "$raw_command" ]
    then
      dm_lib__debug "dm_cli__interpreter" \
        "empty user input received, skip processing.."
      continue
    else
      dm_lib__debug "dm_cli__interpreter" \
        "user input received: '${raw_command}'"
    fi

    # TODO: add help system as a question mark postfix. This information will
    # be appended to the command arguments.

    _command="$(_dm_cli__get_command "$raw_command")"

    dm_lib__debug "dm_cli__interpreter" "executing command: '${_command}'"
    $_command
    dm_lib__debug "dm_cli__interpreter" "command '${_command}' executed"

  done
  dm_lib__debug "dm_cli__interpreter" "interpreter finished, exiting.."
}
