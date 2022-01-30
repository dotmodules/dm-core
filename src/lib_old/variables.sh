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
