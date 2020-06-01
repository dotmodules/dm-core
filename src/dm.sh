#!/bin/sh

#==============================================================================
# SANE ENVIRONMENT

set -e
set -u


#==============================================================================
# GLOBAL SCRIPT BASED VARIABLES

DM__GLOBAL__RUNTIME__PATH="$(dirname "$(readlink -f "$0")")"
DM__GLOBAL__RUNTIME__VERSION=$(cat "${DM__GLOBAL__RUNTIME__PATH}/../VERSION")

#==============================================================================
# PATH CHANGE

cd "${DM__GLOBAL__RUNTIME__PATH}"


#==============================================================================
# EXTERNAL LIBRARIES

. ./dm.lib.sh

DM__GLOBAL__CONFIG__CLI__VARIABLES_PADDING="12"

DM__GLOBAL__CLI__PROMPT=" ${BOLD}dm${RESET} # "
DM__GLOBAL__CLI__EXIT_CONDITION="0"

#==============================================================================
# DOCUMENTATION

print_documentation() {
cat <<EOM
- DOTMODULES ${GLOBAL__VERSION} ------------------------------------------------------------
        _
       | |
     __| |_ __ ___
    / _\` | '_ \` _ \\
   | (_| | | | | | |
  (_)__,_|_| |_| |_|

  ${BOLD}DOCUMENTATION${RESET}

    Modular Dotfiles System that helps you to organize your configuration files
    in a modular way. Plug and play others dotfile modules.


  ${BOLD}MODULE SCRIPTS${RESET}

    The following steps and their corresponting files/scripts are executed for
    every module during the installation process. If a corresponding file or
    script is present in the module's directory root the step will be executed.
    Each step also contains a pre and post hook defined in the next section.

    During the initial module discovery if at least one of the folowing files
    is present in the module's directory root, the module will be recognized
    and picked up for installation.

    ${BOLD}COLLECT${RESET}                                                             ${BLUE}collect${RESET}
                                                          ${GREEN}collect_finished.bash${RESET}

      Arbitrary categorized item collection. It can be used to collect specific
      data from packages. After the item collection has finished, an optional
      script will be called and the lst of collected items will be passed to
      it. In this way you can collect environment variables or additional path
      items from the packages, and apply them in your profile config.

    ${BOLD}INSTALL${RESET}                                                    ${GREEN}pre_install.bash${RESET}
                                                                        ${BLUE}install${RESET}
                                                              ${GREEN}post_install.bash${RESET}

      List of dependent packages that need to be installed in order to the
      module to operate properly. All the dependencies listed in this file will
      be collected from every module and the collected package list will be
      passed to the system's package manager. Lines started with a hashmark (#)
      will be ignored.

    ${BOLD}DEPLOY${RESET}                                                      ${GREEN}pre_deploy.bash${RESET}
                                                                         ${BLUE}deploy${RESET}
                                                               ${GREEN}post_deploy.bash${RESET}

      This script is executed after all the regular and custom dependencies are
      installed. The script can be used to copy  configuration files to the
      necessary places with the included dotfiles library.


  ${BOLD}MODULE INSTALLATION HOOKS${RESET}

    Each installation step consist a pre and post hook that can be used to
    customize even more the installation process if needed. Installation hooks
    are scripts in all cases even if the step's file is a regular file. Here is
    a list of all available hook scripts:

      ${GREEN}pre_install.bash${RESET}
      ${GREEN}post_install.bash${RESET}
      ${GREEN}pre_deploy.bash${RESET}
      ${GREEN}post_deploy.bash${RESET}


  ${BOLD}SPECIAL MODULE FILES${RESET}

    Each module can include special module files that will alter the execution
    of the installtion.

    ${BOLD}RETIRED${RESET}                                                             ${BLUE}retired${RESET}

      If this file is present in the module's root direcotry the module will be
      ignored during te installation process.

EOM
}

display_documentation() {
  # less is applying its own color sequence termination so we need to remove
  # the RESET sequences..
  print_documentation | sed 's/\x0F//g' | less -R
}

#==============================================================================
# INDENTED PRINTOUT

dm_cli__indent() {
  # Indents the given message to a common level.
  cat - | sed 's/^/    /'
}


#==============================================================================
# PARAMETER PARSING

DM__GLOBAL__RUNTIME__MODULES_ROOT="$1"
DM__GLOBAL__RUNTIME__DEBUG_ENABLED="$2"


#==============================================================================
# COMMAND REGISTERING

DM__RUNTIME__REGISTERED_COMMANDS=""
DM__RUNTIME__DEFAULT_COMMAND=""

dm_cli__register_command() {
  hotkey="$1"
  _command="$2"
  DM__RUNTIME__REGISTERED_COMMANDS="$( \
    echo "${DM__RUNTIME__REGISTERED_COMMANDS}"; echo "${hotkey} ${_command}" \
  )"
  dm_lib__debug "dm_cli__register_command" \
    "command '${_command}' registered for hotkey '${hotkey}'"
}

dm_cli__register_default_command() {
  _command="$1"
  DM__RUNTIME__DEFAULT_COMMAND="$_command"
  dm_lib__debug "dm_cli__register_default_command" \
    "command '${_command}' registered as the default command"
}

_dm_cli__get_command() {
  raw_command="$1"
  dm_lib__debug "_dm_cli__get_command" \
    "processing raw command: '${raw_command}'"

  hotkey=$(echo "$raw_command" | _dm_lib__utils__trim_list 1)
  word_count=$(echo "$raw_command" | wc -w)
  if [ "$word_count" -gt 1 ]
  then
    params=$(echo "$raw_command" | _dm_lib__utils__trim_list 2-)
    dm_lib__debug "_dm_cli__get_command" \
      "received additional paramters: '${params}'"
  else
    params=""
    dm_lib__debug "_dm_cli__get_command" \
      "no additional parameters received"
  fi

  dm_lib__debug "_dm_cli__get_command" \
    "matching registered command for hotkey: '${hotkey}'"
  result=$(echo "$DM__RUNTIME__REGISTERED_COMMANDS" | grep -E "^${hotkey}\s" || true)
  if [ -n "$result" ]
  then
    _command=$(echo "$result" | _dm_lib__utils__trim_list 2)
    dm_lib__debug "_dm_cli__get_command" \
      "command matched: '${_command}'"
    _command="$_command $params"
  else
    dm_lib__debug "_dm_cli__get_command" \
      "no match for hotkey, using default command: '${DM__RUNTIME__DEFAULT_COMMAND}'"
    _command="$DM__RUNTIME__DEFAULT_COMMAND"
  fi
  echo "$_command" | _dm_lib__utils__remove_surrounding_whitespace
}


#==============================================================================
# COMMAND: EXIT

dm_cli__register_command "q" "dm_cli__interpreter_quit"
dm_cli__register_command "quit" "dm_cli__interpreter_quit"
dm_cli__register_command "exit" "dm_cli__interpreter_quit"
dm_cli__interpreter_quit() {
  dm_lib__debug "dm_cli__interpreter_quit" \
    "interpreter quit called, setting exit condition.."
  DM__GLOBAL__CLI__EXIT_CONDITION="1"
}


#==============================================================================
# COMMAND: PRINT HELP

dm_cli__register_command "help" "dm_cli__indent_help"
dm_cli__register_default_command "dm_cli__indent_help"
dm_cli__indent_help() {
  echo ""
  echo "This is the help message.." | dm_cli__indent
  echo ""
}


#==============================================================================
# COMMAND: PRINT VERSION

dm_cli__register_command "version" "dm_cli__indent_version"
dm_cli__indent_version() {
  echo ""
  echo "${BOLD}dotmodules${RESET} ${DIM}v${DM__GLOBAL__RUNTIME__VERSION}${RESET}" | dm_cli__indent
  echo ""
}


#==============================================================================
# COMMAND: VARIABLES

dm_cli__register_command "v" "dm_cli__list_variables"
dm_cli__register_command "variables" "dm_cli__list_variables"
dm_cli__list_variables() {
  dm_lib__debug "dm_cli__list_variables" \
    "displaying the content of the full variable cache.."
  echo ""

  while read -r line
  do
    variable_name="$(echo "$line" | _dm_lib__utils__trim_list 1)"
    values="$(echo "$line" | _dm_lib__utils__trim_list 2-)"

    wrapped_values="$(echo "$values" | fmt --width=80)"
    _dm_cli__utils__header_multiline \
      "${BOLD}%${DM__GLOBAL__CONFIG__CLI__VARIABLES_PADDING}s${RESET} %s\n" \
      "$variable_name" \
      "$wrapped_values"
  done < "$DM__GLOBAL__CONFIG__CACHE__VARIABLES_FILE"

  echo ""
}

_dm_cli__utils__header_multiline() {
  format="$1"
  header="$2"
  lines="$3"

  header_line_passed="0"
  echo "$lines" | while IFS= read -r line
  do
    if [ "$header_line_passed" = "0" ]
    then
      # Te point here is to be able to receive dynamic formats.
      # shellcheck disable=SC2059
      printf "$format" "$header" "$line"
      header_line_passed="1"
    else
      # Also here.
      # shellcheck disable=SC2059
      printf "$format" " " "$line"
    fi
  done
}


#==============================================================================
# COMMAND: LIST MODULES

dm_cli__register_command "m" "dm_cli__modules"
dm_cli__register_command "modules" "dm_cli__modules"
dm_cli__modules() {
  echo ""
  if [ "$#" = "0" ]
  then
    _dm_cli__list_modules | column --table --separator ":" | dm_cli__indent
  else
    index="$1"
    _dm_cli__show_module "$index" | dm_cli__indent
  fi
  echo ""
}

_dm_cli__list_modules() {
  index=1
  modules=$(dm_lib__modules__list)
  for module in $modules
  do
    name="$(dm_lib__config__get_name "$module")"
    version="$(dm_lib__config__get_version "$module")"
    status="deployed"

    name="${BOLD}${name}${RESET}"
    version="${version}"
    status="${BOLD}${GREEN}${status}${RESET}"
    path="$(readlink -f "${module}")"

    echo "[${index}]:${name}:${version}:${status}:${path}"
    index=$((index + 1))
  done
}

_dm_cli__show_module() {
  selected_index="$1"
  dm_lib__debug "_dm_cli__show_module" "selected index: ${selected_index}"
  modules=$(dm_lib__modules__list)

  module_count="$(echo "$modules" | wc -l)"
  dm_lib__debug "_dm_cli__show_module" "module count: ${module_count}"

  if [ "$selected_index" -gt "$module_count" ]
  then
    dm_lib__debug "_dm_cli__show_module" "invalid selected index"
    echo "${RED}Invalid module index! It should be in the range of 1-${module_count}.${RESET}"
    return
  fi
  module="$(echo "$modules" | _dm_lib__utils__select_line "$selected_index")"

  dm_lib__debug "_dm_cli__show_module" "module selected: '${module}'"

  name="$(dm_lib__config__get_name "$module")"
  version="$(dm_lib__config__get_version "$module")"
  status="deployed"
  docs="$(dm_lib__config__get_docs "$module")"
  variables="$(dm_lib__config__get_variables "$module")"
  links="$(dm_lib__config__get_links "$module")"
  hooks="$(dm_lib__config__get_hooks "$module")"

  name="${BOLD}${name}${RESET}"
  version="${version}"
  status="${BOLD}${GREEN}${status}${RESET}"
  path="$(readlink -f "${module}")"

  format="${DIM}%10s${RESET} %s\n"
  _dm_cli__utils__header_multiline "$format" "Name" "$name"
  _dm_cli__utils__header_multiline "$format" "Version" "$version"
  echo ""
  _dm_cli__utils__header_multiline "$format" "Status" "$status"
  echo ""
  _dm_cli__utils__header_multiline "$format" "Docs" "$docs"
  echo ""
  _dm_cli__utils__header_multiline "$format" "Path" "$path"
  echo ""
  _dm_cli__utils__header_multiline "$format" "Variables" "$variables"
  echo ""
  _dm_cli__utils__header_multiline "$format" "Links" "$links"
  echo ""
  _dm_cli__utils__header_multiline "$format" "Hooks" "$hooks"
}

#==============================================================================
# INTERPRETER

dm_cli__interpreter() {
  dm_lib__debug "dm_cli__interpreter" "interpreter starting.."
  while [ "$DM__GLOBAL__CLI__EXIT_CONDITION" = "0" ]
  do
    dm_lib__debug "dm_cli__interpreter" "waiting for user input.."
    printf "%s" "$DM__GLOBAL__CLI__PROMPT"
    read -r raw_command
    if [ -z "$raw_command" ]
    then
      dm_lib__debug "dm_cli__interpreter" \
        "empty user input received, skip processing.."
      continue
    fi

    _command="$(_dm_cli__get_command "$raw_command")"
    dm_lib__debug "dm_cli__interpreter" "executing command: '${_command}'"
    $_command
    dm_lib__debug "dm_cli__interpreter" "command '${_command}' executed"

  done
  dm_lib__debug "dm_cli__interpreter" "interpreter finished"
}


#==============================================================================
# INITIALIZATION
#==============================================================================

dm_cli__init() {
  dm_lib__debug "dm_cli__init" "initialization started"
  dm_lib__cache__init
  dm_lib__variables__load "run_formatting_in_the_backgroud"
  dm_lib__debug "dm_cli__init" "initialization finished"
}

dm_cli__welcome_message() {
  echo " ${BOLD}dotmodules${RESET} ${DIM}v${DM__GLOBAL__RUNTIME__VERSION}${RESET}"
}


#==============================================================================
# ENTRY POINT
#==============================================================================

dm_cli__welcome_message
dm_cli__init
dm_cli__interpreter

