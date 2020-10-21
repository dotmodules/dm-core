. ../../../src/dm.lib.sh

setup() {
  dummy_module_path="${DM_TEST__TMP_TEST_DIR}/module"
  mkdir -p "$dummy_module_path"
  dummy_config_file="${dummy_module_path}/${DM__GLOBAL__CONFIG__CONFIG_FILE_NAME}"
}

teardown() {
  rm -r "$dummy_module_path"
  mkdir -p "$dummy_module_path"
}

#==============================================================================
# CONFIG LINE EXTRACTION
#==============================================================================

test__extraction__relevant_lines_can_be_extracted() {
  prefix="PREFIX"
  expected="${prefix} this line is expected."

  {
    echo "Some other line";
    echo "$expected";
    echo "Another line";
  } >> "$dummy_config_file"

  run _dm_lib__config__get_lines_for_prefix "$dummy_config_file" "$prefix"

  assert_status 0
  assert_output_line_count 1
  assert_line_at_index 1 "$expected"
}

test__extraction__only_the_right_ones_are_selected() {
  prefix="PREFIX"
  expected="${prefix} this line is expected."

  {
    echo "Ambiguous line ${prefix}";
    echo "$expected";
    echo "Another ${prefix} ambiguous line";
  } >> "$dummy_config_file"

  run _dm_lib__config__get_lines_for_prefix "$dummy_config_file" "$prefix"

  assert_status 0
  assert_output_line_count 1
  assert_line_at_index 1 "$expected"
}

test__extraction__messy_whitespace_can_be_tolerated() {
  prefix="PREFIX"
  expected="            ${prefix} this line is expected."

  {
    echo "Ambiguous line ${prefix}";
    echo "$expected";
    echo "Another ${prefix} ambiguous line";
  } >> "$dummy_config_file"

  run _dm_lib__config__get_lines_for_prefix "$dummy_config_file" "$prefix"

  assert_status 0
  assert_output_line_count 1
  assert_line_at_index 1 "$expected"
}

#==============================================================================
# PREFIX HANDLING
#==============================================================================

test__prefix__prefix_gets_removed() {
  prefix="PREFIX"
  expected="this is what expected"
  input_line="${prefix} ${expected}"

  dummy_function() {
    echo "$input_line" | _dm_lib__config__remove_prefix_from_lines "$prefix"
  }
  run dummy_function

  assert_status 0
  assert_output "$expected"
}

test__prefix__prefix_and_whitespace_gets_removed() {
  prefix="PREFIX"
  expected="this is what expected"
  input_line="    ${prefix}          ${expected}"

  dummy_function() {
    echo "$input_line" | _dm_lib__config__remove_prefix_from_lines "$prefix"
  }
  run dummy_function

  assert_status 0
  assert_output "$expected"
}

#==============================================================================
# MODULE NAME
#==============================================================================

test__name__parse_module_name() {
  name="My module"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "$name"
  }

  run dm_lib__config__get_name "dummy_module_path"

  assert_status 0
  assert_output "$name"
}

test__name__surrounding_whitespace_gets_removed() {
  name="My module with  spaces"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "    ${name}         "
  }

  run dm_lib__config__get_name "dummy_module_path"

  assert_status 0
  assert_output "$name"
}

test__name__only_the_first_name_line_is_kept() {
  name_1="name_1"
  name_2="name_2"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "$name_1"
    echo "$name_2"
  }

  run dm_lib__config__get_name "dummy_module_path"

  assert_status 0
  assert_output_line_count 1
  assert_line_at_index 1 "$name_1"
}

#==============================================================================
# MODULE VERSION
#==============================================================================

test__version__parse_module_version() {
  version="v1.2.3"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "$version"
  }

  run dm_lib__config__get_version "dummy_module_path"

  assert_status 0
  assert_output "$version"
}

test__version__only_first_word_is_captured() {
  version="v1.2.3"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "${version} other words"
  }

  run dm_lib__config__get_version "dummy_module_path"

  assert_status 0
  assert_output "$version"
}

test__version__whitespace_ignored() {
  version="v1.2.3"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "   ${version} other words           "
  }

  run dm_lib__config__get_version "dummy_module_path"

  assert_status 0
  assert_output "$version"
}

test__version__only_the_first_verion_line_is_kept() {
  version_1="version_1"
  version_2="version_2"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "$version_1"
    echo "$version_2"
  }

  run dm_lib__config__get_name "dummy_module_path"

  assert_status 0
  assert_output_line_count 1
  assert_line_at_index 1 "$version_1"
}

#==============================================================================
# MODULE DOCUMENTATION
#==============================================================================

test__docs__leading_pipe_gets_removed() {
  docs="This is my doc."

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "|${docs}"
  }

  run dm_lib__config__get_docs "dummy_module_path"

  assert_status 0
  assert_output "$docs"
}

test__docs__surrounding_whitespace_gets_removed() {
  docs="This is my     doc with   plenty        of        spaces.."

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "       |${docs}                 "
  }

  run dm_lib__config__get_docs "dummy_module_path"

  assert_status 0
  assert_output "$docs"
}

test__docs__indentation_is_kept_when_using_a_pipe() {
  docs="This is my     doc with   plenty        of        spaces.."
  indentation="       "

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "       |${indentation}${docs}                 "
  }

  run dm_lib__config__get_docs "dummy_module_path"

  assert_status 0
  assert_output "${indentation}${docs}"
}

test__docs__every_line_is_kept() {
  docs_1="Docs1"
  docs_2="Docs2"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "$docs_1"
    echo "$docs_2"
  }

  run dm_lib__config__get_docs "dummy_module_path"

  assert_status 0
  assert_output_line_count 2

  assert_line_at_index 1 "$docs_1"
  assert_line_at_index 2 "$docs_2"
}

#==============================================================================
# MODULE VARIABLES
#==============================================================================

test__variables__parse_registered_variables() {
  variable_1="VARIABLE_1 value1 value2"
  variable_2="VARIABLE_2 value3 value4"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "$variable_1"
    echo "$variable_2"
  }

  run dm_lib__config__get_variables "dummy_module_path"

  assert_status 0
  assert_output_line_count 2

  assert_line_at_index 1 "$variable_1"
  assert_line_at_index 2 "$variable_2"
}

test__variables__whitespace_gets_normalized() {
  variable="VARIABLE      value1           value2         "
  expected_variable="VARIABLE value1 value2"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "$variable"
  }

  run dm_lib__config__get_variables "dummy_module_path"

  assert_status 0
  assert_output "$expected_variable"
}

#==============================================================================
# MODULE LINKS
#==============================================================================

test__links__parse_links() {
  link_1="target_1 destination_1"
  link_2="target_2 destination_2"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "$link_1"
    echo "$link_2"
  }

  run dm_lib__config__get_links "dummy_module_path"

  assert_status 0
  assert_output_line_count 2

  assert_line_at_index 1 "$link_1"
  assert_line_at_index 2 "$link_2"
}

test__links__only_the_two_items_are_kept_while_whitespace_ignored() {
  link="   target     destination     dummy dummy"
  link_expected="target destination"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "$link"
  }

  run dm_lib__config__get_links "dummy_module_path"

  assert_status 0
  assert_output "$link_expected"
}

#==============================================================================
# MODULE HOOKS
#==============================================================================

test__hooks__parse_registered_hooks() {
  hook_1="HOOK_1 0 script_1"
  hook_2="HOOK_2 0 script_2"

  expected_hook_1="HOOK_1 0 script_1"
  expected_hook_2="HOOK_2 0 script_2"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "$hook_1"
    echo "$hook_2"
  }

  run dm_lib__config__get_hooks "dummy_module_path"

  assert_status 0
  assert_output_line_count 2

  assert_line_at_index 1 "$expected_hook_1"
  assert_line_at_index 2 "$expected_hook_2"
}

test__hooks__additional_script_names_gets_ignored() {
  hook_1="HOOK_1 0 script_1 ignored"
  hook_2="HOOK_2 0 script_2 ignored ignored"

  expected_hook_1="HOOK_1 0 script_1"
  expected_hook_2="HOOK_2 0 script_2"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "$hook_1"
    echo "$hook_2"
  }

  run dm_lib__config__get_hooks "dummy_module_path"

  assert_status 0
  assert_output_line_count 2

  assert_line_at_index 1 "$expected_hook_1"
  assert_line_at_index 2 "$expected_hook_2"
}

test__hooks__whitespace_gets_normalized() {
  hook="MY_HOOK      0           script1         "
  expected_hook="MY_HOOK 0 script1"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "   ${hook}"
  }

  run dm_lib__config__get_hooks "dummy_module_path"

  assert_status 0
  assert_output "$expected_hook"
}

test__hooks__missing_priority_gets_inserted() {
  hook_1="HOOK_1 script_1"
  hook_2="HOOK_2 0 script_2"

  expected_hook_1="HOOK_1 0 script_1"
  expected_hook_2="HOOK_2 0 script_2"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "$hook_1"
    echo "$hook_2"
  }

  run dm_lib__config__get_hooks "dummy_module_path"

  assert_status 0
  assert_output_line_count 2

  assert_line_at_index 1 "$expected_hook_1"
  assert_line_at_index 2 "$expected_hook_2"
}

test__hooks__missing_priority_gets_inserted_while_ignoring_the_whitespace() {
  hook_1="HOOK_1       script_1    "
  hook_2="HOOK_2    0 script_2 "

  expected_hook_1="HOOK_1 0 script_1"
  expected_hook_2="HOOK_2 0 script_2"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "$hook_1"
    echo "$hook_2"
  }

  run dm_lib__config__get_hooks "dummy_module_path"

  assert_status 0
  assert_output_line_count 2

  assert_line_at_index 1 "$expected_hook_1"
  assert_line_at_index 2 "$expected_hook_2"
}

test__hooks__second_parameter_has_to_be_an_integer() {
  hook_1="HOOK_1 script_1 ignored something else"
  hook_2="HOOK_2 0 script_2"

  expected_hook_1="HOOK_1 0 script_1"
  expected_hook_2="HOOK_2 0 script_2"

  _dm_lib__config__get_prefixed_lines_from_config_file() {
    echo "$hook_1"
    echo "$hook_2"
  }

  run dm_lib__config__get_hooks "dummy_module_path"

  assert_status 0
  assert_output_line_count 2

  assert_line_at_index 1 "$expected_hook_1"
  assert_line_at_index 2 "$expected_hook_2"
}

#==============================================================================
# FULL CONFIG FILE
#==============================================================================

test__full__tidy_config_file_can_be_parsed() {
  name="My module"
  echo "NAME ${name}" >> "$dummy_config_file"

  version="v1.2.3"
  echo "VERSION ${version}" >> "$dummy_config_file"

  docs="This is my doc."
  echo "DOC | ${docs}" >> "$dummy_config_file"

  variable="VARIABLE value1 value2"
  echo "REGISTER ${variable}" >> "$dummy_config_file"

  link="target destination"
  echo "LINK ${link}" >> "$dummy_config_file"

  hook="MY_HOOK script1"
  expected_hook="MY_HOOK 0 script1"
  echo "HOOK ${hook}" >> "$dummy_config_file"

  # Parse file
  run dm_lib__config__get_name "$dummy_module_path"
  assert_status 0
  assert_output "$name"

  run dm_lib__config__get_version "$dummy_module_path"
  assert_status 0
  assert_output "$version"

  run dm_lib__config__get_docs "$dummy_module_path"
  assert_status 0
  assert_output " $docs"

  run dm_lib__config__get_variables "$dummy_module_path"
  assert_status 0
  assert_output "$variable"

  run dm_lib__config__get_links "$dummy_module_path"
  assert_status 0
  assert_output "$link"

  run dm_lib__config__get_hooks "$dummy_module_path"
  assert_status 0
  assert_output "$expected_hook"
}

test__full__messy_config_file_can_be_parsed() {
  name="My module"
  echo "  NAME     ${name}   " >> "$dummy_config_file"

  version="v1.2.3"
  echo " VERSION             ${version}  dummy words..       " >> "$dummy_config_file"

  docs="This is my doc."
  echo "   DOC     ${docs}          " >> "$dummy_config_file"

  variable="VARIABLE value1 value2"
  echo "        REGISTER     ${variable}     " >> "$dummy_config_file"

  link="target destination"
  echo "      LINK         ${link} dummy words     " >> "$dummy_config_file"

  hook="MY_HOOK           script1          invalid      unparsed   ignored "
  expected_hook="MY_HOOK 0 script1"
  echo "        HOOK       ${hook}    " >> "$dummy_config_file"

  # Parse file
  run dm_lib__config__get_name "$dummy_module_path"
  assert_status 0
  assert_output "$name"

  run dm_lib__config__get_version "$dummy_module_path"
  assert_status 0
  assert_output "$version"

  run dm_lib__config__get_docs "$dummy_module_path"
  assert_status 0
  assert_output "$docs"

  run dm_lib__config__get_variables "$dummy_module_path"
  assert_status 0
  assert_output "$variable"

  run dm_lib__config__get_links "$dummy_module_path"
  assert_status 0
  assert_output "$link"

  run dm_lib__config__get_hooks "$dummy_module_path"
  assert_status 0
  assert_output "$expected_hook"
}
