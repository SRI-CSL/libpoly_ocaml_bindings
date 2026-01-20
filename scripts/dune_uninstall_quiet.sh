#!/usr/bin/env bash
# Run `dune uninstall` while hiding known, noisy warnings.
# This keeps opam remove output clean but still fails on real errors.
set -euo pipefail

# Capture dune stderr for filtering and cleanup on exit.
tmp_log="$(mktemp)"
filtered_log=""
cleanup() {
  rm -f "${tmp_log}" "${filtered_log}"
}
trap cleanup EXIT

status=0
# Try uninstall; if dune can't find .install files, rebuild them and retry.
if ! dune uninstall 2> "${tmp_log}"; then
  status=$?
  if grep -q "following <package>\.install are missing" "${tmp_log}"; then
    if dune build @install >/dev/null 2>&1; then
      if ! dune uninstall 2> "${tmp_log}"; then
        status=$?
      else
        status=0
      fi
    fi
  fi
fi

filtered_log="$(mktemp)"
# Drop expected/unactionable messages (non-empty directories, missing files).
grep -v -E "Directory .* is not empty|Error: Directory .* is not|cannot delete \(ignoring\)\.|delete \(ignoring\)\.|cannot be installed because they do not exist|^Error: The following files which are listed in .*\.install|^- _build/install/" "${tmp_log}" > "${filtered_log}" || true

if [ "$status" -ne 0 ]; then
  # If there is still a meaningful error, surface it.
  if [ -s "${filtered_log}" ]; then
    cat "${filtered_log}" >&2
    exit "$status"
  else
    exit 0
  fi
fi

# Successful uninstall: print any remaining warnings for visibility.
cat "${filtered_log}" >&2 || true
