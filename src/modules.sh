#!/bin/sh
#==============================================================================
# SUBMODULE: MODULES
#==============================================================================
#   __  __           _       _
#  |  \/  |         | |     | |
#  | \  / | ___   __| |_   _| | ___  ___
#  | |\/| |/ _ \ / _` | | | | |/ _ \/ __|
#  | |  | | (_) | (_| | |_| | |  __/\__ \
#  |_|  |_|\___/ \__,_|\__,_|_|\___||___/
#
#==============================================================================

# Hooks cache file that will contain the hooks from all of the modules in a
# sorted way.
DM__GLOBAL__MODULES__CACHE_FILE="${DM__GLOBAL__CONFIG__CACHE_DIR}/dm.modules"
DM__GLOBAL__MODULES__CACHE_SEPARATOR='#'

#==============================================================================
# API function to load the modules and its basic properties to the modules cache
# file.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CONFIG__MANDATORY__TEST_CASE_PREFIX
# Arguments:
#   [1] test_file_path - Path of the given test file the test cases should be
#       collected from.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Test cases matched in the given test file.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm_lib__modules__load() {
  _dm_lib__modules__collect_modules > \
    "$DM__GLOBAL__MODULES__CACHE_FILE"
  dm_lib__debug \
    "dm_lib__modules__load" \
    "modules loaded"
}

#==============================================================================
# API function to load the modules and its basic properties to the modules
# cache file.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__MODULES__CACHE_FILE
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
dm_lib__modules__load() {
  _dm_lib__modules__collect_modules > \
    "$DM__GLOBAL__MODULES__CACHE_FILE"
  dm_lib__debug \
    "dm_lib__modules__load" \
    "modules loaded"
}

#==============================================================================
# Returns the relative path list for all recognized modules found in the
# modules cache file.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__MODULES__CACHE_FILE
# - DM__GLOBAL__MODULES__CACHE_SEPARATOR
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
# - Newline separated sorted list of module root paths
# StdErr
# - Error that occured during operation
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__modules__list() {
  dm_lib__debug "dm_lib__modules__list" \
    "listing modules from the cache file '${DM__GLOBAL__MODULES__CACHE_FILE}'"

  cut \
    --delimiter="$DM__GLOBAL__MODULES__CACHE_SEPARATOR" \
    --field='1' \
    "$DM__GLOBAL__MODULES__CACHE_FILE"
}

#==============================================================================
# Returns the module name from the modules cache file.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__MODULES__CACHE_FILE
# - DM__GLOBAL__MODULES__CACHE_SEPARATOR
# Arguments
# - module_path - relative path of the module
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Name of the given module.
# StdErr
# - Error that occured during operation
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__modules__get_name() {
  module_path="$1"
  dm_lib__debug "dm_lib__modules__get_name" \
    "getting name for module '$module' from cache"

  grep "$module_path" "$DM__GLOBAL__MODULES__CACHE_FILE" | \
    cut \
      --delimiter="$DM__GLOBAL__MODULES__CACHE_SEPARATOR" \
      --field='2'
}

#==============================================================================
# Returns the module version from the modules cache file.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__MODULES__CACHE_FILE
# - DM__GLOBAL__MODULES__CACHE_SEPARATOR
# Arguments
# - module_path - relative path of the module
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Version of the given module.
# StdErr
# - Error that occured during operation
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__modules__get_version() {
  module_path="$1"
  dm_lib__debug "dm_lib__modules__get_version" \
    "getting version for module '$module' from cache"

  grep "$module_path" "$DM__GLOBAL__MODULES__CACHE_FILE" | \
    cut \
      --delimiter="$DM__GLOBAL__MODULES__CACHE_SEPARATOR" \
      --field='3'
}

#==============================================================================
# Returns the module status from the modules cache file.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__MODULES__CACHE_FILE
# - DM__GLOBAL__MODULES__CACHE_SEPARATOR
# Arguments
# - module_path - relative path of the module
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Status of the given module.
# StdErr
# - Error that occured during operation
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__modules__get_status() {
  module_path="$1"
  dm_lib__debug "dm_lib__modules__get_status" \
    "getting status for module '$module' from cache"

  grep "$module_path" "$DM__GLOBAL__MODULES__CACHE_FILE" | \
    cut \
      --delimiter="$DM__GLOBAL__MODULES__CACHE_SEPARATOR" \
      --field='4'
}

#==============================================================================
# Returns the module indexes max width.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__MODULES__CACHE_FILE
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
# - Module indexes max width.
# StdErr
# - Error that occured during operation
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__modules__get_width__index() {
  dm_lib__debug "dm_lib__modules__get_width__index" \
    "getting width of the module indexes.."

  width="$( \
    # Using the 'useless cat' here, because otherwise wc will put in the file
    # name too, and we need to cut that, which is far more bloated.
    # shellcheck disable=SC2002
    cat "$DM__GLOBAL__MODULES__CACHE_FILE" | \
    wc --lines | \
    wc --max-line-length \
  )"

  dm_lib__debug "dm_lib__modules__get_width__index" \
    "module indexes max width is '${width}'"

  echo "$width"
}

#==============================================================================
# Returns the module names max width.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__MODULES__CACHE_FILE
# - DM__GLOBAL__MODULES__CACHE_SEPARATOR
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
# - Module names max width.
# StdErr
# - Error that occured during operation
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__modules__get_width__name() {
  dm_lib__debug "dm_lib__modules__get_width__name" \
    "getting width of the module names.."

  width="$( \
    cut \
      --delimiter="$DM__GLOBAL__MODULES__CACHE_SEPARATOR" \
      --field='2' \
      "$DM__GLOBAL__MODULES__CACHE_FILE" | \
    wc --max-line-length \
  )"

  dm_lib__debug "dm_lib__modules__get_width__name" \
    "modules names max width is '${width}'"

  echo "$width"
}

#==============================================================================
# Returns the module versions max width.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__MODULES__CACHE_FILE
# - DM__GLOBAL__MODULES__CACHE_SEPARATOR
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
# - Module versions max width.
# StdErr
# - Error that occured during operation
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__modules__get_width__version() {
  dm_lib__debug "dm_lib__modules__get_width__version" \
    "getting width of the module versions.."

  width="$( \
    cut \
      --delimiter="$DM__GLOBAL__MODULES__CACHE_SEPARATOR" \
      --field='3' \
      "$DM__GLOBAL__MODULES__CACHE_FILE" | \
    wc --max-line-length \
  )"

  dm_lib__debug "dm_lib__modules__get_width__version" \
    "modules versions max width is '${width}'"

  echo "$width"
}

#==============================================================================
# Returns the module status max width.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__MODULES__CACHE_FILE
# - DM__GLOBAL__MODULES__CACHE_SEPARATOR
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
# - Module status max width.
# StdErr
# - Error that occured during operation
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__modules__get_width__status() {
  dm_lib__debug "dm_lib__modules__get_width__status" \
    "getting width of the module statuses.."

  width="$( \
    cut \
      --delimiter="$DM__GLOBAL__MODULES__CACHE_SEPARATOR" \
      --field='4' \
      "$DM__GLOBAL__MODULES__CACHE_FILE" | \
    wc --max-line-length \
  )"

  dm_lib__debug "dm_lib__modules__get_width__status" \
    "modules statuses max width is '${width}'"

  echo "$width"
}


#==============================================================================
# Returns the relative path list for all recognized modules found in the
# given modules root directory. A module is recognized if it contains a dm
# configuration file.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__RUNTIME__MODULES_ROOT
# - DM__GLOBAL__CONFIG__CONFIG_FILE_NAME
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
# - Newline separated sorted list of modules relative path.
# StdErr
# - Error that occured during operation
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__modules__discover_modules() {
  dm_lib__debug "_dm_lib__modules__discover_modules" \
    "loading modules from '${DM__GLOBAL__RUNTIME__MODULES_ROOT}'"

  find "$DM__GLOBAL__RUNTIME__MODULES_ROOT" \
      -type f \
      -name "$DM__GLOBAL__CONFIG__CONFIG_FILE_NAME" | \
    sort | \
    xargs -I {} dirname "{}"
}

#==============================================================================
# Returns the relative path for the selected module. The index should be based
# on the shorted module path list produced by the `dm_lib__modules__list`
# function. The index starts from 1.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - index - module index started from 1.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Selected module
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error and the returned number is the max number of the index
#==============================================================================
dm_lib__modules__module_for_index() {
  selected_index="$1"

  dm_lib__debug "dm_lib__modules__module_for_index" \
    "getting module for index '${selected_index}'"

  modules="$(dm_lib__modules__list)"

  if module="$(_dm_lib__utils__line_by_index "$selected_index" "$modules")"
  then
    :
  else
    dm_lib__debug \
      "dm_lib__modules__module_for_index" \
      "received index '${selected_index}' is invalid, aborting.."
    return 1
  fi

  dm_lib__debug \
    "dm_lib__modules__module_for_index" \
    "returning module: ${module}"

  echo "$module"
}

#==============================================================================
# Private function that collects all modules and its basic properties and
# prints out to the standard output.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__MODULES__CACHE_SEPARATOR
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
_dm_lib__modules__collect_modules() {
  dm_lib__debug \
    "_dm_lib__modules__collect_modules" \
    "collecting modules.."

  modules="$(_dm_lib__modules__discover_modules)"
  for module in $modules
  do

    name="$(dm_lib__config__get_name "$module")"
    version="$(dm_lib__config__get_version "$module")"
    status="deployed"
    path="$module"

    sep="$DM__GLOBAL__MODULES__CACHE_SEPARATOR"

    echo "${path}${sep}${name}${sep}${version}${sep}${status}"
  done
}
