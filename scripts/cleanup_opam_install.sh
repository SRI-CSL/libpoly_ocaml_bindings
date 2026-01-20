#!/usr/bin/env bash
# Remove libpoly files installed by this package, but only if the directory
# contains exactly what we expect. This avoids clobbering user-managed files.
set -euo pipefail

# Resolve opam prefix (environment first, then opam binary).
prefix="${OPAM_SWITCH_PREFIX:-}"
# Bail out if we cannot safely identify the target prefix.
if [[ -z "${prefix}" ]]; then
  if command -v opam >/dev/null 2>&1; then
    prefix="$(opam var prefix)"
  fi
fi

if [[ -z "${prefix}" ]]; then
  echo "Unable to determine opam prefix (OPAM_SWITCH_PREFIX not set and opam not found)." >&2
  exit 1
fi

# We keep package-specific artifacts under $prefix/lib/libpoly.
libdir="${prefix}/lib/libpoly"
# If nothing was installed, there is nothing to clean.
if [[ ! -d "${libdir}" ]]; then
  exit 0
fi

# Refuse to delete if unexpected files are present.
unexpected="$(find "${libdir}" -mindepth 1 -maxdepth 1 \
  ! -name 'libpoly.*' ! -name '__private__' -print)"

# Surface potential conflicts so the user can clean manually.
if [[ -n "${unexpected}" ]]; then
  echo "Not removing ${libdir}; unexpected entries present:" >&2
  echo "${unexpected}" >&2
  exit 1
fi

# Delete known libpoly artifacts and the directory if it is empty.
rm -f "${libdir}/libpoly."*
rmdir "${libdir}/__private__" 2>/dev/null || true
rmdir "${libdir}" 2>/dev/null || true
