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

dm_lib__debug() {
  #============================================================================
  # Prints out the given message to standard error if debug mode is enabled.
  #============================================================================
  if [ "$DM__GLOBAL__RUNTIME__DEBUG_ENABLED" = "1" ]
  then
    domain="$1"
    message="$2"
    printf "${DIM}$(date +"%F %T.%N") | %36s | %s${RESET}\n" "$domain" "$message"
  fi
} >&2

dm_lib__debug_list() {
  #============================================================================
  # Prints out a given newline separated list to the debug output in a
  # formatted line-by-line way if debug mode is enabled.
  #============================================================================
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
# SUBMODULE: CACHE
#==============================================================================

dm_lib__cache__init() {
  mkdir -p "$DM__GLOBAL__CONFIG__CACHE_DIR"
}


#==============================================================================
# SUBMODULE: MODULES
#==============================================================================

dm_lib__modules__list() {
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

#==============================================================================
# SUBMODULE: CONFIG FILE
#==============================================================================

dm_lib__config__get_name() {
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
  module_path="$1"

  prefix="NAME"

  _dm_lib__config__get_prefixed_lines_from_config_file "$module_path" "$prefix" | \
    _dm_lib__config__parse_as_line | \
    _dm_lib__utils__select_line "1"
}

dm_lib__config__get_version() {
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
  module_path="$1"

  prefix="VERSION"

  _dm_lib__config__get_prefixed_lines_from_config_file "$module_path" "$prefix" | \
    _dm_lib__config__parse_as_list | \
    _dm_lib__utils__trim_list "1" | \
    _dm_lib__utils__select_line "1"
}

dm_lib__config__get_docs() {
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
  module_path="$1"

  prefix="DOC"

  _dm_lib__config__get_prefixed_lines_from_config_file "$module_path" "$prefix" | \
    _dm_lib__config__parse_as_line
}

dm_lib__config__get_variables() {
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
  module_path="$1"

  debug_domain="dm_lib__config__get_variables"
  prefix="REGISTER"

  dm_lib__debug "$debug_domain" "getting lines from config file for prefix '${prefix}' in moodule '${module_path}'.."
  _dm_lib__config__get_prefixed_lines_from_config_file "$module_path" "$prefix" | \
    _dm_lib__config__parse_as_list
}

dm_lib__config__get_links() {
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
  module_path="$1"

  prefix="LINK"

  _dm_lib__config__get_prefixed_lines_from_config_file "$module_path" "$prefix" | \
    _dm_lib__config__parse_as_list | \
    _dm_lib__utils__trim_list "1-2"
}

dm_lib__config__get_hooks() {
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
  module_path="$1"

  prefix="HOOK"

  _dm_lib__config__get_prefixed_lines_from_config_file "$module_path" "$prefix" | \
    _dm_lib__config__parse_as_list
}

_dm_lib__config__get_config_file_path() {
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
  module_path="$1"
  config_file="${module_path}/${DM__GLOBAL__CONFIG__CONFIG_FILE_NAME}"
  echo "$config_file"
}

_dm_lib__config__get_lines_for_prefix() {
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
  config_file="$1"
  prefix="$2"
  grep --color=never --regexp="^\s*$prefix" "$config_file"
}

_dm_lib__config__remove_prefix_from_lines() {
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
  prefix="$1"
  cat - | sed -E "s/\s*${prefix}\s+//"
}

_dm_lib__config__get_prefixed_lines_from_config_file() {
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
  module_path="$1"
  prefix="$2"

  config_file="$(_dm_lib__config__get_config_file_path "$module_path")"

  _dm_lib__config__get_lines_for_prefix "$config_file" "$prefix" | \
    _dm_lib__config__remove_prefix_from_lines "$prefix"
}

_dm_lib__config__parse_as_list() {
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
  cat - | _dm_lib__utils__parse_list
}

_dm_lib__config__parse_as_line() {
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
  cat - | _dm_lib__utils__remove_surrounding_whitespace
}


#==============================================================================
# UTILS
#==============================================================================

_dm_lib__utils__normalize_whitespace() {
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
  cat - | tr --squeeze-repeats '[:space:]'
}

_dm_lib__utils__remove_surrounding_whitespace() {
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
  cat - | \
    sed -E 's/^\s*//' | \
    sed -E 's/\s*$//'
}

_dm_lib__utils__trim_list() {
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
  items="$1"
  cat - |\
    _dm_lib__utils__normalize_whitespace | \
    cut --delimiter=' ' --fields="${items}"
}

_dm_lib__utils__select_line() {
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
  line="$1"
  cat - | sed "${line}q;d"
}

_dm_lib__utils__parse_list() {
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
  _dm_lib__variables__format

  dm_lib__debug "dm_lib__variables__load" "initialization finished"
}


dm_lib__variables__get() {
  variable="$1"
  grep -E "^${variable}" "$DM__GLOBAL__CONFIG__CACHE__VARIABLES_FILE" | \
    _dm_lib__utils__trim_list 2-
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

_dm_lib__variables__format() {
  dm_lib__debug "_dm_lib__variables__format" "sorting lines in variables cache file"
  sort -o "$DM__GLOBAL__CONFIG__CACHE__VARIABLES_FILE" \
    "$DM__GLOBAL__CONFIG__CACHE__VARIABLES_FILE"

  cp "$DM__GLOBAL__CONFIG__CACHE__VARIABLES_FILE" \
    "$DM__GLOBAL__CONFIG__TEMP__VARIABLES_FILE"

  dm_lib__debug "_dm_lib__variables__format" "sorting variables line by line"
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
