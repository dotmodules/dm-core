#==============================================================================
# EXTERNAL PARAMETER PARSING
#==============================================================================

dm_lib__config__load_parameter() {
  index="$1"
  default_value="$2"
  file_path="$3"

  dm_lib__debug "dm_lib__config__load_parameter" \
    "loading external parameter with index '${index}'.."

  if [ -f "$file_path" ]
  then
    value="$(grep -E "^${index}\s" "$file_path" 2>/dev/null || true)"
    if [ -n "$value" ]
    then
      value="${value#* }"
      dm_lib__debug "dm_lib__config__load_parameter" \
        "parameter loaded with value '${value}'"
      echo "$value"
    else
      dm_lib__debug "dm_lib__config__load_parameter" \
        "error during parameter retrival, fallback to default value '${default_value}'"
      echo "$default_value"
    fi
  else
    dm_lib__debug "dm_lib__config__load_parameter" \
      "parameter file not found: '${file_path}'!"
    dm_lib__debug "dm_lib__config__load_parameter" \
      "fallback to default value '${default_value}'"
    echo "$default_value"
  fi
}
