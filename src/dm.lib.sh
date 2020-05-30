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
# VARIABLES: GLOBAL
#==============================================================================

# Name of the configuration file. This file will indicate that a directory is a
# dm module.
DM__GLOBAL__CONFIG__CONFIG_FILE_NAME="dm.conf"

# Character used to separate lists in the whole project.
DM__GLOBAL__CONFIG__LIST_SEPARATOR=" "

# Cache directory to store data between runs
DM__GLOBAL__CONFIG__CACHE_DIR="../.dm.cache"
DM__GLOBAL__CONFIG__CACHE__VARIABLES_FILE="${DM__GLOBAL__CONFIG__CACHE_DIR}/dm.variables"


#==============================================================================
# VARIABLES: RUNTIME
#==============================================================================

# The following variables are expected to be set by the main script that uses
# this library. The values are depend on the actual deployment configuration,
# so they cannot be static like the other global variables.

# Global  debug enabled flag. Debug will be enabled if the value is 1.
DM__GLOBAL__RUNTIME__DEBUG_ENABLED="0"

# Name of the main executable. Used for error reporting.
DM__GLOBAL__RUNTIME__NAME="__INVALID__"

# Calculated relative path to the main script.
DM__GLOBAL__RUNTIME__PATH="__INVALID__"

# Current version of the system.
DM__GLOBAL__RUNTIME__VERSION="__INVALID__"

# Relative path to the modules root.
DM__GLOBAL__RUNTIME__MODULES_ROOT="__INVALID__"

# Using python based variable merging script
DM__GLOBAL__RUNTIME__BOOST__VARIABLES="0"


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
  debug_domain="dm_lib__modules_list"
  dm_lib__debug "$debug_domain" "loading modules from '${DM__GLOBAL__RUNTIME__MODULES_ROOT}'"

  modules="$(\
    find "$DM__GLOBAL__RUNTIME__MODULES_ROOT"\
      -type f\
      -name "$DM__GLOBAL__CONFIG__CONFIG_FILE_NAME" | sort\
  )"

  for module in $modules; do
    echo "$(dirname "$module")"
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
    _dm_lib__utils__remove_surrounding_whitespace | \
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

_dm_lib__utils__merge_lists() {
  #============================================================================
  # Merges two lists by sorting and deduplicating the items.
  #============================================================================
  # INPUT
  #============================================================================
  # Global variables
  # - None
  #
  # Arguments
  # - 1: list one
  # - 2: list two
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
  # - Merged, sorted, deduplicate list.
  #
  # StdErr
  # - Error that occured during operation.
  #
  # Status
  # -  0 : ok
  # - !0 : error
  #============================================================================
  list_1="$1"
  list_2="$2"
  merged_values="${list_1} ${list_2}"
  echo "$merged_values" | xargs -n1 | sort | uniq | xargs
}



#==============================================================================
# SUBMODULE: VARIABLES
#==============================================================================

dm_lib__variables__load() {
  dm_lib__debug "dm_lib__variables__load" \
    "loading variables from the modules.."

  _dm_lib__variables__init

  variables="$(_dm_lib__variables__get_variables_from_modules)"

  if [ "$DM__GLOBAL__RUNTIME__BOOST__VARIABLES" = "1" ]
  then
    merged_variables="$(echo "$variables" | python boost/merge_variables.py)"
  else
    merged_variables="$(_dm_lib__variables__merge "$variables")"
  fi

  _dm_lib__variables__write_to_cache "$merged_variables"
  dm_lib__debug "dm_lib__variables__load" "initialization finished"
}

_dm_lib__variables__merge() {
  variables="$1"
  merged_variables=""

  # Writing the received raw variables to the file, to be able to process them
  # without a subshell because of the read pipe.
  echo "$variables" > "$DM__GLOBAL__CONFIG__CACHE__VARIABLES_FILE"

  dm_lib__debug "_dm_lib__variables__merge" "merging variables.."

  while read -r variable
  do
    variable_name="$(echo "$variable" | _dm_lib__utils__trim_list 1)"
    new_values="$(echo "$variable" | _dm_lib__utils__trim_list 2-)"
    dm_lib__debug "_dm_lib__variables__merge" \
      "processing variable name: '$variable_name'"

    existing_variable="$( \
      echo "$merged_variables" | grep -E "^${variable_name}\s" || true \
    )"
    if [ -n "$existing_variable" ]
    then
      dm_lib__debug "_dm_lib__variables__merge" \
        "existing variable found: '$existing_variable'"

      existing_values="$(echo "$existing_variable" | _dm_lib__utils__trim_list 2-)"

      merged_values="$(_dm_lib__utils__merge_lists "${existing_values}" "${new_values}")"

      dm_lib__debug "_dm_lib__variables__merge" \
        "values merged: '$merged_values'"

      updated_variable="${variable_name} ${merged_values}"

      dm_lib__debug "_dm_lib__variables__merge" \
        "variable updated: '$updated_variable'"

      merged_variables="$( \
        # Another variable present in the pattern. Regular parameter expansion
        # cannot be used here.
        # shellcheck disable=SC2001
        echo "$merged_variables" | \
        sed "s%^${variable_name}.*$%${updated_variable}%" \
      )"

    else
      dm_lib__debug "_dm_lib__variables__merge" \
        "variable '${variable_name}' no match in temp cache"
      dm_lib__debug "_dm_lib__variables__merge" \
        "adding variable '${variable_name}' to temp cache"
      sorted_values="$(_dm_lib__utils__merge_lists "${new_values}" "")"
      merged_variables="$( \
        printf "%s\n%s" "$merged_variables" "${variable_name} ${sorted_values}" \
      )"
    fi
  done < "$DM__GLOBAL__CONFIG__CACHE__VARIABLES_FILE"
  echo "$merged_variables"
  dm_lib__debug "_dm_lib__variables__merge" "variables merged"
}

_dm_lib__variables__write_to_cache() {
  merged_variables="$1"
  dm_lib__debug "_dm_lib__variables__write_to_cache" \
    "writing variables to the variable cache file"
  echo "$merged_variables" | \
    sed '/^[[:space:]]*$/d'| \
    sort > "$DM__GLOBAL__CONFIG__CACHE__VARIABLES_FILE"
}

dm_lib__variables__get() {
  variable="$1"
  grep -E "^${variable}" "$DM__GLOBAL__CONFIG__CACHE__VARIABLES_FILE" | \
    _dm_lib__utils__trim_list 2-
}

_dm_lib__variables__init() {
  dm_lib__debug "_dm_lib__variables__init" \
    "initializing variable cache"

  rm -f "$DM__GLOBAL__CONFIG__CACHE__VARIABLES_FILE"

  dm_lib__debug "_dm_lib__variables__init" \
    "existing variable cache file deleted"
}

_dm_lib__variables__get_variables_from_modules() {
  modules="$(dm_lib__modules__list)"
  for module in $modules
  do
    dm_lib__config__get_variables "$module"
  done
}
