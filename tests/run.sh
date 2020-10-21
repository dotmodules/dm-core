#!/bin/sh

#==============================================================================
# SANE ENVIRONMENT
#==============================================================================

set -e  # exit on error
set -u  # prevent unset variable expansion

#==============================================================================
# PATH CHANGE
#==============================================================================

cd "$(dirname "$(readlink -f "$0")")"

#==============================================================================
# DM_TEST_RUNNER CONFIGURATION
#==============================================================================

DM_TEST__SUBMODULE_PATH_PREFIX="./runner"
DM_TEST__TEST_FILE_PREFIX="test_"
DM_TEST__TEST_CASE_PREFIX="test_"
DM_TEST__TEST_CASES_ROOT="./tests"

#==============================================================================
# TEST RUNNER IMPORT
#==============================================================================

# shellcheck source=./runner/dm.test.sh
. "${DM_TEST__SUBMODULE_PATH_PREFIX}/dm.test.sh"

#==============================================================================
# SHELLCHECK VALIDATION
#==============================================================================

run_shellcheck() {
  if command -v shellcheck >/dev/null
  then
    current_path="$(pwd)"
    cd ../src
    shellcheck -x ./*.sh
    cd "$current_path"
  else
    echo "Warning: Shellcheck needs to be installed to run the validation."
    return
  fi
}

#==============================================================================
# ENTRY POINT
#==============================================================================

dm_test__run_suite
run_shellcheck