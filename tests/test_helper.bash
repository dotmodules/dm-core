
# guard against executing this block twice due to bats internals
if [ -z "$DM__TEST__TEST_DIR" ]; then
  DM__TEST__TEST_DIR="${BATS_TMPDIR}/dm"
  export DM__TEST__TEST_DIR="$(mktemp -d "${DM__TEST__TEST_DIR}.XXXXX" 2>/dev/null || echo "$DM__TEST__TEST_DIR")"
fi

teardown() {
  rm -rf "$DM__TEST__TEST_DIR"
}
