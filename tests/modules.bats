load ../src/dm.lib
load helpers/mocks/stub
load helpers/assert/load
load helpers/support/load


@test "dummy_test" {
  lib__imre() { echo "imre"; }

  run lib__bela
  assert [ $status -eq 0 ]
  assert_output "imre"
}


