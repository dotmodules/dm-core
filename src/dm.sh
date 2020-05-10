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
# PARAMETER PARSING

# This variable contains the relative path from this dm.sh entry script to the
# modules root directory. The path is passed from the deployed Makefile as the
# only parameter, that knows the path from the deployment process.
DM__GLOBAL__RUNTIME__MODULES_ROOT=""

while [ $# -gt 0 ]
do
  key="$1"
  case $key in
    -h|--help|h|help)
      display_documentation
      exit 0
      ;;
    *)
      # The passed parameter is relative to the dm repo, so we need to step
      # back one more level.
      DM__GLOBAL__RUNTIME__MODULES_ROOT="$1"
      shift
      ;;
  esac
done


dm_lib__modules__list


