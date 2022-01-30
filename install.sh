#!/bin/sh
# Sane environment
set -e
set -u


#==============================================================================
# GLOBAL VARIABLES

INSTALL_SCRIPT_PATH="$(dirname "$(readlink -f "$0")")"
DM_ROOT="${INSTALL_SCRIPT_PATH}/src"
VERSION=$(cat "${INSTALL_SCRIPT_PATH}/VERSION")
DEFAULT_MODULES_DIR="modules"


#==============================================================================
# COLOR AND PRINTOUT MANAGEMENT

if command -v tput >/dev/null 2>&1
then
  RED=$(tput setaf 1)
  RED_BG=$(tput setab 1)
  GREEN=$(tput setaf 2)
  YELLOW=$(tput setaf 3)
  BLUE=$(tput setaf 4)
  MAGENTA=$(tput setaf 5)
  CYAN=$(tput setaf 6)
  RESET=$(tput sgr0)
  BOLD=$(tput bold)
else
  RED=""
  RED_BG=""
  GREEN=""
  YELLOW=""
  BLUE=""
  MAGENTA=""
  CYAN=""
  RESET=""
  BOLD=""
fi


#==============================================================================
# DOCUMENTATION

print_documentation() {
cat <<EOM
- DOTMODULES ${VERSION} ------------------------------------------------------------
   _           _        _ _       _
  (_)         | |      | | |     | |
   _ _ __  ___| |_ __ _| | |  ___| |__
  | | '_ \\/ __| __/ _\` | | | / __| '_ \\
  | | | | \\__ \\ || (_| | | |_\\__ \\ | | |
  |_|_| |_|___/\\__\\__,_|_|_(_)___/_| |_|

  ${BOLD}DOCUMENTATION${RESET}

    Installer script for the ${BOLD}dotmodules${RESET} system. It assumes that you added
    ${BOLD}dotmodules${RESET} to your dotfiles repo as a submodule, and you are invoking this
    script from your dotfiles repository root.

    The script will calculate the necessary relative paths needed for proper
    operation and with that information it will generate a Makefile to your
    dotfile repo's root. The relative paths will be written into that Makefile.

    This Makefile will be the main entry point to interact with ${BOLD}dotmodules${RESET}.


  ${BOLD}PARAMETERS${RESET}

    ${BOLD}-h|--help${RESET}

      Prints out this help message.

    ${BOLD}-m|--modules${RESET}

      By default ${BOLD}dotmodules${RESET} will look for the '${DEFAULT_MODULES_DIR}' directory in your
      dotfiles repo, but you can pass a custom directory name with this flag.
EOM
}

display_documentation() {
  # less is applying its own color sequence termination so we need to remove
  # the RESET sequences..
  print_documentation | sed 's/\x0F//g' | less -R
}

#==============================================================================
# PARAMETER PARSING

MODULES_DIR="${DEFAULT_MODULES_DIR}"

while [ $# -gt 0 ]
do
  key="$1"
  case $key in
    -h|--help)
      display_documentation
      exit 0
      ;;
    -m|--modules)
      MODULES_DIR="$2"
      shift # past argument
      shift # past value
      ;;
    *)
      shift
      ;;
  esac
done


#==============================================================================
# FUNCTIONS

log() {
  echo "${BOLD} .. ${RESET}| $@"
}

error() {
  echo "${BOLD}${RED} !! ${RESET}| $@"
}

assert_repo() {
  if [ ! -d ".git" ]
  then
    error "You should run the installer script from your repository root."
    exit 1
  fi
}

get_path_prefix() {
  # Calulate the prefix will be used by the Makefile to access the dm entry script.
  current_invocation_path="$(pwd)"
  dm_prefix=".$(echo "$DM_ROOT" | sed "s#$current_invocation_path##")"
  echo "$dm_prefix"
}

get_modules_relative_path() {
  # Calculate the relative path to the modules directory relative to the dm entry script.
  current_invocation_path="$(pwd)/${MODULES_DIR}"
  rel_path=$(realpath --relative-to="$DM_ROOT" "$current_invocation_path")
  echo "$rel_path"
}

assert_repo
log "Installing dotmodules into your repository.."
path_prefix=$(get_path_prefix)
log "Path prefix calculated: '${path_prefix}'"
modules_relative_path=$(get_modules_relative_path)
log "Modules relative path calculated: '${modules_relative_path}'"

# Substitute calculated variables to the Makefile template and place it to the
# invocation's directory.
sed -e "s#__PREFIX__#${path_prefix}#" \
    -e "s#__RELATIVE__#${modules_relative_path}#" \
    "${path_prefix}/../assets/Makefile.template" > Makefile

log "Makefile added to your repository."
