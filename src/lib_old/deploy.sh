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
