#!/usr/bin/env bash
set -euo pipefail

prefix="${OPAM_SWITCH_PREFIX:-}"
if [[ -z "${prefix}" ]]; then
  if command -v opam >/dev/null 2>&1; then
    prefix="$(opam var prefix)"
  fi
fi

if [[ -z "${prefix}" ]]; then
  echo "Unable to determine opam prefix (OPAM_SWITCH_PREFIX not set and opam not found)." >&2
  exit 1
fi

echo "Removing vendored libpoly from ${prefix}"

rm -f \
  "${prefix}/lib/libpoly."* \
  "${prefix}/lib/libpolyxx."* \
  "${prefix}/lib/libpicpoly.a" \
  "${prefix}/lib/libpicpolyxx.a" \
  "${prefix}/lib/pkgconfig/poly.0.pc" \
  "${prefix}/lib/pkgconfig/.libpoly_vendored"

rm -rf "${prefix}/include/poly"
