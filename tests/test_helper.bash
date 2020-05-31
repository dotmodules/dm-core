setup_file() {
  DM__TEST__TEST_DIR="${BATS_TMPDIR}/dm"
  export DM__TEST__TEST_DIR="$( \
    mktemp -d "${DM__TEST__TEST_DIR}.XXX" 2>/dev/null || echo "$DM__TEST__TEST_DIR" \
  )"
  mkdir -p "${DM__TEST__TEST_DIR}"
  echo ">> temp directory created: '${DM__TEST__TEST_DIR}'" >&3
}

teardown_file() {
  echo ">> deleting temp directory: '${DM__TEST__TEST_DIR}'" >&3
  rm -rf "$DM__TEST__TEST_DIR"
}
