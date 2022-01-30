#==============================================================================
# SUBMODULE LINKS
#==============================================================================
#   _      _       _
#  | |    (_)     | |
#  | |     _ _ __ | | _____
#  | |    | | '_ \| |/ / __|
#  | |____| | | | |   <\__ \
#  |______|_|_| |_|_|\_\___/
#
#==============================================================================

DM__GLOBAL__CONFIG__LINK__NOT_EXISTS="0"
DM__GLOBAL__CONFIG__LINK__EXISTS_BUT_TARGET_MISMATCH="1"
DM__GLOBAL__CONFIG__LINK__EXISTS_WITH_TARGET="2"

#==============================================================================
# Expand path received from the config files as a string. The rationale behind
# this expansion is to not to use the `eval` function. It is based on a string
# replacement. It only expands the `$HOME` variable and the `~` tilde
# character, so it behaves as the shell in these cases.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: string path to be expanded.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Expanded path.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__links__expand_path() {
  raw_path="$1"
  home="$HOME"

  dm_lib__debug "_dm_lib__links__expand_path" \
    "expanding raw_path '${raw_path}'"

  # Here we are replacing the existing `$HOME` and `~` strings instead of using
  # eval to do the same (and potentioally many other things..). This restricts
  # the expansion for only these two instances in exchange of security.
  path="$(echo "$raw_path" | \
    sed -e "s#^\$HOME#${home}#" | \
    sed -e "s#^~#${home}#" \
  )"

  dm_lib__debug "_dm_lib__links__expand_path" \
    "path expanded to '${path}'"

  echo "$path"
}

#==============================================================================
# Returns the target path of a symbolic link.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: link_name - path to the link thats target should be resolved
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - the resolved target path of the link
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__links__get_link_target_path() {
  link_name="$1"

  dm_lib__debug "_dm_lib__links__get_link_target_path" \
    "getting target path for link '${link_name}'"

  result="$(ls -l "$link_name")"
  target_path="${result##* }"

  dm_lib__debug "_dm_lib__links__get_link_target_path" \
    "resolved target path:'${target_path}'"

  echo "$target_path"
}

#==============================================================================
# Tests if the given link exists and it's target is the same as the given
# target. The parameter order is the same as for the `ln` command.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM__GLOBAL__CONFIG__LINK__NOT_EXISTS
# - DM__GLOBAL__CONFIG__LINK__EXISTS_BUT_TARGET_MISMATCH
# - DM__GLOBAL__CONFIG__LINK__EXISTS_WITH_TARGET
# Arguments
# - 1: target_path - the path the link should point to
# - 2: link_name - the path where the link should be
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - DM__GLOBAL__CONFIG__LINK__EXISTS_WITH_TARGET - the link is in place and
#   points to the given path
# - DM__GLOBAL__CONFIG__LINK__EXISTS_BUT_TARGET_MISMATCH - the link is in place
#   but it points to a different path
# - DM__GLOBAL__CONFIG__LINK__NOT_EXISTS - the link isn't exist
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__links__check_link() {
  target_path="$1"
  link_name="$2"

  dm_lib__debug "_dm_lib__links__check_link" \
    "checking target_path '${target_path}' and link_name '${link_name}'"

  target_path="$(readlink -f "$target_path")"

  if [ -L "$link_name" ]
  then
    link_target="$(_dm_lib__links__get_link_target_path "$link_name")"

    if [ "$target_path" = "$link_target" ]
    then
      dm_lib__debug "_dm_lib__links__check_link" "link exists and target matched"
      echo "$DM__GLOBAL__CONFIG__LINK__EXISTS_WITH_TARGET"
    else
      dm_lib__debug "_dm_lib__links__check_link" "link exists but target mismatched"
      echo "$DM__GLOBAL__CONFIG__LINK__EXISTS_BUT_TARGET_MISMATCH"
    fi
  else
    dm_lib__debug "_dm_lib__links__check_link" "link does not exist"
    echo "$DM__GLOBAL__CONFIG__LINK__NOT_EXISTS"
  fi
}

#==============================================================================
# Preprocesses the raw link data received from the configuration files. It is
# received as a module relative script name and an absolute path the link
# should be put.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - 1: module_path - relative module path
# - 2: raw link string - this is a space separated module relative path and an
#      absolute link path where the link should be created.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - target path and link path separated by space.
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_lib__links__preprocess_raw_link_string() {
  module="$1"
  link_string="$2"

  target_file="${link_string%% *}"  # getting the first element from the list
  link_name="${link_string#* }"  # getting all items but the first

  # making sure the script is relative to the module
  target_path="${module}/${target_file}"

  target_path="$(readlink -f "$target_path")"
  link_name="$(_dm_lib__links__expand_path "$link_name")"

  echo "${target_path} ${link_name}"
}
