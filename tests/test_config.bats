load $DM_LIB_MUT
load $BATS_MOCK
load $BATS_ASSERT
load $BATS_SUPPORT
load test_helper

setup() {
  export dummy_module_path="${DM__TEST__TEST_DIR}/module"
  mkdir -p $dummy_module_path
  export dummy_config_file="${dummy_module_path}/${DM__GLOBAL__CONFIG__CONFIG_FILE_NAME}"
}

teardown() {
  rm -r "$dummy_module_path"
  mkdir -p "$dummy_module_path"
}

# ==============================================================================
# CONFIG LINE EXTRACTION

@test "config - relevant lines can be extracted" {
  prefix="PREFIX"
  expected="${prefix} this line is expected."

  echo "Some other line" >> $dummy_config_file
  echo "$expected" >> $dummy_config_file
  echo "Another line" >> $dummy_config_file

  run _dm_lib__config__get_lines_for_prefix "$dummy_config_file" "$prefix"

  assert test $status -eq 0
  assert test ${#lines[@]} -eq 1

  assert_line --index 0 "$expected"
}

@test "config - only the right ones are selected" {
  prefix="PREFIX"
  expected="${prefix} this line is expected."

  echo "Ambiguous line ${prefix}" >> $dummy_config_file
  echo "$expected" >> $dummy_config_file
  echo "Another ${prefix} ambiguous line" >> $dummy_config_file

  run _dm_lib__config__get_lines_for_prefix "$dummy_config_file" "$prefix"

  assert test $status -eq 0
  assert test ${#lines[@]} -eq 1

  assert_line --index 0 "$expected"
}

@test "config - messy whitespace can be tolerated" {
  prefix="PREFIX"
  expected="            ${prefix} this line is expected."

  echo "Ambiguous line ${prefix}" >> $dummy_config_file
  echo "$expected" >> $dummy_config_file
  echo "Another ${prefix} ambiguous line" >> $dummy_config_file

  run _dm_lib__config__get_lines_for_prefix "$dummy_config_file" "$prefix"

  assert test $status -eq 0
  assert test ${#lines[@]} -eq 1

  assert_line --index 0 "$expected"
}


# ==============================================================================
# PREFIX HANDLING

@test "config - prefix gets removed" {
  prefix="PREFIX"
  expected="this is what expected"
  input_line="${prefix} ${expected}"

  dummy_function() {
    echo "$input_line" | _dm_lib__config__remove_prefix_from_lines "$prefix"
  }
  run dummy_function

  assert test $status -eq 0
  assert_output "$expected"
}

@test "config - prefix and whitespace gets removed" {
  prefix="PREFIX"
  expected="this is what expected"
  input_line="    ${prefix}          ${expected}"

  dummy_function() {
    echo "$input_line" | _dm_lib__config__remove_prefix_from_lines "$prefix"
  }
  run dummy_function

  assert test $status -eq 0
  assert_output "$expected"
}


# ==============================================================================
# MODULE NAME

@test "config - parse module name" {
  name="My module"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "$name"
  }

  run dm_lib__config__get_name "dummy_module_path"

  assert test $status -eq 0
  assert_output "$name"
}

@test "config - parse module name - surrounding whitespace gets removed" {
  name="My module with  spaces"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "    ${name}         "
  }

  run dm_lib__config__get_name "dummy_module_path"

  assert test "$status" -eq 0
  assert_output "$name"
}

@test "config - parse module name - only the first name line is kept" {
  name_1="name_1"
  name_2="name_2"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "$name_1"
    echo "$name_2"
  }

  run dm_lib__config__get_name "dummy_module_path"

  assert test $status -eq 0
  assert test ${#lines[@]} -eq 1

  assert_line --index 0 "$name_1"
}


# ==============================================================================
# MODULE VERSION

@test "config - parse module version" {
  version="v1.2.3"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "$version"
  }

  run dm_lib__config__get_version "dummy_module_path"

  assert test "$status" -eq 0
  assert_output "$version"
}

@test "config - parse module version - only first word is captured" {
  version="v1.2.3"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "${version} other words"
  }

  run dm_lib__config__get_version "dummy_module_path"

  assert test "$status" -eq 0
  assert_output "$version"
}

@test "config - parse module version - whitespace ignored" {
  version="v1.2.3"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "   ${version} other words           "
  }

  run dm_lib__config__get_version "dummy_module_path"

  assert test "$status" -eq 0
  assert_output "$version"
}

@test "config - parse module version - only the first verion line is kept" {
  version_1="version_1"
  version_2="version_2"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "$version_1"
    echo "$version_2"
  }

  run dm_lib__config__get_name "dummy_module_path"

  assert test $status -eq 0
  assert test ${#lines[@]} -eq 1

  assert_line --index 0 "$version_1"
}


# ==============================================================================
# MODULE DOCUMENTATION

@test "config - parse module docs" {
  docs="This is my doc."

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "$docs"
  }

  run dm_lib__config__get_docs "dummy_module_path"

  assert test $status -eq 0
  assert_output "$docs"
}

@test "config - parse module docs - surrounding whitespace gets removed" {
  docs="This is my     doc with   plenty        of        spaces.."

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "       ${docs}                 "
  }

  run dm_lib__config__get_docs "dummy_module_path"

  assert test "$status" -eq 0
  assert_output "$docs"
}

@test "config - parse module docs - every line is kept" {
  docs_1="Docs1"
  docs_2="Docs2"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "$docs_1"
    echo "$docs_2"
  }

  run dm_lib__config__get_docs "dummy_module_path"

  assert test $status -eq 0
  assert test ${#lines[@]} -eq 2

  assert_line --index 0 "$docs_1"
  assert_line --index 1 "$docs_2"
}


# ==============================================================================
# MODULE VARIABLES

@test "config - parse registered variables" {
  variable_1="VARIABLE_1 value1 value2"
  variable_2="VARIABLE_2 value3 value4"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "$variable_1"
    echo "$variable_2"
  }

  run dm_lib__config__get_variables "dummy_module_path"

  assert test $status -eq 0
  assert test ${#lines[@]} -eq 2

  assert_line --index 0 "$variable_1"
  assert_line --index 1 "$variable_2"
}

@test "config - parse registered variables - whitespace gets normalized" {
  variable="VARIABLE      value1           value2         "
  expected_variable="VARIABLE value1 value2"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "$variable"
  }

  run dm_lib__config__get_variables "dummy_module_path"

  assert test "$status" -eq 0
  assert_output "$expected_variable"
}


# ==============================================================================
# MODULE LINKS

@test "config - parse links" {
  link_1="target_1 destination_1"
  link_2="target_2 destination_2"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "$link_1"
    echo "$link_2"
  }

  run dm_lib__config__get_links "dummy_module_path"

  assert test $status -eq 0
  assert test ${#lines[@]} -eq 2

  assert_line --index 0 "$link_1"
  assert_line --index 1 "$link_2"
}

@test "config - parse links - only the two items are kept while whitespace ignored" {
  link="   target     destination     dummy dummy"
  link_expected="target destination"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "$link"
  }

  run dm_lib__config__get_links "dummy_module_path"

  assert test "$status" -eq 0
  assert_output "$link_expected"
}


# ==============================================================================
# MODULE HOOKS

@test "config - parse registered hooks" {
  hook_1="HOOK_1 script_1 script_2"
  hook_2="HOOK_2 script_3 script_4"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "$hook_1"
    echo "$hook_2"
  }

  run dm_lib__config__get_hooks "dummy_module_path"

  assert test $status -eq 0
  assert test ${#lines[@]} -eq 2

  assert_line --index 0 "$hook_1"
  assert_line --index 1 "$hook_2"
}

@test "config - parse registered hooks - whitespace gets normalized" {
  hook="MY_HOOK      script1           script2         "
  expected_hook="MY_HOOK script1 script2"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "   ${hook}"
  }

  run dm_lib__config__get_hooks "dummy_module_path"

  assert test "$status" -eq 0
  assert_output "$expected_hook"
}


# ==============================================================================
# FULL CONFIG FILE

@test "config - tidy config file can be parsed" {
  name="My module"
  echo "NAME ${name}" >> $dummy_config_file

  version="v1.2.3"
  echo "VERSION ${version}" >> $dummy_config_file

  docs="This is my doc."
  echo "DOC ${docs}" >> $dummy_config_file

  variable="VARIABLE value1 value2"
  echo "REGISTER ${variable}" >> $dummy_config_file

  link="target destination"
  echo "LINK ${link}" >> $dummy_config_file

  hook="MY_HOOK script1 script2"
  echo "HOOK ${hook}" >> $dummy_config_file

  # Parse file
  run dm_lib__config__get_name "$dummy_module_path"
  assert test "$status" -eq 0
  assert_output "$name"

  run dm_lib__config__get_version "$dummy_module_path"
  assert test "$status" -eq 0
  assert_output "$version"

  run dm_lib__config__get_docs "$dummy_module_path"
  assert test "$status" -eq 0
  assert_output "$docs"

  run dm_lib__config__get_variables "$dummy_module_path"
  assert test "$status" -eq 0
  assert_output "$variable"

  run dm_lib__config__get_links "$dummy_module_path"
  assert test "$status" -eq 0
  assert_output "$link"

  run dm_lib__config__get_hooks "$dummy_module_path"
  assert test "$status" -eq 0
  assert_output "$hook"
}

@test "config - messy config file can be parsed" {
  name="My module"
  echo "  NAME     ${name}   " >> $dummy_config_file

  version="v1.2.3"
  echo " VERSION             ${version}  dummy words..       " >> $dummy_config_file

  docs="This is my doc."
  echo "   DOC     ${docs}          " >> $dummy_config_file

  variable="VARIABLE value1 value2"
  echo "        REGISTER     ${variable}     " >> $dummy_config_file

  link="target destination"
  echo "      LINK         ${link} dummy words     " >> $dummy_config_file

  hook="MY_HOOK script1 script2"
  echo "        HOOK       ${hook}    " >> $dummy_config_file

  # Parse file
  run dm_lib__config__get_name "$dummy_module_path"
  assert test "$status" -eq 0
  assert_output "$name"

  run dm_lib__config__get_version "$dummy_module_path"
  assert test "$status" -eq 0
  assert_output "$version"

  run dm_lib__config__get_docs "$dummy_module_path"
  assert test "$status" -eq 0
  assert_output "$docs"

  run dm_lib__config__get_variables "$dummy_module_path"
  assert test "$status" -eq 0
  assert_output "$variable"

  run dm_lib__config__get_links "$dummy_module_path"
  assert test "$status" -eq 0
  assert_output "$link"

  run dm_lib__config__get_hooks "$dummy_module_path"
  assert test "$status" -eq 0
  assert_output "$hook"
}
