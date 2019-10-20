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
# DM LIB INTERFACE - these functions have to be implemented by the client.

client__log() {
  echo "${RED}${BOLD}Interface incomplete: client__log not implemented!${RESET}"
  exit 1
}

client__log_verbose() {
  echo "${RED}${BOLD}Interface incomplete: client__log_verbose not implemented!${RESET}"
  exit 1
}

#==============================================================================
# COLOR AND PRINTOUT MANAGEMENT

# Ignoring the not used shellcheck errors as these variables are good to have
# during additional development.
if command -v tput > /dev/null
then
  # shellcheck disable=SC2034
  RED=$(tput setaf 1)
  # shellcheck disable=SC2034
  RED_BG=$(tput setab 1)
  # shellcheck disable=SC2034
  GREEN=$(tput setaf 2)
  # shellcheck disable=SC2034
  YELLOW=$(tput setaf 3)
  # shellcheck disable=SC2034
  BLUE=$(tput setaf 4)
  # shellcheck disable=SC2034
  MAGENTA=$(tput setaf 5)
  # shellcheck disable=SC2034
  CYAN=$(tput setaf 6)
  # shellcheck disable=SC2034
  RESET=$(tput sgr0)
  # shellcheck disable=SC2034
  BOLD=$(tput bold)
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
fi

lib__bela() {
  echo "$(lib__imre)"
}

lib__imre() {
  echo "hello"
}

#==============================================================================
#  A P I   F U N C T I O N S
#==============================================================================

#######################################
# Searches for all the modules.
# Globals:
#   PARAM__MODULES_ROOT
#   CONF__MODULE_FILE__REGISTER
#   CONF__MODULE_FILE__INSTALL
#   CONF__MODULE_FILE__DEPLOY
#   CONF__MODULE_FILE__RETIRED
#   CONF__MODULE_FILE__HOOK__PRE_DEPLOY
#   CONF__MODULE_FILE__HOOK__PRE_INSTALL
#   CONF__MODULE_FILE__HOOK__POST_INSTALL
#   CONF__MODULE_FILE__HOOK__PRE_DEPLOY
#   CONF__MODULE_FILE__HOOK__POST_DEPLOY
#   CONF__MODULE_FILE__CACHE
# Arguments:
#   None
# Output variables:
#   module_paths - space separated list of module paths
#   installed    - space separated list of installed module paths
#   retired      - space separated list of retired module paths
# Returns:
#   None
#######################################
lib__get_module_paths() {
  module_paths=""
  retired=""
  installed=""

  # Looking for modules that have at least one of the module related files.
  config_file_paths=$(find "$PARAM__MODULES_ROOT" -type f \
    -name "$CONF__MODULE_FILE__REGISTER" -o \
    -name "$CONF__MODULE_FILE__INSTALL" -o \
    -name "$CONF__MODULE_FILE__DEPLOY" -o \
    -name "$CONF__MODULE_FILE__RETIRED" -o \
    -name "$CONF__MODULE_FILE__HOOK__PRE_DEPLOY" -o \
    -name "$CONF__MODULE_FILE__HOOK__PRE_INSTALL" -o \
    -name "$CONF__MODULE_FILE__HOOK__POST_INSTALL" -o \
    -name "$CONF__MODULE_FILE__HOOK__PRE_DEPLOY" -o \
    -name "$CONF__MODULE_FILE__HOOK__POST_DEPLOY" -o \
    -name "$CONF__MODULE_FILE__CACHE" | sort)

  for config_file_path in $config_file_paths
  do
    module_path=$(realpath "$(dirname "$config_file_path")")
    module_name=$(basename "$module_path")

    if [ -f "$module_path/$CONF__MODULE_FILE__RETIRED" ]
    then
      client__log "${BOLD}${RED}$(printf %15s "${module_name}")${RESET} ${module_path}"
      retired="$retired ."
      continue
    elif [ -f "$module_path/$CONF__MODULE_FILE__RETIRED" ]
    then
      client__log "${BOLD}${GREEN}$(printf %15s "${module_name}")${RESET} ${module_path}"
      installed="$installed ."
    else
      client__log "${BOLD}${BLUE}$(printf %15s "${module_name}")${RESET} ${module_path}"
    fi
    module_paths="$module_paths $module_path"

  done
}
