#!/bin/sh

export DM__GLOBAL__RUNTIME__REPO_ROOT="../../../.."
# shellcheck source=../../../../src/load_sources.sh
. "${DM__GLOBAL__RUNTIME__REPO_ROOT}/src/load_sources.sh"

setup_file() {
  dm__debug__init
}

setup() {
  export DM__CLI__INTERPRETER__PROMPT=''
  export DM__CONFIG__CLI__INDENT='[INDENT]'
  export RED='[RED]'
  export GREEN='[GREEN]'
  export YELLOW='[YELLOW]'
  export BLUE='[BLUE]'
  export MAGENTA='[MAGENTA]'
  export CYAN='[CYAN]'
  export BOLD='[BOLD]'
  export DIM='[DIM]'
  export RESET='[RESET]'
}

test__prompt_template_can_be_substituted__indent() {
  export DM__CONFIG__CLI__PROMPT_TEMPLATE='aaa<<indent>>bbb'

  run _dm__cli__interpreter__init_prompt
  assert_no_error
  assert_no_output
  assert_status 0

  result="$DM__CLI__INTERPRETER__PROMPT"
  expected='aaa[INDENT]bbb'

  assert_equal "$expected" "$result"
}

test__prompt_template_can_be_substituted__space() {
  export DM__CONFIG__CLI__PROMPT_TEMPLATE='aaa<<space>>bbb'

  run _dm__cli__interpreter__init_prompt
  assert_no_error
  assert_no_output
  assert_status 0

  result="$DM__CLI__INTERPRETER__PROMPT"
  expected='aaa bbb'

  assert_equal "$expected" "$result"
}

test__prompt_template_can_be_substituted__red() {
  export DM__CONFIG__CLI__PROMPT_TEMPLATE='aaa<<red>>bbb'

  run _dm__cli__interpreter__init_prompt
  assert_no_error
  assert_no_output
  assert_status 0

  result="$DM__CLI__INTERPRETER__PROMPT"
  expected='aaa[RED]bbb'

  assert_equal "$expected" "$result"
}

test__prompt_template_can_be_substituted__green() {
  export DM__CONFIG__CLI__PROMPT_TEMPLATE='aaa<<green>>bbb'

  run _dm__cli__interpreter__init_prompt
  assert_no_error
  assert_no_output
  assert_status 0

  result="$DM__CLI__INTERPRETER__PROMPT"
  expected='aaa[GREEN]bbb'

  assert_equal "$expected" "$result"
}

test__prompt_template_can_be_substituted__yellow() {
  export DM__CONFIG__CLI__PROMPT_TEMPLATE='aaa<<yellow>>bbb'

  run _dm__cli__interpreter__init_prompt
  assert_no_error
  assert_no_output
  assert_status 0

  result="$DM__CLI__INTERPRETER__PROMPT"
  expected='aaa[YELLOW]bbb'

  assert_equal "$expected" "$result"
}

test__prompt_template_can_be_substituted__blue() {
  export DM__CONFIG__CLI__PROMPT_TEMPLATE='aaa<<blue>>bbb'

  run _dm__cli__interpreter__init_prompt
  assert_no_error
  assert_no_output
  assert_status 0

  result="$DM__CLI__INTERPRETER__PROMPT"
  expected='aaa[BLUE]bbb'

  assert_equal "$expected" "$result"
}

test__prompt_template_can_be_substituted__magenta() {
  export DM__CONFIG__CLI__PROMPT_TEMPLATE='aaa<<magenta>>bbb'

  run _dm__cli__interpreter__init_prompt
  assert_no_error
  assert_no_output
  assert_status 0

  result="$DM__CLI__INTERPRETER__PROMPT"
  expected='aaa[MAGENTA]bbb'

  assert_equal "$expected" "$result"
}

test__prompt_template_can_be_substituted__cyan() {
  export DM__CONFIG__CLI__PROMPT_TEMPLATE='aaa<<cyan>>bbb'

  run _dm__cli__interpreter__init_prompt
  assert_no_error
  assert_no_output
  assert_status 0

  result="$DM__CLI__INTERPRETER__PROMPT"
  expected='aaa[CYAN]bbb'

  assert_equal "$expected" "$result"
}

test__prompt_template_can_be_substituted__bold() {
  export DM__CONFIG__CLI__PROMPT_TEMPLATE='aaa<<bold>>bbb'

  run _dm__cli__interpreter__init_prompt
  assert_no_error
  assert_no_output
  assert_status 0

  result="$DM__CLI__INTERPRETER__PROMPT"
  expected='aaa[BOLD]bbb'

  assert_equal "$expected" "$result"
}

test__prompt_template_can_be_substituted__dim() {
  export DM__CONFIG__CLI__PROMPT_TEMPLATE='aaa<<dim>>bbb'

  run _dm__cli__interpreter__init_prompt
  assert_no_error
  assert_no_output
  assert_status 0

  result="$DM__CLI__INTERPRETER__PROMPT"
  expected='aaa[DIM]bbb'

  assert_equal "$expected" "$result"
}

test__prompt_template_can_be_substituted__reset() {
  export DM__CONFIG__CLI__PROMPT_TEMPLATE='aaa<<reset>>bbb'

  run _dm__cli__interpreter__init_prompt
  assert_no_error
  assert_no_output
  assert_status 0

  result="$DM__CLI__INTERPRETER__PROMPT"
  expected='aaa[RESET]bbb'

  assert_equal "$expected" "$result"
}