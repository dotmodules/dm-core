#!/bin/sh

#==============================================================================
# SANE ENVIRONMENT
#==============================================================================

set -e  # exit on error
set -u  # prevent unset variable expansion

#==============================================================================
# PATH HANDLING
#==============================================================================

# It is known that on MacOS readlink does not support the -f flag by default.
# https://stackoverflow.com/a/4031502/1565331
if DM_REPO_ROOT="$(dirname "$(readlink -f "$0" 2>/dev/null)")"
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
    DM_REPO_ROOT="$(dirname "$0")"
  fi
fi

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
  ___dm_tools_path_prefix="${DM_REPO_ROOT}/dependencies/dm-tools"
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
# GLOBAL VARIABLES
#==============================================================================

VERSION=$(cat "${DM_REPO_ROOT}/VERSION")
DEFAULT_MODULES_DIR='modules'
MAKEFILE_TEMPLATE_PATH='templates/Makefile.template'
MAKEFILE_NAME='Makefile'

if dm_tools__tput__is_available
then
  RED=$(dm_tools__tput setaf 1)
  RED_BG=$(dm_tools__tput setab 1)
  GREEN=$(dm_tools__tput setaf 2)
  YELLOW=$(dm_tools__tput setaf 3)
  BLUE=$(dm_tools__tput setaf 4)
  MAGENTA=$(dm_tools__tput setaf 5)
  CYAN=$(dm_tools__tput setaf 6)
  RESET=$(dm_tools__tput sgr0)
  BOLD=$(dm_tools__tput bold)
else
  RED=''
  RED_BG=''
  GREEN=''
  YELLOW=''
  BLUE=''
  MAGENTA=''
  CYAN=''
  RESET=''
  BOLD=''
fi

#==============================================================================
# FUNCTIONS
#==============================================================================

#==============================================================================
# Function that prints out the documentation to its standard output.
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
#   Documentation.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
print_documentation() {
dm_tools__cat <<EOM
- DOTMODULES ${VERSION} ------------------------------------------------------------
   _           _        _ _       _
  (_)         | |      | | |     | |
   _ _ __  ___| |_ __ _| | |  ___| |__
  | | '_ \\/ __| __/ _\` | | | / __| '_ \\
  | | | | \\__ \\ || (_| | | |_\\__ \\ | | |
  |_|_| |_|___/\\__\\__,_|_|_(_)___/_| |_|


  ${BOLD}DOCUMENTATION${RESET}

    Installer script for the ${BOLD}dotmodules${RESET} configuration management system. It
    assumes that you added ${BOLD}dotmodules${RESET} to your dotfiles repo as a submodule,
    and you are invoking this script from your dotfiles repository root.

    The script will calculate the necessary relative paths needed for proper
    operation and with that information it will generate a Makefile to your
    dotfile repo's root.

    This Makefile will be the main entry point to interact with ${BOLD}dotmodules${RESET}.


  ${BOLD}PARAMETERS${RESET}

    ${BOLD}-h|--help${RESET}

      Prints out this help message.

    ${BOLD}-m|--modules <modules_directory>${RESET}

      By default ${BOLD}dotmodules${RESET} will look for the '${DEFAULT_MODULES_DIR}' directory in your
      dotfiles repo, but you can pass a custom directory name with this flag.

EOM
}

#==============================================================================
# Function that calculates the relative path fot the given target path from the
# dm repository root directory. It is used to populate the paths in the
# generated Makefile.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] target path - Target path for which the relative path should be
#       calculate to from the dm repository root.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Relative path to the target path.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
calculate_relative_path_for() {
  target_path="$1"
  realpath --relative-to="$DM_REPO_ROOT" "$target_path"
}

#==============================================================================
# PARAMETER PARSING
#==============================================================================

MODULES_DIR="${DEFAULT_MODULES_DIR}"

while [ $# -gt 0 ]
do
  key="$1"
  case $key in
    -h|--help)
      print_documentation
      exit 0
      ;;
    -m|--modules)
      MODULES_DIR="$2"
      shift
      shift
      ;;
    *)
      ;;
  esac
done

#==============================================================================
# ENTRY POINT
#==============================================================================


dm_tools__echo ''
dm_tools__echo "  ${BOLD}DOTMODULES INSTALLER SCRIPT${RESET}"
dm_tools__echo ''

parameters_file_name='dm_parameters.tmp'
relative_parameters_file_path="$( \
  calculate_relative_path_for "$(pwd)/${parameters_file_name}" \
)"
relative_modules_path="$(calculate_relative_path_for "$(pwd)/${MODULES_DIR}")"

dm_tools__echo "    Current working directory: ${BLUE}$(pwd)${RESET}"
dm_tools__echo "    Dotmodules repository root: ${BLUE}${DM_REPO_ROOT}${RESET}"
dm_tools__echo "    Modules directory path: ${BLUE}$(pwd)/${MODULES_DIR}${RESET}"
dm_tools__echo "    Calculated relative modules directory path: ${GREEN}${relative_modules_path}${RESET}"

# Substitute calculated variables to the Makefile template and place it to the
# invocation's directory.
dm_tools__sed --expression "s#__PREFIX__#${DM_REPO_ROOT}#" \
    --expression "s#__PARAMETERS_FILE_NAME__#${parameters_file_name}#" \
    --expression "s#__RELATIVE_MODULES_PATH__#${relative_modules_path}#" \
    --expression "s#__RELATIVE_PARAMETERS_FILE_PATH__#${relative_parameters_file_path}#" \
    "${DM_REPO_ROOT}/${MAKEFILE_TEMPLATE_PATH}" > "${MAKEFILE_NAME}"

dm_tools__echo ''
dm_tools__echo 'Makefile added to your repository.'
