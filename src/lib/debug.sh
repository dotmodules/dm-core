#==============================================================================
# DEBUGGING FUNCTIONALITY
#==============================================================================

#==============================================================================
# Prints out the given message to standard error if debug mode is enabled.
#==============================================================================
dm_lib__debug() {
  if [ "$DM__GLOBAL__RUNTIME__DEBUG_ENABLED" = "1" ]
  then
    domain="$1"
    message="$2"
    printf "${DIM}$(date +"%F %T.%N") | %48s | %s${RESET}\n" "$domain" "$message"
  fi
} >&2

#==============================================================================
# Prints out a given newline separated list to the debug output in a
# formatted line-by-line way if debug mode is enabled.
#==============================================================================
dm_lib__debug_list() {
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
