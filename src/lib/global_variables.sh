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
# COLOR AND PRINTOUT
#==============================================================================

# Checking the availibility and usability of tput. If it is available and
# usable we can set the global coloring variables with it.
if command -v tput >/dev/null && tput init >/dev/null 2>&1
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
