# =======================================================================================
#  M A K E   S E T T I N G S

.DEFAULT_GOAL := help
NAME := DOTMODULES


# =======================================================================================
#  H E L P   C O M M A N D

.PHONY: help
help:
	@echo ""
	@echo "-------------------------------------------------------------------"
	@echo "  $(NAME) make interface "
	@echo "-------------------------------------------------------------------"
	@echo ""
	@echo "   help              Prints out this help message."
	@echo "   test              Runs the test suite."
	@echo ""


# =======================================================================================
#  T E S T   C O M M A N D
#
.PHONY: assert_test_environment
assert_test_environment:
	@./utils/init_submodules.sh

.PHONY: test
test: assert_test_environment
	@./tests/run.sh
