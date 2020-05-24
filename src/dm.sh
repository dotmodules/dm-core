#!/bin/sh

#==============================================================================
# SANE ENVIRONMENT

set -e
set -u


#==============================================================================
# GLOBAL SCRIPT BASED VARIABLES

DM__GLOBAL__RUNTIME__NAME="$(basename "$0")"
DM__GLOBAL__RUNTIME__PATH="$(dirname "$(readlink -f "$0")")"
DM__GLOBAL__RUNTIME__VERSION=$(cat "${DM__GLOBAL__RUNTIME__PATH}/../VERSION")


#==============================================================================
# PATH CHANGE

cd "${DM__GLOBAL__RUNTIME__PATH}"


#==============================================================================
# EXTERNAL LIBRARIES

. ./dm.lib.sh

DM__GLOBAL__RUNTIME__NAME="$(basename "$0")"
DM__GLOBAL__RUNTIME__PATH="$(dirname "$(readlink -f "$0")")"
DM__GLOBAL__RUNTIME__VERSION=$(cat "${DM__GLOBAL__RUNTIME__PATH}/../VERSION")


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

dm_cli__print() {
  message="$1"
  IFS_backup="$IFS"
  IFS=$'\n'
  for line in $message
  do
    echo "   ${line}"
  done
  IFS="$IFS_backup"
}


#==============================================================================
# PARAMETER PARSING

while [ $# -gt 0 ]
do
  key="$1"
  case $key in
    -h|--help|h|help)
      display_documentation
      exit 0
      ;;
    *)
      DM__GLOBAL__RUNTIME__MODULES_ROOT="$1"
      shift
      ;;
  esac
done


#==============================================================================
# COMMAND REGISTERING

REGISTERED_COMMANDS=""
DEFAULT_COMMAND=""

dm_cli__register_command() {
  hotkey="$1"
  command="$2"
  REGISTERED_COMMANDS="$(echo "${REGISTERED_COMMANDS}"; echo "${hotkey} ${command}")"
  dm_lib__debug dm_cli__register_command "command '${command}' registered for hotkey '${hotkey}'"
}

dm_cli__register_default_command() {
  command="$1"
  DEFAULT_COMMAND="$command"
  dm_lib__debug dm_cli__register_default_command "default command '${command}' registered"
}


#==============================================================================
# COMMAND: EXIT

dm_cli__register_command "q" "dm_cli__interpreter_quit"
dm_cli__register_command "quit" "dm_cli__interpreter_quit"
dm_cli__register_command "exit" "dm_cli__interpreter_quit"
dm_cli__interpreter_quit() {
  dm_lib__debug dm_cli__interpreter_quit "interpreter quit called, setting exit condition.."
  exit_condition=1
}


#==============================================================================
# COMMAND: PRINT HELP

dm_cli__register_command "h" "dm_cli__print_help"
dm_cli__register_command "help" "dm_cli__print_version"
dm_cli__register_default_command "dm_cli__print_help"
dm_cli__print_help() {
  echo "This is the help."
}


#==============================================================================
# COMMAND: PRINT VERSION

dm_cli__register_command "version" "dm_cli__print_version"
dm_cli__print_version() {
  echo ""
  dm_cli__print "$DM__GLOBAL__RUNTIME__VERSION"
  echo ""
}


#==============================================================================
# COMMAND: VARIABLES

dm_cli__register_command "v" "dm_cli__list_variables"
dm_cli__register_command "variables" "dm_cli__list_variables"
dm_cli__list_variables() {
  modules=$(dm_lib__modules__list)
  for module in $modules
  do
    name="$(dm_lib__config__get_name "$module")"
    variables="$(dm_lib__config__get_variables "$module")"
    status="deployed"

    name="${BOLD}${name}${RESET}"
    echo "${name}"
    echo "${variables}"
  done
}


#==============================================================================
# COMMAND: LIST MODULES

dm_cli__register_command "l" "dm_cli__list_modules"
dm_cli__register_command "list" "dm_cli__list_modules"
dm_cli__list_modules() {
  echo ""
  dm_cli__print "$(_dm_cli__list_modules | column --table --separator ":")"
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
    path="$(readlink -f ${module})"

    echo "[${index}]:${name}:${version}:${status}:${path}"
    index=$(expr $index + 1)
  done
}


#==============================================================================
# INTERPRETER

DM_CLI__PROMPT=" ${BOLD}dm${RESET} # "

dm_cli__interpreter() {
  debug_domain="dm_cli__interpreter"

  dm_lib__debug "$debug_domain" "interpreter starting.."
  exit_condition=0
  while [ $exit_condition -eq 0 ]
  do
    dm_lib__debug "$debug_domain" "waiting for user input.."
    read -p "$DM_CLI__PROMPT" raw_command
    if [ -z "$raw_command" ]
    then
      dm_lib__debug "$debug_domain" "empty user input received, skip processing.."
      continue
    fi
    dm_lib__debug "$debug_domain" "user input received: '${raw_command}'"

    hotkey=$(echo "$raw_command" | cut -d ' ' -f 1)
    dm_lib__debug "$debug_domain" "parsed hotkey: ${hotkey}"

    word_count=$(echo "$raw_command" | wc -w)
    dm_lib__debug "$debug_domain" "user input word count: ${word_count}"

    if [ $word_count -gt 1 ]
    then
      params=$(echo "$raw_command" | cut -d ' ' -f 2-)
      dm_lib__debug "$debug_domain" "received additional paramters: '${params}'"
    else
      params=""
      dm_lib__debug "$debug_domain" "no additional parameters received"
    fi

    result=$(echo "$REGISTERED_COMMANDS" | grep -E "^${hotkey}\s" || true)
    dm_lib__debug "$debug_domain" "command matching result: '${result}'"
    if [ -z "$result" ]
    then
      dm_lib__debug "$debug_domain" "no match for hotkey, executing default command: '${DEFAULT_COMMAND}'"
      $DEFAULT_COMMAND
    else
      command=$(echo "$result" | cut -d ' ' -f 2)
      dm_lib__debug "$debug_domain" "command matched: '${command}'"
      dm_lib__debug "$debug_domain" "executing command with parameters: '${command} ${params}'"
      $command $params
    fi
    dm_lib__debug "$debug_domain" "command executed"
  done
}

dm_cli__welcome_message() {
  echo " ${BOLD}dotmodules${RESET} v${DM__GLOBAL__RUNTIME__VERSION}"
}


dm_cli__init() {
  debug_domain="dm_cli__init"
  dm_lib__debug $debug_domain "initializing cache"
  dm_lib__cache__init
  dm_lib__variables__init
  dm_lib__variables__get IMRE
  dm_lib__debug $debug_domain "initializing cache"
}


#==============================================================================
# ENTRY POINT
#==============================================================================

dm_cli__init
dm_cli__welcome_message
dm_cli__interpreter

