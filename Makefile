# =======================================================================================
#  MAKE SETTINGS

.DEFAULT_GOAL := help
NAME := DOTMODULES


# =======================================================================================
#  HELP COMMAND

.PHONY: help
help:
	@echo ""
	@echo "-------------------------------------------------------------------"
	@echo "  $(NAME) make interface "
	@echo "-------------------------------------------------------------------"
	@echo ""
	@echo "   init              Initializes the repository's dependencies."
	@echo "   help              Prints out this help message."
	@echo "   test              Runs the test suite."
	@echo ""


# =======================================================================================
#  TEST COMMAND

.PHONY: init
init:
	@git submodule update --init --recursive

.PHONY: test
test:
	@./tests/run.sh
