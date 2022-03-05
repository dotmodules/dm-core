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

DM__CLI__INTERPRETER__EXIT_CONDITION='0'
DM__CLI__INTERPRETER__PROMPT='0'

#==============================================================================
# Helper function to check if the interpreter should be stopped or not.
#------------------------------------------------------------------------------
# Globals:
#   DM__CLI__INTERPRETER__EXIT_CONDITION
# Arguments:
#   None
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
#   0 - The interpreter may continue.
#   1 - The interpreter should be stopped.
#==============================================================================
_dm__cli__interpreter__should_run() {
  test "$DM__CLI__INTERPRETER__EXIT_CONDITION" -eq "0"
}

#==============================================================================
# Helper function that will make the interpreter stop on the next cycle.
#------------------------------------------------------------------------------
# Globals:
#   DM__CLI__INTERPRETER__EXIT_CONDITION
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM__CLI__INTERPRETER__EXIT_CONDITION
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm__cli__interpreter__abort() {
  dm__debug 'dm__cli__interpreter__abort' \
    'triggering interpreter abort condition..'
  DM__CLI__INTERPRETER__EXIT_CONDITION='1'
}

#==============================================================================
# Function to initialize the interpreter internals.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   None
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
dm__cli__interpreter__init() {
  dm__debug 'dm__cli__interpreter__init' 'initializing cli interpreter..'

  _dm__cli__interpreter__init_commands
  _dm__cli__interpreter__init_prompt

  dm__debug 'dm__cli__interpreter__init' 'cli interpreter initialized'
}

#==============================================================================
# Function to initialize the available commands in the system. Each command has
# to be registered individually in it.
#------------------------------------------------------------------------------
# Globals:
#   DM__CONFIG__CLI__HOTKEYS__EXIT
#   DM__CLI__COMMANDS__EXIT__NAME
#   DM__CLI__COMMANDS__EXIT__DOCS
#   DM__CONFIG__CLI__HOTKEYS__HELP
#   DM__CLI__COMMANDS__HELP__NAME
#   DM__CLI__COMMANDS__HELP__DOCS
# Arguments:
#   None
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
_dm__cli__interpreter__init_commands() {
  dm__debug 'dm__cli__interpreter__init_commands' \
    'command registration started'

  dm__cli__commands__register_default "$DM__CLI__COMMANDS__HELP__NAME"
  dm__cli__commands__register \
    "$DM__CONFIG__CLI__HOTKEYS__HELP" \
    "$DM__CLI__COMMANDS__HELP__NAME" \
    "$DM__CLI__COMMANDS__HELP__DOCS"

  dm__cli__commands__register \
    "$DM__CONFIG__CLI__HOTKEYS__EXIT" \
    "$DM__CLI__COMMANDS__EXIT__NAME" \
    "$DM__CLI__COMMANDS__EXIT__DOCS"

  dm__cli__commands__register \
    "$DM__CONFIG__CLI__HOTKEYS__MODULES" \
    "$DM__CLI__COMMANDS__MODULES__NAME" \
    "$DM__CLI__COMMANDS__MODULES__DOCS"

  dm__cli__commands__register \
    "$DM__CONFIG__CLI__HOTKEYS__VARIABLES" \
    "$DM__CLI__COMMANDS__VARIABLES__NAME" \
    "$DM__CLI__COMMANDS__VARIABLES__DOCS"

  dm__cli__commands__register \
    "$DM__CONFIG__CLI__HOTKEYS__HOOKS" \
    "$DM__CLI__COMMANDS__HOOKS__NAME" \
    "$DM__CLI__COMMANDS__HOOKS__DOCS"

  dm__debug 'dm__cli__interpreter__init_commands' \
    'command registration finished'
}

#==============================================================================
# Formats the raw prompt template by replacing the template keywords with the
# proper values. This has to be executed this way, because we don't want to use
# exec to replace the shell variables that would be passed from the Makefile.
# In this way there is no security risk while having a fully customizable
# prompt.
#------------------------------------------------------------------------------
# Globals:
#   DM__CONFIG__CLI__PROMPT_TEMPLATE
#   DM__CONFIG__CLI__INDENT
#   RED
#   GREEN
#   YELLOW
#   BLUE
#   MAGENTA
#   CYAN
#   BOLD
#   DIM
#   RESET
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM__CLI__INTERPRETER__PROMPT
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_dm__cli__interpreter__init_prompt() {
  DM__CLI__INTERPRETER__PROMPT="$(
    dm_tools__echo "$DM__CONFIG__CLI__PROMPT_TEMPLATE" | \
      dm_tools__sed --expression "s/<<indent>>/${DM__CONFIG__CLI__INDENT}/g" | \
      dm_tools__sed --expression "s/<<space>>/ /g" | \
      dm_tools__sed --expression "s/<<red>>/${RED}/g" | \
      dm_tools__sed --expression "s/<<green>>/${GREEN}/g" | \
      dm_tools__sed --expression "s/<<yellow>>/${YELLOW}/g" | \
      dm_tools__sed --expression "s/<<blue>>/${BLUE}/g" | \
      dm_tools__sed --expression "s/<<magenta>>/${MAGENTA}/g" | \
      dm_tools__sed --expression "s/<<cyan>>/${CYAN}/g" | \
      dm_tools__sed --expression "s/<<bold>>/${BOLD}/g" | \
      dm_tools__sed --expression "s/<<dim>>/${DIM}/g" | \
      dm_tools__sed --expression "s/<<reset>>/${RESET}/g" \
  )"
}

#==============================================================================
# Interpreter implementation that waits for the user's input and tries to find
# the commands for the input.
#------------------------------------------------------------------------------
# Globals:
#   DM__CLI__INTERPRETER__PROMPT
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Prints out the interpreted commands output.
# STDERR:
#   Error that occured during operation.
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm__cli__interpreter__run() {
  dm__debug 'dm_cli__run_interpreter' 'interpreter is starting up..'
  while _dm__cli__interpreter__should_run
  do
    dm__debug 'dm_cli__run_interpreter' 'waiting for user input..'

    # POSIX does not define the prompt section of the read command, this is why
    # we need to use an explicit printf before the read.
    # Read more: https://github.com/koalaman/shellcheck/wiki/SC2039
    printf "%s" "$DM__CLI__INTERPRETER__PROMPT"

    # TODO: add arrow key handling with history
    read -r raw_command

    if [ -z "$raw_command" ]
    then
      dm__debug 'dm_cli__run_interpreter' \
        'empty user input received, skip prcessing..'
      continue
    else
      dm__debug 'dm_cli__run_interpreter' \
        "user input received: '${raw_command}'"
    fi

    # TODO: add help system as a question mark postfix. This information will
    # be appended to the command arguments.

    _command="$(dm__cli__commands__query "$raw_command")"

    dm__debug 'dm_cli__run_interpreter' "executing command: '${_command}'"
    $_command
    dm__debug 'dm_cli__run_interpreter' "command '${_command}' executed"

  done
  dm__debug 'dm_cli__run_interpreter' 'interpreter finished, exiting..'
}
