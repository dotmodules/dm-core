#==============================================================================
# SUBMODULE HOOKS
#==============================================================================
#   _    _             _
#  | |  | |           | |
#  | |__| | ___   ___ | | _____
#  |  __  |/ _ \ / _ \| |/ / __|
#  | |  | | (_) | (_) |   <\__ \
#  |_|  |_|\___/ \___/|_|\_\___/
#
#==============================================================================

# Hooks cache file that will contain the hooks from all of the modules in a
# sorted way.
DM__GLOBAL__HOOKS__CACHE_FILE="${DM__GLOBAL__CONFIG__CACHE_DIR}/dm.hooks"

#==============================================================================
# API function to load the hooks from all the modules. After this function
# return, the cache file will contain a sorted list of the registered hooks.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__HOOKS__CACHE_FILE
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
# - None
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__hooks__load() {
  _dm_lib__hooks__collect_hooks_from_modules > \
    "$DM__GLOBAL__HOOKS__CACHE_FILE"
  _dm_lib__hooks__sort
  dm_lib__debug \
    "dm_lib__hooks__load" \
    "hooks loaded"
}

#==============================================================================
# API function to print all hooks to the standard output.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__HOOKS__CACHE_FILE
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
# - All hooks line by line.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__hooks__get_all() {
  dm_lib__debug \
    "dm_lib__hooks__get_all" \
    "getting the content of the hook cache file.."
  cat "$DM__GLOBAL__HOOKS__CACHE_FILE"
}

#==============================================================================
# API function to print all signals for the registered hooks.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__HOOKS__CACHE_FILE
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
# - All signals line by line.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__hooks__get_signal_names() {
  dm_lib__debug \
    "dm_lib__hooks__get_signal_names" \
    "getting signal names from the hook cache file.."
  cut --delimiter=' ' --fields='1' "$DM__GLOBAL__HOOKS__CACHE_FILE" | \
    sort | \
    uniq
}

#==============================================================================
# API function to get all hooks from a module.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: module - module path
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - All hooks line by line for the given module.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__hooks__get_hooks_for_module() {
  module="$1"

  dm_lib__debug \
    "dm_lib__hooks__get_hooks_for_module" \
    "getting hooks from the module '${module}'"

  dm_lib__config__get_hooks "$module" | while read -r hook
  do
    _dm_lib__hooks__expand_hook "$hook" "$module"
  done
}

#==============================================================================
# Returns the signal name for the index that correspongs to the line number in
# the sorted signal names list.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - index - signal index started from 1.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Selected signal name
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error and the returned number is the max number of the index
#==============================================================================
dm_lib__hooks__signal_for_index() {
  selected_index="$1"

  dm_lib__debug "dm_lib__hooks__signal_for_index" \
    "getting signal name for index '${selected_index}'"

  signals="$(dm_lib__hooks__get_signal_names)"

  if signal="$(_dm_lib__utils__line_by_index "$selected_index" "$signals")"
  then
    :
  else
    dm_lib__debug \
      "dm_lib__hooks__signal_for_index" \
      "received index '${selected_index}' is invalid, aborting.."
    return 1
  fi

  dm_lib__debug \
    "dm_lib__hooks__signal_for_index" \
    "returning signal name: ${signal}"

  echo "$signal"
}

#==============================================================================
# API function to get the longest signal name length.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__HOOKS__CACHE_FILE
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
# - All hooks line by line.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__hooks__get_max_signal_name_length() {
  dm_lib__debug \
    "dm_lib__hooks__get_max_signal_name_length" \
    "getting the max signal name length from the hooks cache file"

  result="$( \
    cut --delimiter=' ' --fields='1' "$DM__GLOBAL__HOOKS__CACHE_FILE" | \
    wc --max-line-length \
  )"

  dm_lib__debug \
    "dm_lib__hooks__get_max_signal_name_length" \
    "returning result: '${result}'"

  echo "$result"
}

#==============================================================================
# API function to get the longest priority number length.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__HOOKS__CACHE_FILE
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
# - All hooks line by line.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__hooks__get_max_priority_number_length() {
  dm_lib__debug \
    "dm_lib__hooks__get_max_priority_number_length" \
    "getting the max priority number length from the hooks cache file"

  result="$( \
    cut --delimiter=' ' --fields='2' "$DM__GLOBAL__HOOKS__CACHE_FILE" | \
    wc --max-line-length \
  )"

  dm_lib__debug \
    "dm_lib__hooks__get_max_priority_number_length" \
    "returning result: '${result}'"

  echo "$result"
}

#==============================================================================
# Function to sort the hooks in the cache file.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__HOOKS__CACHE_FILE
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
# - None
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__hooks__sort() {
  sort \
    --version-sort \
    --output="$DM__GLOBAL__HOOKS__CACHE_FILE" \
    "$DM__GLOBAL__HOOKS__CACHE_FILE"

  dm_lib__debug \
    "_dm_lib__hooks__sort" \
    "hooks cache file sorted"
}

#==============================================================================
# Private function that collects all hooks from the modules and prints
# them out to the standard output.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
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
# - Line by line list of all the variables loaded from the modules.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__hooks__collect_hooks_from_modules() {
  dm_lib__debug \
    "_dm_lib__hooks__collect_hooks_from_modules" \
    "collecting hooks from modules.."

  modules="$(dm_lib__modules__list)"
  for module in $modules
  do
    dm_lib__hooks__get_hooks_for_module "$module"
  done
}

#==============================================================================
# Function to convert the hook's path to an absolute path. This function does
# not cares about if the file at the expanded file is not exists. This check
# has to be made in a higher level.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: hook - the hook string that needs to be expanded with the following
#             structure: '<signal_name> <priority_number> <paht>.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Expanded hook string.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__hooks__expand_hook() {
  hook="$1"
  module="$2"

  signal="${hook%% *}"  # getting the first element from the list
  remaining="${hook#* }"  # getting all items but the first
  priority="${remaining%% *}"  # getting the first element from the list
  path="${remaining#* }"  # getting all items but the first

  dm_lib__debug \
    "_dm_lib__hooks__expand_hook" \
    "resolving absoute path for '${path}'"

  # Getting the absolute path without requiring to be existing. In this
  # way, this command will always succeed. The existence should be checked
  # on a higher level.
  absolute_path="$(readlink --canonicalize-missing "${module}/${path}")"

  dm_lib__debug \
    "_dm_lib__hooks__expand_hook" \
    "resolved: '${absolute_path}'"

  echo "${signal} ${priority} ${absolute_path}"
}
