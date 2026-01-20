#!/usr/bin/env bash
# Install vendored libpoly into the opam switch prefix.
# This copies headers/libs and rewrites pkg-config paths for a usable install.
set -euo pipefail

# Source (vendored) prefix and destination (opam) prefix.
from_prefix=""
prefix=""

# Parse explicit prefixes so the script can be called from dune or make.
while [ $# -gt 0 ]; do
  case "$1" in
    --from-prefix)
      from_prefix="$2"
      shift 2
      ;;
    --prefix)
      prefix="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

# from_prefix is required: it points at the vendored install.
if [ -z "$from_prefix" ]; then
  echo "Usage: $0 --from-prefix <path> --prefix <path>" >&2
  exit 2
fi

# Destination prefix defaults to the current opam switch.
if [ -z "$prefix" ]; then
  if [ -n "${OPAM_SWITCH_PREFIX:-}" ]; then
    prefix="$OPAM_SWITCH_PREFIX"
  elif command -v opam >/dev/null 2>&1; then
    prefix="$(opam var prefix 2>/dev/null || true)"
  fi
fi

# Fail early if no opam switch can be discovered.
if [ -z "$prefix" ]; then
  echo "Missing install prefix (opam switch not detected)." >&2
  exit 1
fi

# Paths inside the vendored prefix.
from_lib="$from_prefix/lib"
from_inc="$from_prefix/include"

# Vendored build may not exist if system libpoly was used.
if [ ! -d "$from_lib" ] || [ ! -d "$from_inc" ]; then
  echo "No vendored libpoly install found at $from_prefix; skipping install."
  exit 0
fi

# Ensure target directories exist.
mkdir -p "$prefix/lib" "$prefix/include" "$prefix/lib/pkgconfig"

copy_lib() {
  # Copy matching libs into the opam prefix with write permissions.
  local pattern="$1"
  local found=0
  for lib in $pattern; do
    if [ -f "$lib" ]; then
      rm -f "$prefix/lib/$(basename "$lib")"
      cp "$lib" "$prefix/lib/"
      chmod u+w "$prefix/lib/$(basename "$lib")"
      found=1
    fi
  done
  return $found
}

# Shared and static artifacts (when present).
copy_lib "$from_lib/libpoly.*" || true
copy_lib "$from_lib/libpolyxx.*" || true
copy_lib "$from_lib/libpicpoly.a" || true
copy_lib "$from_lib/libpicpolyxx.a" || true

if [ -d "$from_inc/poly" ]; then
  # Replace header tree to match the vendored build.
  rm -rf "$prefix/include/poly"
  cp -R "$from_inc/poly" "$prefix/include/"
  chmod -R u+w "$prefix/include/poly"
fi

if [ -f "$from_lib/pkgconfig/poly.0.pc" ]; then
  # Rewrite paths so pkg-config reports the opam prefix.
  tmp_pc="$(mktemp)"
  sed -e "s|^prefix=.*|prefix=$prefix|" \
      -e "s|^exec_prefix=.*|exec_prefix=\\${prefix}|" \
      -e "s|^libdir=.*|libdir=\\${prefix}/lib|" \
      -e "s|^includedir=.*|includedir=\\${prefix}/include|" \
      "$from_lib/pkgconfig/poly.0.pc" > "$tmp_pc"
  rm -f "$prefix/lib/pkgconfig/poly.0.pc"
  {
    echo "# Installed by libpoly vendored build"
    cat "$tmp_pc"
  } > "$prefix/lib/pkgconfig/poly.0.pc"
  chmod u+w "$prefix/lib/pkgconfig/poly.0.pc"
  rm -f "$tmp_pc"
fi

marker="$prefix/lib/pkgconfig/.libpoly_vendored"
rm -f "$marker"
: > "$marker"
chmod u+w "$marker"

# macOS needs install-name fixups; Linux just needs a symlink.
os_name="$(uname -s 2>/dev/null || echo unknown)"
case "$os_name" in
  Darwin)
    if [ -f "$prefix/lib/libpoly.0.dylib" ] && [ ! -f "$prefix/lib/libpoly.dylib" ]; then
      ln -sf "libpoly.0.dylib" "$prefix/lib/libpoly.dylib"
    fi
    # Fix absolute install names from the vendored build and patch stubs.
    if command -v otool >/dev/null 2>&1 && command -v install_name_tool >/dev/null 2>&1; then
      fix_install_name() {
        # Update the library's install name, then patch any dependent stubs.
        local lib_path="$1"
        local old_install_name new_install_name ocaml_libdir

        [ -f "$lib_path" ] || return 0
        old_install_name="$(otool -D "$lib_path" 2>/dev/null | awk 'NR==2 {print $1}' || true)"
        new_install_name="$lib_path"
        if [ -z "$old_install_name" ] || [ "$old_install_name" = "$new_install_name" ]; then
          return 0
        fi

        install_name_tool -id "$new_install_name" "$lib_path"

        # If libpolyxx links against libpoly's old install name, fix it directly.
        if [ "$lib_path" = "$prefix/lib/libpoly.0.dylib" ] && [ -f "$prefix/lib/libpolyxx.0.dylib" ]; then
          if otool -L "$prefix/lib/libpolyxx.0.dylib" 2>/dev/null | grep -Fq "$old_install_name"; then
            chmod u+w "$prefix/lib/libpolyxx.0.dylib" 2>/dev/null || true
            install_name_tool -change "$old_install_name" "$new_install_name" "$prefix/lib/libpolyxx.0.dylib"
          fi
        fi

        # Patch OCaml stubs in both opam prefix and the ocamlc libdir.
        ocaml_libdir="$(ocamlc -where 2>/dev/null || true)"
        fixup_dirs=("$prefix/lib/stublibs" "$prefix/lib/libpoly")
        if [ -n "$ocaml_libdir" ]; then
          fixup_dirs+=("$ocaml_libdir/stublibs" "$ocaml_libdir/libpoly")
        fi
        for dir in "${fixup_dirs[@]}"; do
          [ -d "$dir" ] || continue
          while IFS= read -r -d '' candidate; do
            if otool -L "$candidate" 2>/dev/null | grep -Fq "$old_install_name"; then
              chmod u+w "$candidate" 2>/dev/null || true
              install_name_tool -change "$old_install_name" "$new_install_name" "$candidate"
            fi
          done < <(find "$dir" -type f \( -name "*.so" -o -name "*.dylib" \) -print0)
        done
      }

      fix_install_name "$prefix/lib/libpoly.0.dylib"
      fix_install_name "$prefix/lib/libpolyxx.0.dylib"
    fi
    ;;
  Linux)
    if compgen -G "$prefix/lib/libpoly.so."* > /dev/null && [ ! -f "$prefix/lib/libpoly.so" ]; then
      so_target="$(ls -1 "$prefix/lib/libpoly.so."* | head -n 1)"
      ln -sf "$(basename "$so_target")" "$prefix/lib/libpoly.so"
    fi
    ;;
esac

echo "Installed vendored libpoly from $from_prefix to $prefix"
