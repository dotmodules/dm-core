#!/bin/sh

#==============================================================================
# SANE ENVIRONMENT

set -e
set -u

#==============================================================================
# PATH CHANGE

cd $(dirname $(readlink -f $0))

#==============================================================================
# GLOBAL VARIABLES

TEST_TEMP_DIR="helpers"

BATS_CORE_REPO="bats"
BATS_MOCK_REPO="mocks"
BATS_ASSERT_REPO="assert"
BATS_SUPPORT_REPO="support"

BATS="${TEST_TEMP_DIR}/${BATS_CORE_REPO}/bin/bats"

#==============================================================================
# PRETTY PRINTOUT

task() {
  echo " >> | $@"
}

success() {
  echo " ok | $@"
}

log() {
  sed -e 's/^/ .. | /' <&0
}

#==============================================================================
# BUSINESS LOGIC

clone_repo() {
  url="$1"
  repo_name="$2"
  git clone --depth 1 "$url" "$repo_name" 2>&1 | log
}

install_bats() {
  if [ ! -d "$TEST_TEMP_DIR" ]
  then
    task "Bootstrapping test tools into '${TEST_TEMP_DIR}'.."
    mkdir ${TEST_TEMP_DIR}
    pushd ${TEST_TEMP_DIR} > /dev/null

    clone_repo "git@github.com:bats-core/bats-core.git"      ${BATS_CORE_REPO}
    clone_repo "git@github.com:jasonkarns/bats-mock.git"     ${BATS_MOCK_REPO}
    clone_repo "git@github.com:jasonkarns/bats-assert-1.git" ${BATS_ASSERT_REPO}
    clone_repo "git@github.com:ztombol/bats-support.git"     ${BATS_SUPPORT_REPO}

    success "Done"

    popd > /dev/null
  fi
}

run_suite() {
  # Hack to be able to load the shell script with bats, as it's only capable of
  # loading `.bash` extensions..
  cp ../src/dm.lib.sh ../src/dm.lib.bash
  ${BATS} *.bats
  rm ../src/dm.lib.bash
}

run_shellcheck() {
  if command -v shellcheck >/dev/null
  then
    pushd ../src > /dev/null
    shellcheck -x dm.sh dm.lib.sh
    popd > /dev/null
  else
    echo "Warning: Shellcheck needs to be installed to run the validation."
    return
  fi
}

#==============================================================================
# ENTRY POINT AND INVOCATION

install_bats
run_suite
run_shellcheck
