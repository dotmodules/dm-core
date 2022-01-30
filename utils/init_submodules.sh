#!/bin/sh
#==============================================================================
# Helper function to initialize the test runner submodule if needed.
#==============================================================================

if git submodule status | grep --silent '^-'
then
  echo "> Initializing submodules.."
  git submodule init
  git submodule update
fi
