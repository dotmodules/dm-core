#!/bin/sh
#==============================================================================
#       _                 _
#      | |               | |
#    __| |_ __ ___    ___| |__
#   / _` | '_ ` _ \  / __| '_ \
#  | (_| | | | | | |_\__ \ | | |
#   \__,_|_| |_| |_(_)___/_| |_|
#
#==============================================================================

#==============================================================================
# SANE ENVIRONMENT
#==============================================================================

set -e  # Exit on error.
set -u  # Unbound variable safe guard.

#==============================================================================
# INITIAL PATH CHANGE
#==============================================================================

# It is known that on MacOS readlink does not support the -f flag by default.
# https://stackoverflow.com/a/4031502/1565331
if DM__GLOBAL__RUNTIME__REPO_ROOT="$(dirname "$(readlink -f "$0" 2>/dev/null)")"
then
  :
else
  # If the path cannot be determined with readlink, we have to check if this
  # script is executed through a symlink or not.
  if [ -L "$0" ]
  then
    # If the current script is executed through a symlink, we are aout of luck,
    # because without readlink, there is no universal solution for this problem
    # that uses the default shell toolset.
    echo 'Symlinked script won'\''t work on this machine..'
    echo 'Make sure you install a readlink version that supports the -f flag.'
  else
    # If the current script is not executed through a symlink, we can determine
    # the path with dirname.
    DM__GLOBAL__RUNTIME__REPO_ROOT="$(dirname "$0")"
  fi
fi

cd "${DM__GLOBAL__RUNTIME__REPO_ROOT}"

#==============================================================================
# DM_TOOLS INTEGRATION
#==============================================================================

#==============================================================================
# The first module we are loading is the dm-tools project that would provide the
# necessary platform independent interface for the command line tools. We are
# only loading the dm-tools system when it hasn't been loaded by other code (the
# tested system for example).
#==============================================================================

if [ -z ${DM_TOOLS__READY+x} ]
then
  # If dm_tools has not sourced yet, we have to source it from this repository.
  # Implementing the dm-tools inporting system variables.
  ___dm_tools_path_prefix="${DM__GLOBAL__RUNTIME__REPO_ROOT}/dependencies/dm-tools"
  DM_TOOLS__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX="$___dm_tools_path_prefix"
  if [ -d "$DM_TOOLS__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX" ]
  then
    # shellcheck source=./dependencies/dm-tools/dm.tools.sh
    . "${DM_TOOLS__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX}/dm.tools.sh"
  else
      echo 'Initialization failed!'
      echo 'dm_tools needs to be initialized but its git submodule is missing!'
      echo 'You need to init the dotmodules repository: make init'
  fi
fi

#==============================================================================
# VERSION PARSING
#==============================================================================

DM__CONFIG__VERSION="$(dm_tools__cat ./VERSION)"
export DM__CONFIG__VERSION

#==============================================================================
# LOAD SOURCE FILES
#==============================================================================

# shellcheck source=./src/load_sources.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/load_sources.sh"

#==============================================================================
# DEBUGGER INITIALIZATION
#==============================================================================

dm__debug__init

#==============================================================================
# COMMAND LINE ARGUMENTS
#==============================================================================

dm__debug 'bootstrap' "args[1]='$1'"

# Temporary file passed to this script from the calling Makefile that contains
# the user configurable parameters.
DM__GLOBAL__RUNTIME__PARAMETERS_FILE_PATH="$1"

#==============================================================================
# EXTERNAL PARAMETERS LOADING
#==============================================================================

dm__parameters__init "$DM__GLOBAL__RUNTIME__PARAMETERS_FILE_PATH"

#==============================================================================
# CORE INIT
#==============================================================================

#==============================================================================
# CLI INIT
#==============================================================================

dm__cli__interpreter__init
dm__cli__interpreter__run