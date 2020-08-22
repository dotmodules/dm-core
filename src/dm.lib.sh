# shellcheck shell=sh
#==============================================================================
#       _             _ _ _          _
#      | |           | (_) |        | |
#    __| |_ __ ___   | |_| |__   ___| |__
#   / _` | '_ ` _ \  | | | '_ \ / __| '_ \
#  | (_| | | | | | |_| | | |_) |\__ \ | | |
#   \__,_|_| |_| |_(_)_|_|_.__(_)___/_| |_|
#
#==============================================================================

#==============================================================================
# GLOBAL
#==============================================================================

# Name of the configuration file. This file will indicate that a directory is a
# dm module.
DM__GLOBAL__CONFIG__CONFIG_FILE_NAME="dm.conf"

# Cache directory to store data between runs
DM__GLOBAL__CONFIG__CACHE_DIR="../.dm.cache"

# File to store the variables collected on startup. It will be cleared before
# each run.
DM__GLOBAL__CONFIG__CACHE__VARIABLES_FILE="${DM__GLOBAL__CONFIG__CACHE_DIR}/dm.variables"

# Temporary file that only used on initialization. It will be deleted right
# after usage.
DM__GLOBAL__CONFIG__TEMP__VARIABLES_FILE="${DM__GLOBAL__CONFIG__CACHE_DIR}/dm.variables.tmp"

# Hook that should run before the whole deploy process.
DM__GLOBAL__CONFIG__HOOK__PRE_DEPLOY="PRE_DEPLOY"

# Hook that should run after the whole deploy process.
DM__GLOBAL__CONFIG__HOOK__POST_DEPLOY="POST_DEPLOY"


DM__GLOBAL__CONFIG__LINK__NOT_EXISTS="0"
DM__GLOBAL__CONFIG__LINK__EXISTS_BUT_TARGET_MISMATCH="1"
DM__GLOBAL__CONFIG__LINK__EXISTS_WITH_TARGET="2"


#==============================================================================
# RUNTIME
#==============================================================================

# The following variables are expected to be set by the main script that uses
# this library. The values are depend on the actual deployment configuration,
# so they cannot be static like the other global variables.

# Global  debug enabled flag. Debug will be enabled if the value is 1.
DM__GLOBAL__RUNTIME__DEBUG_ENABLED="0"

# Relative path to the modules root.
DM__GLOBAL__RUNTIME__MODULES_ROOT="__INVALID__"


#==============================================================================
# LOG INTERFACE API
#==============================================================================

dm_lib__log() {
  echo "${RED}${BOLD}Interface incomplete: dm_lib__log not implemented!${RESET}"
  exit 1
}

dm_lib__log_verbose() {
  echo "${RED}${BOLD}Interface incomplete: dm_lib__log_verbose not implemented!${RESET}"
  exit 1
}


#==============================================================================
# COLOR AND PRINTOUT
#==============================================================================

# Ignoring the not used shellcheck errors as these variables are good to have
# during additional development.
if command -v tput > /dev/null
then
  # shellcheck disable=SC2034
  RED="$(tput setaf 1)"
  # shellcheck disable=SC2034
  RED_BG="$(tput setab 1)"
  # shellcheck disable=SC2034
  GREEN="$(tput setaf 2)"
  # shellcheck disable=SC2034
  YELLOW="$(tput setaf 3)"
  # shellcheck disable=SC2034
  BLUE="$(tput setaf 4)"
  # shellcheck disable=SC2034
  MAGENTA="$(tput setaf 5)"
  # shellcheck disable=SC2034
  CYAN="$(tput setaf 6)"
  # shellcheck disable=SC2034
  RESET="$(tput sgr0)"
  # shellcheck disable=SC2034
  BOLD="$(tput bold)"
  # shellcheck disable=SC2034
  DIM="$(tput dim)"
else
  # shellcheck disable=SC2034
  RED=""
  # shellcheck disable=SC2034
  RED_BG=""
  # shellcheck disable=SC2034
  GREEN=""
  # shellcheck disable=SC2034
  YELLOW=""
  # shellcheck disable=SC2034
  BLUE=""
  # shellcheck disable=SC2034
  MAGENTA=""
  # shellcheck disable=SC2034
  CYAN=""
  # shellcheck disable=SC2034
  RESET=""
  # shellcheck disable=SC2034
  BOLD=""
  # shellcheck disable=SC2034
  DIM=""
fi


#==============================================================================
# DEBUGGING FUNCTIONALITY
#==============================================================================

#============================================================================
# Prints out the given message to standard error if debug mode is enabled.
#============================================================================
dm_lib__debug() {
  if [ "$DM__GLOBAL__RUNTIME__DEBUG_ENABLED" = "1" ]
  then
    domain="$1"
    message="$2"
    printf "${DIM}$(date +"%F %T.%N") | %42s | %s${RESET}\n" "$domain" "$message"
  fi
} >&2

#============================================================================
# Prints out a given newline separated list to the debug output in a
# formatted line-by-line way if debug mode is enabled.
#============================================================================
dm_lib__debug_list() {
  if [ "$DM__GLOBAL__RUNTIME__DEBUG_ENABLED" = "1" ]
  then
    domain="$1"
    message="$2"
    list="$3"

    dm_lib__debug "$domain" "$message"

    echo "$list" | while read -r item
    do
      dm_lib__debug "$domain" "- '${item}'"
    done
  fi
} >&2


#==============================================================================
# EXTERNAL PARAMETER PARSING
#==============================================================================

dm_lib__config__load_parameter() {
  index="$1"
  default_value="$2"
  file_path="$3"

  dm_lib__debug "dm_lib__config__load_parameter" \
    "loading external parameter with index '${index}'.."

  if [ -f "$file_path" ]
  then
    value="$(grep -E "^${index}\s" "$file_path" 2>/dev/null || true)"
    if [ -n "$value" ]
    then
      value="${value#* }"
      dm_lib__debug "dm_lib__config__load_parameter" \
        "parameter loaded with value '${value}'"
      echo "$value"
    else
      dm_lib__debug "dm_lib__config__load_parameter" \
        "error during parameter retrival, fallback to default value '${default_value}'"
      echo "$default_value"
    fi
  else
    dm_lib__debug "dm_lib__config__load_parameter" \
      "parameter file not found: '${file_path}'!"
    dm_lib__debug "dm_lib__config__load_parameter" \
      "fallback to default value '${default_value}'"
    echo "$default_value"
  fi
}


#==============================================================================
# SUBMODULE: CACHE
#==============================================================================

dm_lib__cache__init() {
  mkdir -p "$DM__GLOBAL__CONFIG__CACHE_DIR"
}


#==============================================================================
# SUBMODULE: MODULES
#==============================================================================

#============================================================================
# Returns the relative path list for all recognized modules found in the
# given modules root directory. A module is recognized if it contains a dm
# configuration file.
#============================================================================
# INPUT
#============================================================================
# Global variables
# - DM__GLOBAL__CONFIG__CONFIG_FILE_NAME
# - DM__GLOBAL__RUNTIME__MODULES_ROOT
#
# Arguments
# - None
#
# StdIn
# - None
#
#============================================================================
# OUTPUT
#============================================================================
# Output variables
# - None
#
# StdOut
# - Newline separated sorted list of modules
#
# StdErr
# - Error that occured during operation
#
# Status
# -  0 : ok
# - !0 : error
#============================================================================
dm_lib__modules__list() {
  dm_lib__debug "dm_lib__modules_list" \
    "loading modules from '${DM__GLOBAL__RUNTIME__MODULES_ROOT}'"

  modules="$(\
    find "$DM__GLOBAL__RUNTIME__MODULES_ROOT"\
      -type f\
      -name "$DM__GLOBAL__CONFIG__CONFIG_FILE_NAME" | sort\
  )"

  for module in $modules; do
    dirname "$module"
  done
  return 0
}

#============================================================================
# Returns the relative path for the selected module. The index should be based
# on the shorted module path list produced by the `dm_lib__modules__list`
# function. The index starts from 1.
#============================================================================
# INPUT
#============================================================================
# Global variables
# - None
#
# Arguments
# - index - module index started from 1.
#
# StdIn
# - None
#
#============================================================================
# OUTPUT
#============================================================================
# Output variables
# - None
#
# StdOut
# - Relative path of the indexed module.
#
# StdErr
# - None
#
# Status
# -  0 : ok
# - !0 : error and the returned number is the max number of the index
#============================================================================
dm_lib__modules__module_by_index() {
  selected_index="$1"

  dm_lib__debug "dm_lib__modules__module_by_index" \
    "getting module for index '${selected_index}'"

  modules=$(dm_lib__modules__list)

  module_count="$(echo "$modules" | wc -l)"
  dm_lib__debug \
    "dm_lib__modules__module_by_index" \
    "module count: ${module_count}"

  case "$selected_index" in
      ''|*[!0-9]*)
        dm_lib__debug \
          "dm_lib__modules__module_by_index" \
          "given index '${selected_index}' is not a number, aborting.."
        return 1
        ;;
      *) ;;
  esac

  if [ "$selected_index" -le "0" ] || [ "$selected_index" -gt "$module_count" ]
  then
    dm_lib__debug \
      "dm_lib__modules__module_by_index" \
      "index is out of range, aborting.."
    return 1
  else
    dm_lib__debug \
      "dm_lib__modules__module_by_index" \
      "index '${index}' is valid"
  fi
  module="$( \
    echo "$modules" | \
      _dm_lib__utils__select_line "$selected_index" \
  )"

  dm_lib__debug \
    "dm_lib__modules__module_by_index" \
    "returning module: ${module}"

  echo "$module"
}


#==============================================================================
# SUBMODULE: CONFIG FILE
#==============================================================================

#============================================================================
# Parses the module name from the config file.
#============================================================================
# INPUT
#============================================================================
# Global variables
# - None
#
# Arguments
# - 1: Module path - this is the path to the module the name should be
#      loaded from.
#
# StdIn
# - None
#
#============================================================================
# OUTPUT
#============================================================================
# Output variables
# - None
#
# StdOut
# - Name of the module in a single line.
#
# StdErr
# - Error that occured during operation.
#
# Status
# -  0 : ok
# - !0 : error
#============================================================================
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

#============================================================================
# Parses the module version from the config file.
#============================================================================
# INPUT
#============================================================================
# Global variables
# - None
#
# Arguments
# - 1: Module path - this is the path to the module the version should be
#      loaded from.
#
# StdIn
# - None
#
#============================================================================
# OUTPUT
#============================================================================
# Output variables
# - None
#
# StdOut
# - Version of the module in a single line.
#
# StdErr
# - Error that occured during operation.
#
# Status
# -  0 : ok
# - !0 : error
#============================================================================
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

#============================================================================
# Parses the module documentation from the config file.
#============================================================================
# INPUT
#============================================================================
# Global variables
# - None
#
# Arguments
# - 1: Module path - this is the path to the module the docs should be
#      loaded from.
#
# StdIn
# - None
#
#============================================================================
# OUTPUT
#============================================================================
# Output variables
# - None
#
# StdOut
# - Module documentation optionally in multiple lines.
#
# StdErr
# - Error that occured during operation.
#
# Status
# -  0 : ok
# - !0 : error
#============================================================================
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

#============================================================================
# Removes the leading pipe character from the lines. This can be used to have a
# way to preserve indentation for the docs section.
#============================================================================
# INPUT
#============================================================================
# Global variables
# - None
#
# Arguments
# - None
#
# StdIn
# - Lines that potentially contains the pipe character.
#
#============================================================================
# OUTPUT
#============================================================================
# Output variables
# - None
#
# StdOut
# - Lines without the leading pipe prefix.
#
# StdErr
# - Error that occured during operation.
#
# Status
# -  0 : ok
# - !0 : error
#============================================================================
_dm_lib__config__remove_leading_pipe() {
  cat - | sed -E "s/^\|//"
}

#============================================================================
# Parses the module registered variables from the config file.
#============================================================================
# INPUT
#============================================================================
# Global variables
# - None
#
# Arguments
# - 1: Module path - this is the path to the module the variables should be
#      loaded from.
#
# StdIn
# - None
#
#============================================================================
# OUTPUT
#============================================================================
# Output variables
# - None
#
# StdOut
# - One variable definition per line.
#
# StdErr
# - Error that occured during operation.
#
# Status
# -  0 : ok
# - !0 : error
#============================================================================
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

#============================================================================
# Parses the module registered links from the config file.
#============================================================================
# INPUT
#============================================================================
# Global variables
# - None
#
# Arguments
# - 1: Module path - this is the path to the module the links should be
#      loaded from.
#
# StdIn
# - None
#
#============================================================================
# OUTPUT
#============================================================================
# Output variables
# - None
#
# StdOut
# - One link definition per line.
#
# StdErr
# - Error that occured during operation.
#
# Status
# -  0 : ok
# - !0 : error
#============================================================================
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

#============================================================================
# Parses the module registered hooks from the config file.
#============================================================================
# INPUT
#============================================================================
# Global variables
# - None
#
# Arguments
# - 1: Module path - this is the path to the module the hooks should be
#      loaded from.
#
# StdIn
# - None
#
#============================================================================
# OUTPUT
#============================================================================
# Output variables
# - None
#
# StdOut
# - One hook definition per line.
#
# StdErr
# - Error that occured during operation.
#
# Status
# -  0 : ok
# - !0 : error
#============================================================================
dm_lib__config__get_hooks() {
  module_path="$1"

  prefix="HOOK"

  dm_lib__debug "dm_lib__config__get_hooks" \
    "parsing hooks for prefix '${prefix}' from module '${module_path}'.."

  hooks="$( \
    _dm_lib__config__get_prefixed_lines_from_config_file "$module_path" "$prefix" | \
      _dm_lib__config__parse_as_list
  )"

  dm_lib__debug_list "dm_lib__config__get_hooks" \
    "hooks parsed:" "$hooks"

  echo "$hooks"
}

#============================================================================
# Returns a list of scripts that configured to be run during a selected hook.
#============================================================================
# INPUT
#============================================================================
# Global variables
# - None
#
# Arguments
# - 1: Module path - this is the path to the module the hooks should be
#      loaded from.
# - 2: Hook name - the hook we are searching for.
#
# StdIn
# - None
#
#============================================================================
# OUTPUT
#============================================================================
# Output variables
# - None
#
# StdOut
# - Script name per line.
#
# StdErr
# - Error that occured during operation.
#
# Status
# -  0 : ok
# - !0 : error
#============================================================================
dm_lib__config__get_scripts_for_hook() {
  module_path="$1"
  hook="$2"

  dm_lib__debug "dm_lib__config__get_scripts_for_hook" \
    "getting scripts for hook '${hook}' from module '${module_path}'.."

  dm_lib__config__get_hooks "$module"| \
    grep "$hook" | \
    _dm_lib__utils__trim_list "2"
}

#============================================================================
# Assembles the config file path given the module's root path.
#============================================================================
# INPUT
#============================================================================
# Global variables
# - DM__GLOBAL__CONFIG__CONFIG_FILE_NAME
#
# Arguments
# - 1: Module path - this is the path to the module.
#
# StdIn
# - None
#
#============================================================================
# OUTPUT
#============================================================================
# Output variables
# - None
#
# StdOut
# - The path to the config file.
#
# StdErr
# - Error that occured during operation.
#
# Status
# -  0 : ok
# - !0 : error
#============================================================================
_dm_lib__config__get_config_file_path() {
  module_path="$1"
  config_file="${module_path}/${DM__GLOBAL__CONFIG__CONFIG_FILE_NAME}"
  echo "$config_file"
}

#============================================================================
# Reads the config file and returns the related lines based on the given
# prefix.
#============================================================================
# INPUT
#============================================================================
# Global variables
# - None
#
# Arguments
# - 1: Config file path.
# - 2: Prefix - this is used for related line identification.
#
# StdIn
# - None
#
#============================================================================
# OUTPUT
#============================================================================
# Output variables
# - None
#
# StdOut
# - Matched related lines based on the prefix.
#
# StdErr
# - Error that occured during operation.
#
# Status
# -  0 : ok
# - !0 : error
#============================================================================
_dm_lib__config__get_lines_for_prefix() {
  config_file="$1"
  prefix="$2"
  grep --color=never --regexp="^\s*$prefix" "$config_file"
}

#============================================================================
# Removes the prefix part from the given line.
#============================================================================
# INPUT
#============================================================================
# Global variables
# - None
#
# Arguments
# - 1: Prefix - the prefix that should be removed from the given input lines.
#
# StdIn
# - Lines that should be cleaned from the prefix part.
#
#============================================================================
# OUTPUT
#============================================================================
# Output variables
# - None
#
# StdOut
# - Cleaned lines.
#
# StdErr
# - Error that occured during operation.
#
# Status
# -  0 : ok
# - !0 : error
#============================================================================
_dm_lib__config__remove_prefix_from_lines() {
  prefix="$1"
  cat - | sed -E "s/\s*${prefix}\s+//"
}

#============================================================================
# Helper function that reads the related config lines and removes it's prefix
# parts.
#============================================================================
# INPUT
#============================================================================
# Global variables
# - None
#
# Arguments
# - 1: Module path.
# - 2: Prefix - this is used for related line identification.
#
# StdIn
# - None
#
#============================================================================
# OUTPUT
#============================================================================
# Output variables
# - None
#
# StdOut
# - Matched and prefix-stripped related lines based on the prefix.
#
# StdErr
# - Error that occured during operation.
#
# Status
# -  0 : ok
# - !0 : error
#============================================================================
_dm_lib__config__get_prefixed_lines_from_config_file() {
  module_path="$1"
  prefix="$2"

  config_file="$(_dm_lib__config__get_config_file_path "$module_path")"

  _dm_lib__config__get_lines_for_prefix "$config_file" "$prefix" | \
    _dm_lib__config__remove_prefix_from_lines "$prefix"
}

#============================================================================
# Function that will parse the given lines as a list by removing all
# unecessary whitespace.
#============================================================================
# INPUT
#============================================================================
# Global variables
# - None
#
# Arguments
# - None
#
# StdIn
# - Lines that needs to be parsed.
#
#============================================================================
# OUTPUT
#============================================================================
# Output variables
# - None
#
# StdOut
# - Parsed lines.
#
# StdErr
# - Error that occured during operation.
#
# Status
# -  0 : ok
# - !0 : error
#============================================================================
_dm_lib__config__parse_as_list() {
  cat - | _dm_lib__utils__parse_list
}

#============================================================================
# Function that will parse the given lines as text lines keepeing every inner
# whitespace while stripping the surrounding whitespace.
#============================================================================
# INPUT
#============================================================================
# Global variables
# - None
#
# Arguments
# - None
#
# StdIn
# - Lines that needs to be parsed.
#
#============================================================================
# OUTPUT
#============================================================================
# Output variables
# - None
#
# StdOut
# - Parsed lines.
#
# StdErr
# - Error that occured during operation.
#
# Status
# -  0 : ok
# - !0 : error
#============================================================================
_dm_lib__config__parse_as_line() {
  cat - | _dm_lib__utils__remove_surrounding_whitespace
}


#==============================================================================
# UTILS
#==============================================================================

#============================================================================
# Function that squeezes every whitespace in the given lines.
#============================================================================
# INPUT
#============================================================================
# Global variables
# - None
#
# Arguments
# - None
#
# StdIn
# - Lines that needs to be parsed.
#
#============================================================================
# OUTPUT
#============================================================================
# Output variables
# - None
#
# StdOut
# - Parsed lines.
#
# StdErr
# - Error that occured during operation.
#
# Status
# -  0 : ok
# - !0 : error
#============================================================================
_dm_lib__utils__normalize_whitespace() {
  cat - | tr --squeeze-repeats '[:space:]'
}

#============================================================================
# Function that removes the surrounding whitespace from the given lines.
#============================================================================
# INPUT
#============================================================================
# Global variables
# - None
#
# Arguments
# - None
#
# StdIn
# - Lines that needs to be parsed.
#
#============================================================================
# OUTPUT
#============================================================================
# Output variables
# - None
#
# StdOut
# - Parsed lines.
#
# StdErr
# - Error that occured during operation.
#
# Status
# -  0 : ok
# - !0 : error
#============================================================================
_dm_lib__utils__remove_surrounding_whitespace() {
  cat - | \
    sed -E 's/^\s*//' | \
    sed -E 's/\s*$//'
}

#============================================================================
# Function that performs a list trimmig based on the given position string in
# every given line..
#============================================================================
# INPUT
#============================================================================
# Global variables
# - None
#
# Arguments
# - 1: Items - Position string that has to be compatible with the `cut`
#      command's `--fields` argument values.
#
# StdIn
# - Lines that needs to be trimmed.
#
#============================================================================
# OUTPUT
#============================================================================
# Output variables
# - None
#
# StdOut
# - Trimmed lines.
#
# StdErr
# - Error that occured during operation.
#
# Status
# -  0 : ok
# - !0 : error
#============================================================================
_dm_lib__utils__trim_list() {
  items="$1"
  cat - |\
    _dm_lib__utils__normalize_whitespace | \
    cut --delimiter=' ' --fields="${items}"
}

#============================================================================
# Function that selects an indexed line from the given lines.
#============================================================================
# INPUT
#============================================================================
# Global variables
# - None
#
# Arguments
# - 1: Line - Line index that should only be returned.
#
# StdIn
# - Lines that needs to be trimmed.
#
#============================================================================
# OUTPUT
#============================================================================
# Output variables
# - None
#
# StdOut
# - the selected line.
#
# StdErr
# - Error that occured during operation.
#
# Status
# -  0 : ok
# - !0 : error
#============================================================================
_dm_lib__utils__select_line() {
  line="$1"
  cat - | sed "${line}q;d"
}

#============================================================================
# Function that will parse the given lines as a list by removing all
# unecessary whitespace.
#============================================================================
# INPUT
#============================================================================
# Global variables
# - None
#
# Arguments
# - None
#
# StdIn
# - Lines that needs to be parsed.
#
#============================================================================
# OUTPUT
#============================================================================
# Output variables
# - None
#
# StdOut
# - Parsed lines.
#
# StdErr
# - Error that occured during operation.
#
# Status
# -  0 : ok
# - !0 : error
#============================================================================
_dm_lib__utils__parse_list() {
  cat - | \
    _dm_lib__utils__normalize_whitespace | \
    _dm_lib__utils__remove_surrounding_whitespace
}


#==============================================================================
# SUBMODULE: VARIABLES
#==============================================================================

dm_lib__variables__load() {
  dm_lib__debug "dm_lib__variables__load" \
    "loading variables from the modules.."

  _dm_lib__variables__init

  _dm_lib__variables__get_variables_from_modules > \
    "$DM__GLOBAL__CONFIG__TEMP__VARIABLES_FILE"
  _dm_lib__variables__merge
  rm -f "$DM__GLOBAL__CONFIG__TEMP__VARIABLES_FILE"

  # Most minimalistic way to have control over the formatting. During testing
  # it has to be run synchronously, but live it can be run in the background to
  # achieve faster loading times.
  if [ "$#" = "0" ]
  then
    dm_lib__debug "dm_lib__variables__load" "about to run formatting synchronously"
    _dm_lib__variables__prettify
  else
    dm_lib__debug "dm_lib__variables__load" "about to run formatting in the background.."
    _dm_lib__variables__prettify &
  fi

  dm_lib__debug "dm_lib__variables__load" "variables loaded"
}


dm_lib__variables__get() {
  variable="$1"
  grep -E "^${variable}" "$DM__GLOBAL__CONFIG__CACHE__VARIABLES_FILE" | \
    _dm_lib__utils__trim_list "2-"
}

_dm_lib__variables__init() {
  rm -f "$DM__GLOBAL__CONFIG__CACHE__VARIABLES_FILE"
  touch "$DM__GLOBAL__CONFIG__CACHE__VARIABLES_FILE"
  dm_lib__debug "_dm_lib__variables__init" \
    "variable cache file initialized"
}

_dm_lib__variables__get_variables_from_modules() {
  modules="$(dm_lib__modules__list)"
  for module in $modules
  do
    dm_lib__config__get_variables "$module"
  done
}

_dm_lib__variables__merge() {
  while read -r variable
  do
    variable_name="${variable%% *}"  # getting the first element from the list
    values="${variable#* }"  # getting all items but the first
    dm_lib__debug "_dm_lib__variables__merge" \
      "processing variable '${variable_name}' with values '${values}'"

    existing_variable="$( \
      grep -E "^${variable_name}\s" "$DM__GLOBAL__CONFIG__CACHE__VARIABLES_FILE" || true \
    )"
    if [ -n "$existing_variable" ]
    then
      dm_lib__debug "_dm_lib__variables__merge" \
        "existing variable found: '$existing_variable'"

      existing_values="${existing_variable#* }"  # getting all items but the first
      updated_variable="${variable_name} ${existing_values} ${values}"

      dm_lib__debug "_dm_lib__variables__merge" \
        "updating variable '${variable_name}' in cache"
      sed -i "s%^${variable_name}.*$%${updated_variable}%" \
        "$DM__GLOBAL__CONFIG__CACHE__VARIABLES_FILE"
    else
      dm_lib__debug "_dm_lib__variables__merge" \
        "variable '${variable_name}' was not found in the cache, writing it directly"
      echo "${variable_name} ${values}" >> "$DM__GLOBAL__CONFIG__CACHE__VARIABLES_FILE"
    fi
  done < "$DM__GLOBAL__CONFIG__TEMP__VARIABLES_FILE"

  dm_lib__debug "_dm_lib__variables__merge" "variables merged"
}

_dm_lib__variables__prettify() {
  sort -o "$DM__GLOBAL__CONFIG__CACHE__VARIABLES_FILE" \
    "$DM__GLOBAL__CONFIG__CACHE__VARIABLES_FILE"

  # Copying the file to the temp file to be able to iterate over the lines
  # without having to worry about modifying them inplace.
  cp "$DM__GLOBAL__CONFIG__CACHE__VARIABLES_FILE" \
    "$DM__GLOBAL__CONFIG__TEMP__VARIABLES_FILE"

  index=1
  while read -r line
  do
    variable_name="${line%% *}"  # getting the first element from the list
    values="${line#* }"  # getting all items but the first
    sorted_values="$(echo "$values" | xargs -n1 | sort | uniq | xargs)"
    sed -i "${index}s;.*;${variable_name} ${sorted_values};" \
      "$DM__GLOBAL__CONFIG__CACHE__VARIABLES_FILE"
    index=$((index + 1))
  done < "$DM__GLOBAL__CONFIG__TEMP__VARIABLES_FILE"
  rm -f "$DM__GLOBAL__CONFIG__TEMP__VARIABLES_FILE"
}

#==============================================================================
# SUBMODULE: LINKS
#==============================================================================

#============================================================================
# Expand path received from the config files as a string. The rationale behind
# this expansion is to not to use the `eval` function. It is based on a string
# replacement. It only expands the `$HOME` variable and the `~` tilde
# character, so it behaves as the shell in these cases.
#============================================================================
# INPUT
#============================================================================
# Global variables
# - None
#
# Arguments
# - 1: string path to be expanded.
#
# StdIn
# - None
#
#============================================================================
# OUTPUT
#============================================================================
# Output variables
# - None
#
# StdOut
# - Expanded path.
#
# StdErr
# - Error that occured during operation.
#
# Status
# -  0 : ok
# - !0 : error
#============================================================================
_dm_lib__links__expand_path() {
  raw_path="$1"
  home="$HOME"

  dm_lib__debug "_dm_lib__links__expand_path" \
    "expanding raw_path '${raw_path}'"

  # Here we are replacing the existing `$HOME` and `~` strings instead of using
  # eval to do the same (and potentioally many other things..). This restricts
  # the expansion for only these two instances in exchange of security.
  path="$(echo "$raw_path" | \
    sed -e "s#^\$HOME#${home}#" | \
    sed -e "s#^~#${home}#" \
  )"

  dm_lib__debug "_dm_lib__links__expand_path" \
    "path expanded to '${path}'"

  echo "$path"
}

#============================================================================
# Returns the target path of a symbolic link.
#============================================================================
# INPUT
#============================================================================
# Global variables
# - None
#
# Arguments
# - 1: link_name - path to the link thats target should be resolved
#
# StdIn
# - None
#
#============================================================================
# OUTPUT
#============================================================================
# Output variables
# - None
#
# StdOut
# - the resolved target path of the link
#
# StdErr
# - Error that occured during operation.
#
# Status
# -  0 : ok
# - !0 : error
#============================================================================
_dm_lib__links__get_link_target_path() {
  link_name="$1"

  dm_lib__debug "_dm_lib__links__get_link_target_path" \
    "getting target path for link '${link_name}'"

  result="$(ls -l "$link_name")"
  target_path="${result##* }"

  dm_lib__debug "_dm_lib__links__get_link_target_path" \
    "resolved target path:'${target_path}'"

  echo "$target_path"
}

#============================================================================
# Tests if the given link exists and it's target is the same as the given
# target. The parameter order is the same as for the `ln` command.
#============================================================================
# INPUT
#============================================================================
# Global variables
# - DM__GLOBAL__CONFIG__LINK__NOT_EXISTS
# - DM__GLOBAL__CONFIG__LINK__EXISTS_BUT_TARGET_MISMATCH
# - DM__GLOBAL__CONFIG__LINK__EXISTS_WITH_TARGET
#
# Arguments
# - 1: target_path - the path the link should point to
# - 2: link_name - the path where the link should be
#
# StdIn
# - None
#
#============================================================================
# OUTPUT
#============================================================================
# Output variables
# - None
#
# StdOut
# - DM__GLOBAL__CONFIG__LINK__EXISTS_WITH_TARGET - the link is in place and
#   points to the given path
# - DM__GLOBAL__CONFIG__LINK__EXISTS_BUT_TARGET_MISMATCH - the link is in place
#   but it points to a different path
# - DM__GLOBAL__CONFIG__LINK__NOT_EXISTS - the link isn't exist
#
# StdErr
# - Error that occured during operation.
#
# Status
# -  0 : ok
# - !0 : error
#============================================================================
_dm_lib__links__check_link() {
  target_path="$1"
  link_name="$2"

  dm_lib__debug "_dm_lib__links__check_link" \
    "checking target_path '${target_path}' and link_name '${link_name}'"

  target_path="$(readlink -f "$target_path")"

  if [ -L "$link_name" ]
  then
    link_target="$(_dm_lib__links__get_link_target_path "$link_name")"

    if [ "$target_path" = "$link_target" ]
    then
      dm_lib__debug "_dm_lib__links__check_link" "link exists and target matched"
      echo "$DM__GLOBAL__CONFIG__LINK__EXISTS_WITH_TARGET"
    else
      dm_lib__debug "_dm_lib__links__check_link" "link exists but target mismatched"
      echo "$DM__GLOBAL__CONFIG__LINK__EXISTS_BUT_TARGET_MISMATCH"
    fi
  else
    dm_lib__debug "_dm_lib__links__check_link" "link does not exist"
    echo "$DM__GLOBAL__CONFIG__LINK__NOT_EXISTS"
  fi
}

#============================================================================
# Preprocesses the raw link data received from the configuration files. It is
# received as a module relative script name and an absolute path the link
# should be put.
#============================================================================
# INPUT
#============================================================================
# Global variables
# - None
#
# Arguments
# - 1: module_path - relative module path
# - 2: raw link string - this is a space separated module relative path and an
#      absolute link path where the link should be created.
#
# StdIn
# - None
#
#============================================================================
# OUTPUT
#============================================================================
# Output variables
# - None
#
# StdOut
# - target path and link path separated by space.
#
# StdErr
# - None
#
# Status
# -  0 : ok
# - !0 : error
#============================================================================
_dm_lib__links__preprocess_raw_link_string() {
  module="$1"
  link_string="$2"

  target_file="${link_string%% *}"  # getting the first element from the list
  link_name="${link_string#* }"  # getting all items but the first

  # making sure the script is relative to the module
  target_path="${module}/${target_file}"

  target_path="$(readlink -f "$target_path")"
  link_name="$(_dm_lib__links__expand_path "$link_name")"

  echo "${target_path} ${link_name}"
}

#==============================================================================
# SUBMODULE: DEPLOY
#==============================================================================

#============================================================================
# Full deploy of a single module.
#============================================================================
# INPUT
#============================================================================
# Global variables
# - None
#
# Arguments
# - module_path - relative module path
#
# StdIn
# - None
#
#============================================================================
# OUTPUT
#============================================================================
# Output variables
# - None
#
# StdOut
# - None
#
# StdErr
# - None
#
# Status
# -  0 : ok
# - !0 : error
#============================================================================
dm_lib__deploy__deploy_module() {
  module="$1"
  dm_lib__debug "dm_lib__deploy__deploy_module" "deploying module '${module}'"

  dm_lib__debug "dm_lib__deploy__deploy_module" "-------------------------"
  dm_lib__debug "dm_lib__deploy__deploy_module" "PHASE 01: PRE_DEPLOY HOOK"
  _dm_lib__deploy__run_hook "$module" "$DM__GLOBAL__CONFIG__HOOK__PRE_DEPLOY"

  dm_lib__debug "dm_lib__deploy__deploy_module" "-------------------------"
  dm_lib__debug "dm_lib__deploy__deploy_module" "PHASE 02: LINKING FILES"
  _dm_lib__deploy__link_files "$module" | \
    sed -e "s#^#${DIM}LINKING${RESET} #g"

  dm_lib__debug "dm_lib__deploy__deploy_module" "-------------------------"
  dm_lib__debug "dm_lib__deploy__deploy_module" "PHASE 03: POST_DEPLOY HOOK"
  _dm_lib__deploy__run_hook "$module" "$DM__GLOBAL__CONFIG__HOOK__POST_DEPLOY"

  dm_lib__debug "dm_lib__deploy__deploy_module" "deploying module '${module}' finished"
}

_dm_lib__deploy__run_hook() {
  module="$1"
  hook="$2"

  dm_lib__debug "_dm_lib__deploy__run_hook" \
    "running hook '${hook}' in module '${module}'"

  dm_lib__config__get_scripts_for_hook "$module" "$hook" | while read -r script
  do
    script_path="${module}/${script}"
    dm_lib__debug "_dm_lib__deploy__run_hook" \
      "running script '${script_path}' for hook '${hook}'"
    echo "${DIM}${hook} running '${script_path}'"

    # Sourcing the hook script to be able to use the dm API. Shellcheck
    # shouldn't check this source, as it is dynamically executed user code.
    # shellcheck source=/dev/null
    . "$script_path" | sed -e "s#^#${DIM}${hook}${RESET} #g"

    dm_lib__debug "_dm_lib__deploy__run_hook" "hook found: '${hook}'"
  done
}


_dm_lib__deploy__link_files() {
  module="$1"

  dm_lib__debug "_dm_lib__deploy__link_files" \
    "linking files in module '${module}'"

  dm_lib__config__get_links "$module" | while read -r link_string
  do
    processed_link="$( \
      _dm_lib__links__preprocess_raw_link_string "$module" "$link_string" \
    )"
    target_path="${processed_link%% *}"  # getting the first element from the list
    link_name="${processed_link#* }"  # getting all items but the first

    dm_lib__debug "_dm_lib__deploy__link_files" \
      "linking: '${target_path}' -> '${link_name}'"

    result="$(_dm_lib__links__check_link "$target_path" "$link_name")"

    if [ "$result" = "$DM__GLOBAL__CONFIG__LINK__NOT_EXISTS" ]
    then
      :
    elif [ "$result" = "$DM__GLOBAL__CONFIG__LINK__EXISTS_BUT_TARGET_MISMATCH" ]
    then
      echo "link already exists but target path is different"
      return
    elif [ "$result" = "$DM__GLOBAL__CONFIG__LINK__EXISTS_WITH_TARGET" ]
    then
      echo "link already exists"
      return
    else
      :
    fi

    ln --symbolic --verbose "$target_path" "$link_name" 2>&1

  done
}
