#!/bin/sh

export DM__CONFIG__CONFIG_FILE_NAME='dm.conf'

#==============================================================================
# Loads all the necessary parameters from the given parameters file then it
# deletes it.
#------------------------------------------------------------------------------
# Globals:
#   DM__CONFIG__RELATIVE_MODULES_PATH
#   DM__CONFIG__CLI__TEXT_WRAP_LIMIT
#   DM__CONFIG__CLI__INDENT
#   DM__CONFIG__CLI__PROMPT_TEMPLATE
#   DM__CONFIG__CLI__HOTKEYS__EXIT
#   DM__CONFIG__CLI__HOTKEYS__HELP
#   DM__CONFIG__CLI__HOTKEYS__HOOKS
#   DM__CONFIG__CLI__HOTKEYS__MODULES
#   DM__CONFIG__CLI__HOTKEYS__VARIABLES
#   DM__CONFIG__WARNING__WRAPPED_DOCS
# Arguments:
#   [1] parameters_file - Path to the paramters file.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM__CONFIG__RELATIVE_MODULES_PATH
#   DM__CONFIG__CLI__TEXT_WRAP_LIMIT
#   DM__CONFIG__CLI__INDENT
#   DM__CONFIG__CLI__PROMPT_TEMPLATE
#   DM__CONFIG__CLI__HOTKEYS__EXIT
#   DM__CONFIG__CLI__HOTKEYS__HELP
#   DM__CONFIG__CLI__HOTKEYS__HOOKS
#   DM__CONFIG__CLI__HOTKEYS__MODULES
#   DM__CONFIG__CLI__HOTKEYS__VARIABLES
#   DM__CONFIG__WARNING__WRAPPED_DOCS
# STDOUT:
#   Parameter value.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm__parameters__init() {
  parameters_file="$1"

  # This section is an exception from the no-longer-than-80-cahracters rule..
  DM__CONFIG__RELATIVE_MODULES_PATH="$(_dm__parameters__load 'DM__CONFIG__RELATIVE_MODULES_PATH' "$parameters_file")"
  DM__CONFIG__CLI__TEXT_WRAP_LIMIT="$(_dm__parameters__load 'DM__CONFIG__CLI__TEXT_WRAP_LIMIT' "$parameters_file")"
  DM__CONFIG__CLI__INDENT="$(_dm__parameters__load 'DM__CONFIG__CLI__INDENT' "$parameters_file")"
  DM__CONFIG__CLI__PROMPT_TEMPLATE="$(_dm__parameters__load 'DM__CONFIG__CLI__PROMPT_TEMPLATE' "$parameters_file")"
  DM__CONFIG__CLI__HOTKEYS__EXIT="$(_dm__parameters__load 'DM__CONFIG__CLI__HOTKEYS__EXIT' "$parameters_file")"
  DM__CONFIG__CLI__HOTKEYS__HELP="$(_dm__parameters__load 'DM__CONFIG__CLI__HOTKEYS__HELP' "$parameters_file")"
  DM__CONFIG__CLI__HOTKEYS__HOOKS="$(_dm__parameters__load 'DM__CONFIG__CLI__HOTKEYS__HOOKS' "$parameters_file")"
  DM__CONFIG__CLI__HOTKEYS__MODULES="$(_dm__parameters__load 'DM__CONFIG__CLI__HOTKEYS__MODULES' "$parameters_file")"
  DM__CONFIG__CLI__HOTKEYS__VARIABLES="$(_dm__parameters__load 'DM__CONFIG__CLI__HOTKEYS__VARIABLES' "$parameters_file")"
  DM__CONFIG__WARNING__WRAPPED_DOCS="$(_dm__parameters__load 'DM__CONFIG__WARNING__WRAPPED_DOCS' "$parameters_file")"

  # Post-process variables
  DM__CONFIG__CLI__INDENT="$( \
    dm_tools__printf "%${DM__CONFIG__CLI__INDENT}s" "" \
  )"

  export DM__CONFIG__RELATIVE_MODULES_PATH
  export DM__CONFIG__CLI__TEXT_WRAP_LIMIT
  export DM__CONFIG__CLI__INDENT
  export DM__CONFIG__CLI__PROMPT_TEMPLATE
  export DM__CONFIG__CLI__HOTKEYS__EXIT
  export DM__CONFIG__CLI__HOTKEYS__HELP
  export DM__CONFIG__CLI__HOTKEYS__HOOKS
  export DM__CONFIG__CLI__HOTKEYS__MODULES
  export DM__CONFIG__CLI__HOTKEYS__VARIABLES
  export DM__CONFIG__WARNING__WRAPPED_DOCS

  dm_tools__rm --force "$parameters_file"
}

#==============================================================================
# Loads the given parameter from the given parameter file. The file is expected
# to have one parameter per line in the following format:
# <parameter_name>=<parameter_value>
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] parameter_name - Name of the parameter should be loaded.
#   [2] parameters_file - Path to the paramters file.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Parameter value.
# STDERR:
#   None
# Status:
#   0 - Parameter name was found.
#   1 - Parameter name was not found or invalid syntax.
#==============================================================================
_dm__parameters__load() {
  parameter_name="$1"
  parameters_file="$2"

  if ! line="$(dm_tools__grep --extended "^${parameter_name}=.+$" "$parameters_file")"
  then
    dm__debug '_dm__parameters__load' \
      "parameter was not found: '${parameter_name}'"
    return 1
  fi

  value="$(dm_tools__echo "$line" | dm_tools__cut --delimiter '=' --fields 2)"

  dm__debug '_dm__parameters__load' "parameter loaded: ${parameter_name}='${value}'"

  dm_tools__echo "$value"
}