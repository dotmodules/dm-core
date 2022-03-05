#!/bin/sh
#==============================================================================
#   _   _      _
#  | | | | ___| |_ __
#  | |_| |/ _ \ | '_ \
#  |  _  |  __/ | |_) |
#  |_| |_|\___|_| .__/
#               |_|
#==============================================================================
# COMMAND: HELP
#==============================================================================

export DM__CLI__COMMANDS__HELP__NAME='dm__cli__commands__help'
export DM__CLI__COMMANDS__HELP__DOCS='Prints out this help message. This is the default command.'

#==============================================================================
# Top level interpreter function for the command help.
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
#   Help text.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm__cli__commands__help() {
  _dm__cli__commands__help__title
  _dm__cli__commands__help__list_commands
  dm_tools__echo ''
}

#==============================================================================
# Helper function that prints the help text title.
#------------------------------------------------------------------------------
# Globals:
#   DM__CONFIG__VERSION
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Help text title.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_dm__cli__commands__help__title() {
  dm_tools__echo ''
  dm__cli__display__header "DOTMODULES v${DM__CONFIG__VERSION}"
}

#==============================================================================
# Helper function that prints the available commands for the help text.
#------------------------------------------------------------------------------
# Globals:
#   BOLD
#   CYAN
#   RESET
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Help text title.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_dm__cli__commands__help__list_commands() {
  dm_tools__echo ''
  dm__cli__display__header 'AVAILABLE COMMANDS'

  dm__cli__commands__get_docs | while read -r line
  do
    hotkeys="${line%% *}"  # getting the first element from the list
    doc="${line#* }"  # getting all items but the first

    header_padding='16'
    format="${BOLD}${CYAN}%${header_padding}s${RESET} %s\n"

    dm__cli__display__header_multiline \
      "$header_padding" \
      "$format" \
      "$hotkeys" \
      "$doc"
  done
}