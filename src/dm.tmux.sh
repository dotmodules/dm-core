#!/bin/sh

#==============================================================================
# SANE ENVIRONMENT

set -e
set -u

#==============================================================================
# GLOBAL SCRIPT BASED VARIABLES

GLOBAL__SELF_NAME="$(basename "$0")"
GLOBAL__SELF_PATH="$(dirname "$(readlink -f "$0")")"
GLOBAL__VERSION=$(cat "${GLOBAL__SELF_PATH}/../VERSION")

#==============================================================================
# PATH CHANGE

cd "${GLOBAL__SELF_PATH}"

#==============================================================================
# EXTERNAL LIBRARIES

. ./dm.lib.sh

#==============================================================================
# ASSERT TMUX INSTALLED

if ! command -v tmux >/dev/null 2>&1
then
  echo "${BOLD}${RED}Missing dependency${RESET}: ${BOLD}tmux${RESET} is required to use this dotmodules implementation."
  echo "Install it manually and try again."
  exit 0
fi

#==============================================================================
# CONFIGURATION

# CONF__MODULE_CONF_FILE="module.conf"
CONF__MODULE_FILE__REGISTER="module.register"
CONF__MODULE_FILE__INSTALL="module.install"
CONF__MODULE_FILE__DEPLOY="module.deploy"

CONF__MODULE_FILE__RETIRED="module.retired"

CONF__MODULE_FILE__HOOK__POST_REGISTER="module.hook.post_register"
CONF__MODULE_FILE__HOOK__PRE_INSTALL="module.hook.pre_install"
CONF__MODULE_FILE__HOOK__POST_INSTALL="module.hook.post_install"
CONF__MODULE_FILE__HOOK__PRE_DEPLOY="module.hook.pre_deploy"
CONF__MODULE_FILE__HOOK__POST_DEPLOY="module.hook.post_deploy"

CONF__MODULE_FILE__CACHE=".module.cache"

CONF__SIDEBAR_WIDTH=42
CONF__LOGO_HEIGHT=7
CONF__LINE_COLOR="$GREEN"
CONF__TMUX_LINE_COLOR="green"

#==============================================================================
# GLOBAL VARIABLES (you should not change theese)

PRIVATE__FIFO="dotmodules.fifo"

PRIVATE__TMUX_SOCKET="dotmodules_socket"
PRIVATE__TMUX_SESSION="dotmodules_session"

PRIVATE__ROLE_FRAME="role_frame"
PRIVATE__ROLE_MAIN="role_main"
PRIVATE__ROLE_DETAILS="role_details"
PRIVATE__ROLE_LOGO="logo"

PRIVATE__ERROR_FILE="error.log"

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
# PARAMETER PARSING

PARAM__ROLE=$PRIVATE__ROLE_FRAME

while [ $# -gt 0 ]
do
  key="$1"
  case $key in
    -h|--help|h|help)
      display_documentation
      exit 0
      ;;
    -r|--role)
      PARAM__ROLE="$2"
      shift # past argument
      shift # past value
      ;;
    *)
      # The passed parameter is relative to the dm repo, so we need to step back one more level.
      PARAM__MODULES_ROOT="$1"
      shift
      ;;
  esac
done

#==============================================================================
# BUSINESS LOGIC

main() {
  echo "${BOLD}$(python -c "print(\"v${GLOBAL__VERSION} \".center(${CONF__SIDEBAR_WIDTH}))")${RESET}"

  gui__line --top

  get_module_paths

  gui__option \
    --green i "${BOLD}${GREEN}install${RESET} non retired modules" \
    --green I "${BOLD}${GREEN}install${RESET} selected module" \
    --cyan l "list all module ${BOLD}${CYAN}details${RESET}" \
    --cyan L "list selected module ${BOLD}${CYAN}details${RESET}" \
    --red d "${BOLD}${RED}uninstall${RESET} all modules" \
    --red D "${BOLD}${RED}uninstall${RESET} selected module" \
    --magenta q "quit" \
    "What do you want to do? This is a really long line that will be folded if it is longer than the sidebar width.."
  case $result in
    i)
      install_modules
      ;;
    I)
      gui__info "Installing selected module.."
      ;;
    l)
      gui__info "Listing details for all modules.."
      ;;
    L)
      gui__info "Listing details for selected module.."
      ;;
    d)
      gui__info "Uninstalling all modules.."
      ;;
    D)
      gui__info "Uninstalling selected module.."
      ;;
    q)
      exit 0
      ;;
  esac
  gui__option "Press any button to exit.."
}

install_modules() {
  gui__task "Installing modules.."
  gui__line
  execute_register
}

execute_register() {
  gui__task "Step [1/3]: Registering"
  for module_path in $module_paths
  do
    module_name="$(basename "$module_path")"
    gui__info "Installing ${BOLD}${module_name}${RESET}.."
  done
}

get_module_paths() {
  gui__task "Looking for dotfiles modules.."
  gui__line
  gui__log "> Looking for modules.."
  gui__log ""

  lib__get_module_paths

  gui__success "${BOLD}$(printf %3s "$(echo "$config_file_paths" | wc -w)") modules${RESET} were found"
  gui__blank "${BOLD}$(printf %3s "$(echo "$retired" | wc -w)") ${RED}retired${RESET}"
  gui__blank "${BOLD}$(printf %3s "$(echo "$installed" | wc -w)") ${GREEN}installed${RESET}"
}

#==============================================================================
# DOTMODULES API IMPLEMENTATION

client__log() {
  gui__log "$1"
}


#==============================================================================
# GUI IMPLEMENTATION

gui__blank() {
  message=$(gui__fold_message "$@")
  echo "    ${CONF__LINE_COLOR}│${RESET} $message"
}

gui__info() {
  message=$(gui__fold_message "$@")
  echo " ${BOLD}${CYAN}..${RESET} ${CONF__LINE_COLOR}│${RESET} $message"
}

gui__task() {
  message=$(gui__fold_message "$@")
  echo " ${BOLD}${BLUE}>>${RESET} ${CONF__LINE_COLOR}│${RESET} $message"
}

gui__success() {
  message=$(gui__fold_message "$@")
  echo " ${BOLD}${GREEN}ok${RESET} ${CONF__LINE_COLOR}│${RESET} $message"
}

gui__warning() {
  message=$(gui__fold_message "$@")
  echo " ${BOLD}${YELLOW}!!${RESET} ${CONF__LINE_COLOR}│${RESET} $message"
}

gui__fail() {
  message=$(gui__fold_message "$@")
  echo " ${BOLD}${RED}!!${RESET} ${CONF__LINE_COLOR}│${RESET} $message"
}

gui__log() {
  printf "%s\n" "$1" > $PRIVATE__FIFO
}

#######################################
# Function that prints a horizontal line to the sidebar. It can draw three type
# of lines.
# Globals:
#   CONF__SIDEBAR_WIDTH
#   CONF__LINE_COLOR
# Arguments:
#   None
# Flags:
#   --doube - double line
#   --top   - line that can be used as a sidebar top
# Returns:
#   None
#######################################
gui__line() {
  flag=${1:-}
  printf "%s" "${CONF__LINE_COLOR}"
  if [ "$flag" = "--double" ]
  then
    python -c "print('═' * 4 + '╪' + '═' * ($CONF__SIDEBAR_WIDTH - 5))"
  elif [ "$flag" = "--top" ]
  then
    python -c "print('─' * 4 + '┬' + '─' * ($CONF__SIDEBAR_WIDTH - 5))"
  else
    python -c "print('─' * 4 + '┼' + '─' * ($CONF__SIDEBAR_WIDTH - 5))"
  fi
  printf "%s" "${RESET}"
}

#######################################
# Fold a given line to fit into the sidebar and prefizes the folds with the
# sidebar placehlder. It tries to fold colored lines too, but only with a very
# crued method, so it can happen that the colored fold fails..
# Globals:
#   CONF__SIDEBAR_WIDTH
#   CONF__LINE_COLOR
# Arguments:
#   None
# Flags:
#   None
# Returns:
#   None
#######################################
gui__fold_message() {
  original="$1"
  folded=$(printf "%s" "$original" | sed 's/\x0F//g' | sed 's/\x1B\[[0-9;]*[JKmsu]//g' | fmt --width=$((CONF__SIDEBAR_WIDTH - 7)))
  if [ "$(echo "$folded" | wc -l)" -gt 1 ]
  then
    IFS_BACKUP="$IFS"
    IFS=$(printf '\n\b')
    for line in $folded
    do
      last="${line##* }"
      original="$(echo "$original" | sed "s/${last}/&\n/")"
    done
    IFS="$IFS_BACKUP"
  fi
  echo "$original" | head -c -1 | sed -e ":a;N;\$!ba;s/\n/\n    ${CONF__LINE_COLOR}│${RESET}/g"
}

gui__render_option() {
  color=$1
  shift
  key=$1
  shift
  description=$1
  echo  "    ${CONF__LINE_COLOR}│${RESET}  ${BOLD}[${color}${key}${RESET}${BOLD}]${RESET} $description"
}

gui__option() {
  # Had to use a backspace in order to prevent the shell trailing newline
  # removing mechanism.
  carriage_return=$(printf "\n\b")

  options=""
  keys=""

  while [ $# -gt 0 ]
  do
    key="$1"
    case $key in
      -g|--green)
        options="${options}${carriage_return}$(gui__render_option "${GREEN}" "$2" "$3")"
        keys="${keys}${2}"
        shift # past color
        shift # past key
        shift # past description
        ;;
      -y|--yellow)
        options="${options}${carriage_return}$(gui__render_option "${YELLOW}" "$2" "$3")"
        keys="${keys}${2}"
        shift # past color
        shift # past key
        shift # past description
        ;;
      -b|--blue)
        options="${options}${carriage_return}$(gui__render_option "${BLUE}" "$2" "$3")"
        keys="${keys}${2}"
        shift # past color
        shift # past key
        shift # past description
        ;;
      -r|--red)
        options="${options}${carriage_return}$(gui__render_option "${RED}" "$2" "$3")"
        keys="${keys}${2}"
        shift # past color
        shift # past key
        shift # past description
        ;;
      -m|--magenta)
        options="${options}${carriage_return}$(gui__render_option "${MAGENTA}" "$2" "$3")"
        keys="${keys}${2}"
        shift # past color
        shift # past key
        shift # past description
        ;;
      -c|--cyan)
        options="${options}${carriage_return}$(gui__render_option "${CYAN}" "$2" "$3")"
        keys="${keys}${2}"
        shift # past color
        shift # past key
        shift # past description
        ;;
      *)
        prompt="$1"
        shift
        ;;
    esac
  done

  gui__line
  prompt=$(gui__fold_message "$prompt")

  if [ -n "$keys" ]
  then
    result="│"
    until test -n "$result" && echo "$keys" | grep --silent "$result"
    do
      echo " ${BOLD}${YELLOW}??${RESET} ${CONF__LINE_COLOR}│${RESET} ${prompt}"
      echo "    ${CONF__LINE_COLOR}│${RESET}${options}"
      echo "    ${CONF__LINE_COLOR}│${RESET}"
      printf "    %s│%s > " "${CONF__LINE_COLOR}" "${RESET}"
      read -r result
      gui__line
    done
  else
    echo " ${BOLD}${YELLOW}??${RESET} ${CONF__LINE_COLOR}│${RESET} ${prompt}"
    printf "    %s│%s > " "${CONF__LINE_COLOR}" "${RESET}"
    read -r result
    gui__line
  fi
}

#==============================================================================
# ROLE ENTRY POINTS

entry_frame_role() {
  rm -f $PRIVATE__FIFO
  mkfifo $PRIVATE__FIFO
  width=$(tput cols)
  height=$(tput lines)

  default_tmux_command="/bin/sh --noprofile --norc"

  # Initializing new plain tmux session
  tmux -L $PRIVATE__TMUX_SOCKET -f /dev/null new-session -d -x "$width" -y "$height" -s "$PRIVATE__TMUX_SESSION" "$default_tmux_command"
  tmux -L $PRIVATE__TMUX_SOCKET set status off
  tmux -L $PRIVATE__TMUX_SOCKET set mouse on
  tmux -L $PRIVATE__TMUX_SOCKET set pane-border-style fg=${CONF__TMUX_LINE_COLOR}
  tmux -L $PRIVATE__TMUX_SOCKET set pane-active-border-style fg=${CONF__TMUX_LINE_COLOR}

  tmux -L $PRIVATE__TMUX_SOCKET split-window -h "$default_tmux_command"

  tmux -L $PRIVATE__TMUX_SOCKET select-pane -t 0
  tmux -L $PRIVATE__TMUX_SOCKET send-keys "./${GLOBAL__SELF_NAME} --role ${PRIVATE__ROLE_LOGO}" C-m

  tmux -L $PRIVATE__TMUX_SOCKET split-window -v "$default_tmux_command"
  tmux -L $PRIVATE__TMUX_SOCKET resize-pane -y $CONF__LOGO_HEIGHT -t 0
  tmux -L $PRIVATE__TMUX_SOCKET resize-pane -x $CONF__SIDEBAR_WIDTH -t 0

  tmux -L $PRIVATE__TMUX_SOCKET select-pane -t 1
  tmux -L $PRIVATE__TMUX_SOCKET send-keys "./${GLOBAL__SELF_NAME} --role ${PRIVATE__ROLE_MAIN} ${PARAM__MODULES_ROOT} 2> $PRIVATE__ERROR_FILE" C-m

  tmux -L $PRIVATE__TMUX_SOCKET select-pane -t 2
  tmux -L $PRIVATE__TMUX_SOCKET send-keys "./${GLOBAL__SELF_NAME} --role ${PRIVATE__ROLE_DETAILS}" C-m
  tmux -L $PRIVATE__TMUX_SOCKET select-pane -t 1
  tmux -L $PRIVATE__TMUX_SOCKET attach
}

entry_main_role() {
  clear
  main
}

entry_details_role() {
  clear
  cat <>${PRIVATE__FIFO}
}

entry_logo_role() {
  clear
  printf "%s" "${GREEN}"
  echo '                 _'
  echo '                | |'
  echo '              __| |_ __ ___'
  echo "             / _\` | \`_ \` _ \\"
  echo '            | (_| | | | | | |'
  echo '           (_)__,_|_| |_| |_|'
  printf "%s" "${RESET}"
  read -r
}

#==============================================================================
# CLEAN EXIT

trap__at_exit() {
  rm -f $PRIVATE__FIFO
  tmux -L $PRIVATE__TMUX_SOCKET kill-session 2>/dev/null || true
}

trap trap__at_exit EXIT

#==============================================================================
# MAIN ROLE DEcISION POINT AND ENTRY CALL

case $PARAM__ROLE in
  "${PRIVATE__ROLE_FRAME}")
    entry_frame_role
    ;;
  "${PRIVATE__ROLE_MAIN}")
    entry_main_role
    ;;
  "${PRIVATE__ROLE_DETAILS}")
    entry_details_role
    ;;
  "${PRIVATE__ROLE_LOGO}")
    entry_logo_role
    ;;
  *)
    echo "Invalid role '${PARAM__ROLE}'!"
    exit 1
    ;;
esac

if [ -f $PRIVATE__ERROR_FILE ]
then
  cat $PRIVATE__ERROR_FILE
  rm $PRIVATE__ERROR_FILE
fi
