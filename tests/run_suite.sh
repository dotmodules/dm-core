#!/bin/sh

#==============================================================================
# SANE ENVIRONMENT
set -e  # exit on error
set -u  # prevent unset variable expansion

#==============================================================================
# PATH CHANGE
cd "$(dirname "$(readlink -f "$0")")"

#==============================================================================
# GLOBAL VARIABLES

TEST_TEMP_DIR="bats_resources"

BATS_CORE_REPO_URL="https://github.com/bats-core/bats-core.git"          # https://github.com/bats-core/bats-core
BATS_MOCK_REPO_URL="https://github.com/jasonkarns/bats-mock.git"         # https://github.com/jasonkarns/bats-mock
BATS_ASSERT_REPO_URL="https://github.com/bats-core/bats-assert.git"      # https://github.com/jasonkarns/bats-assert-1
BATS_SUPPORT_REPO_URL="https://github.com/ztombol/bats-support.git"      # https://github.com/ztombol/bats-support

BATS_CORE_REPO_DIR="bats"
BATS_MOCK_REPO_DIR="mocks"
BATS_ASSERT_REPO_DIR="assert"
BATS_SUPPORT_REPO_DIR="support"

BATS_EXECUTABLE="${TEST_TEMP_DIR}/${BATS_CORE_REPO_DIR}/bin/bats"

export BATS_MOCK="${TEST_TEMP_DIR}/${BATS_MOCK_REPO_DIR}/stub"
export BATS_ASSERT="${TEST_TEMP_DIR}/${BATS_ASSERT_REPO_DIR}/load"
export BATS_SUPPORT="${TEST_TEMP_DIR}/${BATS_SUPPORT_REPO_DIR}/load"

export DM_LIB_MUT="../src/dm.lib.sh"


#==============================================================================
# TEST SUITE

run_suite() {
  # Hack to be able to load the shell script with bats, as it's only capable of
  # loading `.bash` extensions..
  cp ${DM_LIB_MUT} "${DM_LIB_MUT}.bash"
  ${BATS_EXECUTABLE} ./*.bats
  rm "${DM_LIB_MUT}.bash"
}


#==============================================================================
# VALIDATION

run_shellcheck() {
  if command -v shellcheck >/dev/null
  then
    current_path="$(pwd)"
    cd ../src
    shellcheck -x *.sh
    cd "$current_path"
  else
    echo "Warning: Shellcheck needs to be installed to run the validation."
    return
  fi
}


#==============================================================================
# BATS TEST SUITE AND DEPENDENCIES

clone_repo() {
  url="$1"
  repo_name="$2"
  git clone --depth 1 "$url" "$repo_name" 2>&1 | log
}

install_bats_dependencies() {
  if [ ! -d "$TEST_TEMP_DIR" ]
  then
    task "Bootstrapping test tools into '${TEST_TEMP_DIR}'.."
    mkdir ${TEST_TEMP_DIR}
    cd ${TEST_TEMP_DIR}

    clone_repo ${BATS_CORE_REPO_URL} ${BATS_CORE_REPO_DIR}
    clone_repo ${BATS_MOCK_REPO_URL} ${BATS_MOCK_REPO_DIR}
    clone_repo ${BATS_ASSERT_REPO_URL} ${BATS_ASSERT_REPO_DIR}
    clone_repo ${BATS_SUPPORT_REPO_URL} ${BATS_SUPPORT_REPO_DIR}

    success "Done. Bats dependencies cloned."

    cd ..
  fi
}


#==============================================================================
# PRETTY PRINTOUT

task() {
  echo " >> | $1"
}

success() {
  echo " ok | $1"
}

log() {
  sed -e 's/^/ .. | /' <&0
}


#==============================================================================
# ENTRY POINT AND INVOCATION

install_bats_dependencies
run_suite
# run_shellcheck
