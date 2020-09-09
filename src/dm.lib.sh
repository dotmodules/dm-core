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
# GLOBAL CONSTANT VARIABLES
#==============================================================================

# Name of the configuration file. This file will indicate that a directory is a
# dm module.
DM__GLOBAL__CONFIG__CONFIG_FILE_NAME="dm.conf"

# Cache directory to store data between runs
DM__GLOBAL__CONFIG__CACHE_DIR="../.dm.cache"


#==============================================================================
# MANDATORY RUNTIME VARIABLES
#==============================================================================
# The following variables are expected to be set by the main script that uses
# this library. The values are depend on the actual deployment configuration,
# so they cannot be static like the other global variables.

# Global  debug enabled flag. Debug will be enabled if the value is 1.
DM__GLOBAL__RUNTIME__DEBUG_ENABLED="__INVALID__"

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

#==============================================================================
# Prints out the given message to standard error if debug mode is enabled.
#==============================================================================
dm_lib__debug() {
  if [ "$DM__GLOBAL__RUNTIME__DEBUG_ENABLED" = "1" ]
  then
    domain="$1"
    message="$2"
    printf "${DIM}$(date +"%F %T.%N") | %48s | %s${RESET}\n" "$domain" "$message"
  fi
} >&2

#==============================================================================
# Prints out a given newline separated list to the debug output in a
# formatted line-by-line way if debug mode is enabled.
#==============================================================================
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

#==============================================================================
# Returns the relative path list for all recognized modules found in the
# given modules root directory. A module is recognized if it contains a dm
# configuration file.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__CONFIG__CONFIG_FILE_NAME
# - DM__GLOBAL__RUNTIME__MODULES_ROOT
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
# - Newline separated sorted list of modules
# StdErr
# - Error that occured during operation
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__modules__list() {
  dm_lib__debug "dm_lib__modules_list" \
    "loading modules from '${DM__GLOBAL__RUNTIME__MODULES_ROOT}'"

  modules="$( \
    find "$DM__GLOBAL__RUNTIME__MODULES_ROOT" \
      -type f \
      -name "$DM__GLOBAL__CONFIG__CONFIG_FILE_NAME" | sort \
  )"

  for module in $modules; do
    dirname "$module"
  done
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
# - Relative path of the indexed module.
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error and the returned number is the max number of the index
#==============================================================================
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
# SUBMODULE: CONFIG
#==============================================================================
#    _____             __ _
#   / ____|           / _(_)
#  | |     ___  _ __ | |_ _  __ _
#  | |    / _ \| '_ \|  _| |/ _` |
#  | |___| (_) | | | | | | | (_| |
#   \_____\___/|_| |_|_| |_|\__, |
#                            __/ |
#===========================|___/=============================================

#==============================================================================
# Parses the module name from the config file.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: Module path - this is the path to the module the name should be
#      loaded from.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Name of the module in a single line.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
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

#==============================================================================
# Parses the module version from the config file.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: Module path - this is the path to the module the version should be
#      loaded from.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Version of the module in a single line.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
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

#==============================================================================
# Parses the module documentation from the config file.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: Module path - this is the path to the module the docs should be
#      loaded from.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Module documentation optionally in multiple lines.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
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

#==============================================================================
# Removes the leading pipe character from the lines. This can be used to have a
# way to preserve indentation for the docs section.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - None
# StdIn
# - Lines that potentially contains the pipe character.
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Lines without the leading pipe prefix.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__config__remove_leading_pipe() {
  cat - | sed -E "s/^\|//"
}

#==============================================================================
# Parses the module registered variables from the config file.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: Module path - this is the path to the module the variables should be
#      loaded from.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - One variable definition per line.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
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

#==============================================================================
# Parses the module registered links from the config file.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: Module path - this is the path to the module the links should be
#      loaded from.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - One link definition per line.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
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

#==============================================================================
# Parses the module registered hooks from the config file.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: Module path - this is the path to the module the hooks should be
#      loaded from.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - One normalized hook definition per line.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__config__get_hooks() {
  module_path="$1"

  prefix="HOOK"

  dm_lib__debug "dm_lib__config__get_hooks" \
    "parsing hooks for prefix '${prefix}' from module '${module_path}'.."

  hooks="$( \
    _dm_lib__config__get_prefixed_lines_from_config_file "$module_path" "$prefix" | \
      _dm_lib__config__parse_as_list \
  )"

  dm_lib__debug_list "dm_lib__config__get_hooks" \
    "hooks parsed:" "$hooks"

  normalized_hooks="$( \
    echo "$hooks" | _dm_lib__config__hooks__normalize \
  )"

  dm_lib__debug_list "dm_lib__config__get_hooks" \
    "hooks normalized:" "$normalized_hooks"

  echo "$normalized_hooks"
}

#==============================================================================
# Main hook token normalization function. It's task is to limit the hook tokens
# to 3 and calling the appropriate sub normalization function based on the
# remained token count. If there is only one token remains, it will gets
# ignored.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - None
# StdIn
# - Hooks to be normalized. One hook per line.
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Normalized hooks per line.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__config__hooks__normalize() {
  dm_lib__debug \
    "_dm_lib__config__hooks__normalize" \
    "normalization started by limiting the tokens to max 3"

  cat - | _dm_lib__utils__trim_list "1-3" | while read -r hook
  do
    dm_lib__debug \
      "_dm_lib__config__hooks__normalize" \
      "normalizing hook '${hook}':"

    count="$(echo "$hook" | wc -w)"

    dm_lib__debug \
      "_dm_lib__config__hooks__normalize" \
      "- token count: ${count}"

    if [ "$count" -eq "3" ]
    then
      normalized_hook="$(_dm_lib__config__hooks__normalize_3_tokens "$hook")"
    elif [ "$count" -eq "2" ]
    then
      normalized_hook="$(_dm_lib__config__normalize_hooks__2_tokens "$hook")"
    else
      dm_lib__debug \
        "_dm_lib__config__hooks__normalize" \
        "- missing mandatory script path, ignoring hook!"
      continue
    fi

    dm_lib__debug \
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
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: hook tokens
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Normalized hook tokens.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__config__hooks__normalize_3_tokens() {
  hook="$1"

  if echo "$hook" | grep -q -P '^[^\s]+\s\d+\s[^\s]+$'
  then
    dm_lib__debug \
      "_dm_lib__config__hooks__normalize_3_tokens" \
      "- hook matches to the '<signal> <priotity> <path>' pattern, nothing to do"

    echo "$hook"

  else
    dm_lib__debug \
      "_dm_lib__config__hooks__normalize_3_tokens" \
      "- priority is not an integer in '<signal> <priotity> <path>' pattern"
    dm_lib__debug \
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
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: hook tokens
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Normalized hook tokens.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__config__normalize_hooks__2_tokens() {
  hook="$1"

  dm_lib__debug \
    "_dm_lib__config__normalize_hooks__2_tokens" \
    "- priority missing, inserting the default one"

  echo "$hook" | _dm_lib__config__hooks__insert_priority
}

#==============================================================================
# Inserts the default priority between the 1st and 2nd token.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - None
# StdIn
# - Token stream. It expects to got 2 tokens per line.
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Modified token stream.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__config__hooks__insert_priority() {
  dm_lib__debug \
    "_dm_lib__config__hooks__insert_priority" \
    "- inserting default priority"

  cat - | sed -E 's/^[^\s]+\s/&0 /'
}

#==============================================================================
# Returns a list of scripts that configured to be run during a selected hook.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: Module path - this is the path to the module the hooks should be
#      loaded from.
# - 2: Hook name - the hook we are searching for.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Script name per line.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__config__get_scripts_for_hook() {
  # ????????????????????????????????
  module_path="$1"
  hook="$2"

  dm_lib__debug "dm_lib__config__get_scripts_for_hook" \
    "getting scripts for hook '${hook}' from module '${module_path}'.."

  dm_lib__config__get_hooks "$module"| \
    grep "$hook" | \
    _dm_lib__utils__trim_list "2"
}

#==============================================================================
# Assembles the config file path given the module's root path.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__CONFIG__CONFIG_FILE_NAME
# Arguments
# - 1: Module path - this is the path to the module.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - The path to the config file.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__config__get_config_file_path() {
  module_path="$1"
  config_file="${module_path}/${DM__GLOBAL__CONFIG__CONFIG_FILE_NAME}"
  echo "$config_file"
}

#==============================================================================
# Reads the config file and returns the related lines based on the given
# prefix.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: Config file path.
# - 2: Prefix - this is used for related line identification.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Matched related lines based on the prefix.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__config__get_lines_for_prefix() {
  config_file="$1"
  prefix="$2"
  grep --color=never --regexp="^\s*$prefix" "$config_file"
}

#==============================================================================
# Removes the prefix part from the given line.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: Prefix - the prefix that should be removed from the given input lines.
# StdIn
# - Lines that should be cleaned from the prefix part.
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Cleaned lines.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__config__remove_prefix_from_lines() {
  prefix="$1"
  cat - | sed -E "s/\s*${prefix}\s+//"
}

#==============================================================================
# Helper function that reads the related config lines and removes it's prefix
# parts.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: Module path.
# - 2: Prefix - this is used for related line identification.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Matched and prefix-stripped related lines based on the prefix.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__config__get_prefixed_lines_from_config_file() {
  module_path="$1"
  prefix="$2"

  config_file="$(_dm_lib__config__get_config_file_path "$module_path")"

  _dm_lib__config__get_lines_for_prefix "$config_file" "$prefix" | \
    _dm_lib__config__remove_prefix_from_lines "$prefix"
}

#==============================================================================
# Function that will parse the given lines as a list by removing all
# unecessary whitespace.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - None
# StdIn
# - Lines that needs to be parsed.
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Parsed lines.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__config__parse_as_list() {
  cat - | _dm_lib__utils__parse_list
}

#==============================================================================
# Function that will parse the given lines as text lines keepeing every inner
# whitespace while stripping the surrounding whitespace.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - None
# StdIn
# - Lines that needs to be parsed.
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Parsed lines.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__config__parse_as_line() {
  cat - | _dm_lib__utils__remove_surrounding_whitespace
}

#==============================================================================
# SUBMODULE: UTILS
#==============================================================================
#   _    _ _   _ _
#  | |  | | | (_) |
#  | |  | | |_ _| |___
#  | |  | | __| | / __|
#  | |__| | |_| | \__ \
#   \____/ \__|_|_|___/
#
#==============================================================================

#==============================================================================
# Function that squeezes every whitespace in the given lines.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - None
# StdIn
# - Lines that needs to be parsed.
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Parsed lines.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__utils__normalize_whitespace() {
  cat - | tr --squeeze-repeats '[:space:]'
}

#==============================================================================
# Function that removes the surrounding whitespace from the given lines.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - None
# StdIn
# - Lines that needs to be parsed.
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Parsed lines.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__utils__remove_surrounding_whitespace() {
  cat - | \
    sed -E 's/^\s*//' | \
    sed -E 's/\s*$//'
}

#==============================================================================
# Function that performs a list trimmig based on the given position string in
# every given line..
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: Items - Position string that has to be compatible with the `cut`
#      command's `--fields` argument values.
# StdIn
# - Lines that needs to be trimmed.
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Trimmed lines.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__utils__trim_list() {
  items="$1"
  cat - |\
    _dm_lib__utils__normalize_whitespace | \
    cut --delimiter=' ' --fields="${items}"
}

#==============================================================================
# Function that selects an indexed line from the given lines.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: Line - Line index that should only be returned.
# StdIn
# - Lines that needs to be trimmed.
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - the selected line.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__utils__select_line() {
  line="$1"
  cat - | sed "${line}q;d"
}

#==============================================================================
# Function that will parse the given lines as a list by removing all
# unecessary whitespace.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - None
# StdIn
# - Lines that needs to be parsed.
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Parsed lines.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__utils__parse_list() {
  cat - | \
    _dm_lib__utils__normalize_whitespace | \
    _dm_lib__utils__remove_surrounding_whitespace
}


#==============================================================================
# SUBMODULE CACHE
#==============================================================================
#    _____           _
#   / ____|         | |
#  | |     __ _  ___| |__   ___
#  | |    / _` |/ __| '_ \ / _ \
#  | |___| (_| | (__| | | |  __/
#   \_____\__,_|\___|_| |_|\___|
#
#==============================================================================

#==============================================================================
# Function that initializes the cache directory after it cleaned it up.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__CONFIG__CACHE_DIR
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
# - Error that occured during operation
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__cache__init() {
  rm -rf "$DM__GLOBAL__CONFIG__CACHE_DIR"
  mkdir -p "$DM__GLOBAL__CONFIG__CACHE_DIR"

  _dm_lib__variables__init_variable_cache
}

#==============================================================================
# SUBMODULE VARIABLES
#==============================================================================
#  __      __        _       _     _
#  \ \    / /       (_)     | |   | |
#   \ \  / /_ _ _ __ _  __ _| |__ | | ___  ___
#    \ \/ / _` | '__| |/ _` | '_ \| |/ _ \/ __|
#     \  / (_| | |  | | (_| | |_) | |  __/\__ \
#      \/ \__,_|_|  |_|\__,_|_.__/|_|\___||___/
#
#==============================================================================

# Variables cache file to store the normalized variables collected from the
# modules. This file should be loaded on initialization and should have valid
# content through end of the dotmodules session.
DM__GLOBAL__VARIABLES__CACHE_FILE="${DM__GLOBAL__CONFIG__CACHE_DIR}/dm.variables"

# Temporary file used by the variables submodule for its inner function. It
# will be deleted after usage.
DM__GLOBAL__VARIABLES__TEMP_FILE="${DM__GLOBAL__CONFIG__CACHE_DIR}/dm.variables.tmp"

#==============================================================================
# API function to load all of the variables from the modules to the cache in a
# normalized way. After this function has finished, the cache will contain a
# variable file that will contain a variable and its corresponding values for
# every line.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__VARIABLES__TEMP_FILE
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
# - None.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__variables__load() {
  # Writing all variables per module into the temporary cache file in an
  # unordered way. There is no formatting applied to the list of variables.
  # There are unordered and ungrupped.
  _dm_lib__variables__collect_all_variables_from_modules > \
    "$DM__GLOBAL__VARIABLES__TEMP_FILE"

  # Merging the variables from the temp cache file to the variables cache file.
  # After this, the variables cache file will contain one unique variable per
  # line with all the values from the different modules.
  _dm_lib__variables__merge

  rm -f "$DM__GLOBAL__VARIABLES__TEMP_FILE"

  # Normalizing the variables line by line to have the values unique and sorted.
  _dm_lib__variables__normalize

  dm_lib__debug \
    "dm_lib__variables__load" \
    "variables loaded"
}

#==============================================================================
# API function to print all variables to the standard output.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__VARIABLES__CACHE_FILE
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
# - All variables and values line by line.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__variables__get_all() {
  cat "$DM__GLOBAL__VARIABLES__CACHE_FILE"
}

#==============================================================================
# API function to get the values for a given variable name. The values will be
# loaded from the normalized variable cache file.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__VARIABLES__CACHE_FILE
# Arguments
# - variable_name - The name of the selected variable.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Values for the given variable name as a space separated line.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__variables__get() {
  variable_name="$1"
  grep -E "^${variable_name}" "$DM__GLOBAL__VARIABLES__CACHE_FILE" | \
    _dm_lib__utils__trim_list "2-"
}

#==============================================================================
# API function to calculate the max variable name length.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__VARIABLES__CACHE_FILE
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
# - Max variable name length.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_lib__variables__get_max_variable_name_length() {
  cut --delimiter=' ' --fields='1' "$DM__GLOBAL__VARIABLES__CACHE_FILE" | \
  wc --max-line-length
}

#==============================================================================
# Private function to initialize the variables cache file. It deletes the old
# one if exists, then creates an empty file for the new cache.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__VARIABLES__CACHE_FILE
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
_dm_lib__variables__init_variable_cache() {
  rm --force "$DM__GLOBAL__VARIABLES__CACHE_FILE"
  touch "$DM__GLOBAL__VARIABLES__CACHE_FILE"

  dm_lib__debug \
    "_dm_lib__variables__init_variable_cache" \
    "variable cache file initialized"
}

#==============================================================================
# Private function that collects all the variables from the modules and prints
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
_dm_lib__variables__collect_all_variables_from_modules() {
  dm_lib__debug \
    "_dm_lib__variables__collect_all_variables_from_modules" \
    "collecting variables from modules.."

  modules="$(dm_lib__modules__list)"
  for module in $modules
  do
    dm_lib__config__get_variables "$module"
  done
}

#==============================================================================
# Private function that checks of the given variable is already present in the
# variable cache file.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__VARIABLES__CACHE_FILE
# Arguments
# - variable - raw variable line (name and values as a line)
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
# - 0 : Variable is already present in the cache file
# - 1 : Variable was not found in the cache file
#==============================================================================
_dm_lib__variables__variable_present_in_cache() {
  variable="$1"

  variable_name="${variable%% *}"  # getting the first element from the list

  if grep --silent -E "^${variable_name}\s" "$DM__GLOBAL__VARIABLES__CACHE_FILE"
  then
    dm_lib__debug \
      "_dm_lib__variables__variable_present_in_cache" \
      "variable '${variable_name}' was found in the cache"
    return 0
  else
    dm_lib__debug \
      "_dm_lib__variables__variable_present_in_cache" \
      "variable '${variable_name}' was not found in the cache"
    return 1
  fi
}

#==============================================================================
# Private function to append new values to the exosting variable in the cache
# file. The append operation is a literal append, no deduplication is applied
# to the values.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__VARIABLES__CACHE_FILE
# Arguments
# - variable - raw variable line (name and values as a line)
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
_dm_lib__variables__append_to_cache() {
  variable="$1"

  variable_name="${variable%% *}"  # getting the first element from the list
  values="${variable#* }"  # getting all items but the first

  dm_lib__debug_list \
    "_dm_lib__variables__append_to_cache" \
    "appending values to '${variable_name}' in cache:" "$values"

  sed -i "s%^${variable_name}.*$%& ${values}%" \
    "$DM__GLOBAL__VARIABLES__CACHE_FILE"
}

#==============================================================================
# Private function to write a not yet existing variable to the variable cache
# file. It is executed as a simple append to the file operation.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__VARIABLES__CACHE_FILE
# Arguments
# - variable - raw variable line (name and values as a line)
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
_dm_lib__variables__add_to_cache() {
  variable="$1"

  variable_name="${variable%% *}"  # getting the first element from the list
  values="${variable#* }"  # getting all items but the first

  dm_lib__debug_list \
    "_dm_lib__variables__add_to_cache" \
    "adding variable '${variable_name}' to cache directly with values:" "$values"
  echo "${variable}" >> "$DM__GLOBAL__VARIABLES__CACHE_FILE"
}

#==============================================================================
# Private function that reads the collected variables from the temporary
# variables cache file and merges the values to the final variable cache file.
# This function only appends the values of the same variable names, it does not
# normalize them (sorting, deduplication).
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__VARIABLES__TEMP_FILE
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
_dm_lib__variables__merge() {
  dm_lib__debug "_dm_lib__variables__merge" "merging variables from the modules"

  while read -r variable
  do
    variable_name="${variable%% *}"  # getting the first element from the list
    values="${variable#* }"  # getting all items but the first

    dm_lib__debug_list \
      "_dm_lib__variables__merge" \
      "processing variable '${variable_name}' with values:" "$values"

    if _dm_lib__variables__variable_present_in_cache "$variable"
    then
      _dm_lib__variables__append_to_cache "$variable"
    else
      _dm_lib__variables__add_to_cache "$variable"
    fi
  done < "$DM__GLOBAL__VARIABLES__TEMP_FILE"

  dm_lib__debug \
    "_dm_lib__variables__merge" \
    "variables merged"
}

#==============================================================================
# Private function that sorts the final variable cache file and normalizes the
# variable values line by line.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__VARIABLES__CACHE_FILE
# - DM__GLOBAL__VARIABLES__TEMP_FILE
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
_dm_lib__variables__normalize() {
  dm_lib__debug \
    "_dm_lib__variables__normalize" \
    "normalizing variables.."

  # Sorting the whole cache file lines.
  sort --output="$DM__GLOBAL__VARIABLES__CACHE_FILE" \
    "$DM__GLOBAL__VARIABLES__CACHE_FILE"

  # Copying the file to the temp file to be able to iterate over the lines
  # without having to worry about modifying them inplace.
  cp "$DM__GLOBAL__VARIABLES__CACHE_FILE" \
    "$DM__GLOBAL__VARIABLES__TEMP_FILE"

  # Iterating through the temp cache file lines, normalizing the values, and
  # replacing them in the cache file.
  while read -r line
  do
    variable_name="${line%% *}"  # getting the first element from the list
    values="${line#* }"  # getting all items but the first

    sorted_values="$(echo "$values" | xargs -n1 | sort | uniq | xargs)"
    sed -i "s;^${variable_name}.*$;${variable_name} ${sorted_values};" \
      "$DM__GLOBAL__VARIABLES__CACHE_FILE"

  done < "$DM__GLOBAL__VARIABLES__TEMP_FILE"

  # Deleting the temporary file.
  rm -f "$DM__GLOBAL__VARIABLES__TEMP_FILE"

  dm_lib__debug \
    "_dm_lib__variables__normalize" \
    "variables normalized"
}

#==============================================================================
# SUBMODULE LINKS
#==============================================================================
#   _      _       _
#  | |    (_)     | |
#  | |     _ _ __ | | _____
#  | |    | | '_ \| |/ / __|
#  | |____| | | | |   <\__ \
#  |______|_|_| |_|_|\_\___/
#
#==============================================================================

DM__GLOBAL__CONFIG__LINK__NOT_EXISTS="0"
DM__GLOBAL__CONFIG__LINK__EXISTS_BUT_TARGET_MISMATCH="1"
DM__GLOBAL__CONFIG__LINK__EXISTS_WITH_TARGET="2"

#==============================================================================
# Expand path received from the config files as a string. The rationale behind
# this expansion is to not to use the `eval` function. It is based on a string
# replacement. It only expands the `$HOME` variable and the `~` tilde
# character, so it behaves as the shell in these cases.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: string path to be expanded.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Expanded path.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
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

#==============================================================================
# Returns the target path of a symbolic link.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: link_name - path to the link thats target should be resolved
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - the resolved target path of the link
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
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

#==============================================================================
# Tests if the given link exists and it's target is the same as the given
# target. The parameter order is the same as for the `ln` command.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__CONFIG__LINK__NOT_EXISTS
# - DM__GLOBAL__CONFIG__LINK__EXISTS_BUT_TARGET_MISMATCH
# - DM__GLOBAL__CONFIG__LINK__EXISTS_WITH_TARGET
# Arguments
# - 1: target_path - the path the link should point to
# - 2: link_name - the path where the link should be
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - DM__GLOBAL__CONFIG__LINK__EXISTS_WITH_TARGET - the link is in place and
#   points to the given path
# - DM__GLOBAL__CONFIG__LINK__EXISTS_BUT_TARGET_MISMATCH - the link is in place
#   but it points to a different path
# - DM__GLOBAL__CONFIG__LINK__NOT_EXISTS - the link isn't exist
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
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

#==============================================================================
# Preprocesses the raw link data received from the configuration files. It is
# received as a module relative script name and an absolute path the link
# should be put.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: module_path - relative module path
# - 2: raw link string - this is a space separated module relative path and an
#      absolute link path where the link should be created.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - target path and link path separated by space.
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
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
#   _____             _
#  |  __ \           | |
#  | |  | | ___ _ __ | | ___  _   _
#  | |  | |/ _ \ '_ \| |/ _ \| | | |
#  | |__| |  __/ |_) | | (_) | |_| |
#  |_____/ \___| .__/|_|\___/ \__, |
#              | |             __/ |
#==============|_|============|___/===========================================

#==============================================================================
# Full deploy of a single module.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - module_path - relative module path
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
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
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
