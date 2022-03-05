#!/bin/sh

#==============================================================================
# GLOBAL COLOR DEFINITION
#==============================================================================

#==============================================================================
# Disabling the not used variables warning for this file..
# shellcheck disable=SC2034
#==============================================================================

if dm_tools__tput__is_available
then
  RED=$(dm_tools__tput setaf 1)
  RED_BG=$(dm_tools__tput setab 1)
  GREEN=$(dm_tools__tput setaf 2)
  YELLOW=$(dm_tools__tput setaf 3)
  BLUE=$(dm_tools__tput setaf 4)
  MAGENTA=$(dm_tools__tput setaf 5)
  CYAN=$(dm_tools__tput setaf 6)
  RESET=$(dm_tools__tput sgr0)
  BOLD=$(dm_tools__tput bold)
  DIM=$(dm_tools__tput dim)
else
  RED=''
  RED_BG=''
  GREEN=''
  YELLOW=''
  BLUE=''
  MAGENTA=''
  CYAN=''
  RESET=''
  BOLD=''
  DIM=''
fi