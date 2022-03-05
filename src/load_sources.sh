#!/bin/sh

#==============================================================================
# CORE
#==============================================================================

# shellcheck source=./debug.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/debug.sh"

# shellcheck source=./utils.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/utils.sh"
# shellcheck source=./parameters.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/parameters.sh"

# shellcheck source=./modules/modules.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/modules/modules.sh"
# shellcheck source=./modules/config/docs.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/modules/config/docs.sh"
# shellcheck source=./modules/config/hooks.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/modules/config/hooks.sh"
# shellcheck source=./modules/config/links.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/modules/config/links.sh"
# shellcheck source=./modules/config/name.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/modules/config/name.sh"
# shellcheck source=./modules/config/utils.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/modules/config/utils.sh"
# shellcheck source=./modules/config/variables.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/modules/config/variables.sh"
# shellcheck source=./modules/config/version.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/modules/config/version.sh"

#==============================================================================
# CLI
#==============================================================================

# shellcheck source=./cli/colors.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/cli/colors.sh"
# shellcheck source=./cli/display.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/cli/display.sh"
# shellcheck source=./cli/commands.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/cli/commands.sh"
# shellcheck source=./cli/commands/exit.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/cli/commands/exit.sh"
# shellcheck source=./cli/commands/help.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/cli/commands/help.sh"
# shellcheck source=./cli/commands/hooks.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/cli/commands/hooks.sh"
# shellcheck source=./cli/commands/modules.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/cli/commands/modules.sh"
# shellcheck source=./cli/commands/variables.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/cli/commands/variables.sh"
# shellcheck source=./cli/interpreter.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/cli/interpreter.sh"