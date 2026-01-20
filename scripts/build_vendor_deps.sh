#!/usr/bin/env bash
# Build and stage a vendored libpoly into a local prefix for dune/ctypes.
# The goal is a reproducible fallback when a system libpoly is unavailable.
set -euo pipefail

# Resolved inputs and optional stamp file for dune caching.
project_root=""
prefix=""
stamp=""

# Parse arguments from dune rules or manual invocation.
while [ $# -gt 0 ]; do
  case "$1" in
    --project-root)
      project_root="$2"
      shift 2
      ;;
    --prefix)
      prefix="$2"
      shift 2
      ;;
    --stamp)
      stamp="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

# project_root is required to find vendor/libpoly and compute default prefixes.
if [ -z "$project_root" ]; then
  echo "Usage: $0 --project-root <path> --prefix <path> [--stamp <path>]" >&2
  exit 2
fi

# Normalize paths early to avoid mixing relative prefixes later.
project_root="$(cd "$project_root" && pwd)"

# Infer platform for OS-specific defaults in include/lib locations.
os_name="$(uname -s 2>/dev/null || echo unknown)"
case "$os_name" in
  Darwin) platform="macos" ;;
  Linux) platform="linux" ;;
  *) platform="unknown" ;;
esac

# Default prefix is a build-local vendor_install directory.
if [ -z "$prefix" ]; then
  prefix="$project_root/_build/vendor_install"
fi

# Ensure prefix is absolute so downstream paths are stable.
if [[ "${prefix:0:1}" != "/" ]]; then
  prefix="$project_root/$prefix"
fi

# Create the prefix and normalize it.
mkdir -p "$prefix"
prefix="$(cd "$prefix" && pwd)"

find_opam_prefix() {
  # Probe OPAM_SWITCH_PREFIX, then opam binary, then ~/.opam config.
  local opam_prefix="${OPAM_SWITCH_PREFIX:-}"
  local opam_cmd=""
  local opam_root opam_switch

  if [[ -z "$opam_prefix" ]]; then
    if command -v opam >/dev/null 2>&1; then
      opam_cmd="$(command -v opam)"
    else
      for candidate in /opt/homebrew/bin/opam /usr/local/bin/opam /opt/local/bin/opam; do
        if [ -x "$candidate" ]; then
          opam_cmd="$candidate"
          break
        fi
      done
    fi
  fi

  if [[ -z "$opam_prefix" ]] && [[ -n "$opam_cmd" ]]; then
    opam_prefix="$($opam_cmd var prefix 2>/dev/null || true)"
  fi
  if [[ -z "$opam_prefix" ]] && [ -f "${HOME:-$project_root}/.opam/config" ]; then
    opam_switch="$(awk -F'"' '/^switch:/ {print $2; exit}' "${HOME:-$project_root}/.opam/config")"
    if [[ -n "$opam_switch" ]]; then
      opam_root="${OPAMROOT:-${HOME:-$project_root}/.opam}"
      opam_prefix="$opam_root/$opam_switch"
    fi
  fi

  if [[ -n "$opam_prefix" ]]; then
    echo "$opam_prefix"
  fi
}

# Prefer pkg-config if available to discover system libpoly.
pkg_config_cmd=""
if command -v pkg-config >/dev/null 2>&1; then
  pkg_config_cmd="pkg-config"
elif command -v pkgconf >/dev/null 2>&1; then
  pkg_config_cmd="pkgconf"
fi

check_system_libpoly() {
  # Compile a tiny C program against libpoly to validate headers+libs.
  local cc tmp_dir c_file exe_file cflags libs pkgconfig_path opam_prefix
  local include_dirs lib_dirs

  cc="${CC:-cc}"
  tmp_dir="$(mktemp -d)"
  c_file="$tmp_dir/has_libpoly.c"
  exe_file="$tmp_dir/has_libpoly"

  # Use a trivial reference to libpoly version symbols to verify headers.
  cat > "$c_file" <<'SRC'
#include <poly/version.h>
int main(void) {
  return LIBPOLY_VERSION_MAJOR;
}
SRC

  # Prefer pkg-config from opam if present, otherwise fall back to common paths.
  opam_prefix="$(find_opam_prefix || true)"
  if [[ -n "$pkg_config_cmd" ]]; then
    pkgconfig_path="${PKG_CONFIG_PATH:-}"
    if [[ -n "$opam_prefix" ]]; then
      pkgconfig_path="${opam_prefix}/lib/pkgconfig${pkgconfig_path:+:${pkgconfig_path}}"
    fi
    if PKG_CONFIG_PATH="$pkgconfig_path" "$pkg_config_cmd" --exists poly.0; then
      cflags="$(PKG_CONFIG_PATH="$pkgconfig_path" "$pkg_config_cmd" --cflags poly.0)"
      libs="$(PKG_CONFIG_PATH="$pkgconfig_path" "$pkg_config_cmd" --libs poly.0)"
    elif PKG_CONFIG_PATH="$pkgconfig_path" "$pkg_config_cmd" --exists poly; then
      cflags="$(PKG_CONFIG_PATH="$pkgconfig_path" "$pkg_config_cmd" --cflags poly)"
      libs="$(PKG_CONFIG_PATH="$pkgconfig_path" "$pkg_config_cmd" --libs poly)"
    fi
  fi

  if [[ -z "${cflags:-}" ]]; then
    # Build include search list, optionally rooted at opam.
    include_dirs=""
    if [[ -n "$opam_prefix" ]] && [ -d "$opam_prefix/include/poly" ]; then
      include_dirs="$opam_prefix/include"
    fi
    if [[ -z "$include_dirs" ]]; then
      case "$platform" in
        macos) include_dirs="/opt/homebrew/include /opt/local/include /usr/local/include" ;;
        *) include_dirs="/usr/local/include /usr/include" ;;
      esac
    fi
    cflags=""
    for dir in $include_dirs; do
      cflags="$cflags -I$dir"
    done
  fi

  if [[ -z "${libs:-}" ]]; then
    # Build library search list, optionally rooted at opam.
    lib_dirs=""
    if [[ -n "$opam_prefix" ]] && [ -d "$opam_prefix/lib" ]; then
      lib_dirs="$opam_prefix/lib"
    fi
    if [[ -z "$lib_dirs" ]]; then
      case "$platform" in
        macos) lib_dirs="/opt/homebrew/lib /opt/local/lib /usr/local/lib" ;;
        *) lib_dirs="/usr/local/lib /usr/lib" ;;
      esac
    fi
    libs=""
    for dir in $lib_dirs; do
      libs="$libs -L$dir"
    done
    libs="$libs -lpoly -lgmp -lm"
  fi

  # Successful compile+link means usable system libpoly.
  if $cc $cflags "$c_file" $libs -o "$exe_file" >/dev/null 2>&1; then
    rm -rf "$tmp_dir"
    return 0
  fi

  rm -rf "$tmp_dir"
  return 1
}

# Skip the vendored build unless explicitly forced.
if [ "${LIBPOLY_FORCE_LOCAL:-}" != "1" ] && check_system_libpoly; then
  echo "Using system libpoly; skipping vendored build."
  touch "$prefix/.keep"
  if [ -n "$stamp" ]; then
    mkdir -p "$(dirname "$stamp")"
    printf '%s\n' "libpoly via system install" > "$stamp"
  fi
  exit 0
fi

# Vendored source tree and target install locations.
libpoly_dir="$project_root/vendor/libpoly"
install_lib="$prefix/lib"
build_root="${VENDOR_BUILD_ROOT:-$PWD/_vendor_build}"
mkdir -p "$build_root"
build_root="$(cd "$build_root" && pwd)"

# Avoid concurrent vendor builds from multiple dune invocations.
lock_dir="$build_root/.vendor_build_lock"
while ! mkdir "$lock_dir" 2>/dev/null; do
  sleep 1
done
trap 'rmdir "$lock_dir"' EXIT

# The submodule must be initialized when using vendored builds.
if [ ! -d "$libpoly_dir" ]; then
  echo "Missing submodule in vendor/. Run: git submodule update --init --recursive" >&2
  exit 1
fi

# If a previous vendored install is already present, re-use it.
if [ -f "$install_lib/libpoly.a" ] && [ -d "$prefix/include/poly" ]; then
  echo "Found vendored libpoly in $prefix; skipping vendored build."
  touch "$prefix/.keep"
  if [ -n "$stamp" ]; then
    mkdir -p "$(dirname "$stamp")"
    printf '%s\n' "libpoly already installed in vendor prefix" > "$stamp"
  fi
  exit 0
fi

# Full vendored build via CMake: shared library plus headers in prefix.
echo "Building vendored libpoly into $prefix"

libpoly_build="$build_root/libpoly"
mkdir -p "$libpoly_build"

# Configure with a minimal feature set (no Python bindings, no tests).
cmake "-S" "$libpoly_dir" "-B" "$libpoly_build" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$prefix" \
  -DLIBPOLY_BUILD_PYTHON_API=OFF \
  -DLIBPOLY_BUILD_STATIC=ON \
  -DLIBPOLY_BUILD_STATIC_PIC=ON \
  -DBUILD_TESTING=OFF

# Build and install into the vendor prefix.
cmake --build "$libpoly_build"
cmake --install "$libpoly_build"

# Generate a minimal pkg-config file for downstream discovery.
pkgconfig_dir="$prefix/lib/pkgconfig"
mkdir -p "$pkgconfig_dir"
version_header="$prefix/include/poly/version.h"
if [ -f "$version_header" ]; then
  # Parse version from installed headers to keep pc file accurate.
  v_major="$(awk '/LIBPOLY_VERSION_MAJOR/{print $3}' "$version_header" | head -n 1)"
  v_minor="$(awk '/LIBPOLY_VERSION_MINOR/{print $3}' "$version_header" | head -n 1)"
  v_patch="$(awk '/LIBPOLY_VERSION_PATCH/{print $3}' "$version_header" | head -n 1)"
  libpoly_version="${v_major}.${v_minor}.${v_patch}"
else
  libpoly_version="0.0.0"
fi
# Keep the pkg-config entry small and self-contained.
cat > "$pkgconfig_dir/poly.0.pc" <<EOPC
prefix=$prefix
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: poly.0
Description: Libpoly library
Version: $libpoly_version
Libs: -L\${libdir} -lpoly -lgmp -lm
Cflags: -I\${includedir}
EOPC

# Add compatibility symlinks expected by downstream tooling.
if [ "$platform" = "macos" ]; then
  if [ -f "$prefix/lib/libpoly.0.dylib" ] && [ ! -f "$prefix/lib/libpoly.dylib" ]; then
    ln -sf "libpoly.0.dylib" "$prefix/lib/libpoly.dylib"
  fi
elif [ "$platform" = "linux" ]; then
  if compgen -G "$prefix/lib/libpoly.so."* > /dev/null && [ ! -f "$prefix/lib/libpoly.so" ]; then
    so_target="$(ls -1 "$prefix/lib/libpoly.so."* | head -n 1)"
    ln -sf "$(basename "$so_target")" "$prefix/lib/libpoly.so"
  fi
fi

# Emit a stamp for dune rules to avoid redundant work.
if [ -n "$stamp" ]; then
  mkdir -p "$(dirname "$stamp")"
  printf '%s\n' "vendored libpoly installed" > "$stamp"
fi
