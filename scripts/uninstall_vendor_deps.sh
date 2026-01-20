#!/usr/bin/env bash
# Remove vendored libpoly artifacts from the opam prefix.
# This mirrors what install_vendor_deps.sh copies in.
set -euo pipefail

# Resolve the opam prefix (environment first, then opam binary).
prefix="${OPAM_SWITCH_PREFIX:-}"
# Without a prefix we cannot safely remove anything.
if [[ -z "${prefix}" ]]; then
  if command -v opam >/dev/null 2>&1; then
    prefix="$(opam var prefix)"
  fi
fi

if [[ -z "${prefix}" ]]; then
  echo "Unable to determine opam prefix (OPAM_SWITCH_PREFIX not set and opam not found)." >&2
  exit 1
fi

# Keep the log message explicit so users know what is being removed.
echo "Removing vendored libpoly from ${prefix}"

# Remove libraries and the vendored pkg-config marker.
rm -f \
  "${prefix}/lib/libpoly."* \
  "${prefix}/lib/libpolyxx."* \
  "${prefix}/lib/libpicpoly.a" \
  "${prefix}/lib/libpicpolyxx.a" \
  "${prefix}/lib/pkgconfig/poly.0.pc" \
  "${prefix}/lib/pkgconfig/.libpoly_vendored"

# Remove vendored headers.
rm -rf "${prefix}/include/poly"
