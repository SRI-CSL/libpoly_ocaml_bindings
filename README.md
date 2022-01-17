[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

# OCaml bindings for libpoly

This repository provides an ocaml library containing bindings for libpoly ([http://sri-csl.github.io/libpoly/](http://sri-csl.github.io/libpoly/)).

## Building and Installing From Source

Make sure you have gmp.

#### Using opam (needs 2.0 or higher)

In the directory of this `README.md`, build and install (in findlib) with the following command:

```
opam install .
```
This expects the libpoly library to be present in the relevant paths (like `/usr/local/lib`). If for some reason these libraries are not in the usual paths, you can specify their paths by setting 
the environment variables `LDFLAGS` (for the libpoly library), e.g.:

```
export LDFLAGS="-L[UNCONVENTIONAL_PATH]"
```

#### Without opam

Besides libpoly, the bindings need some OCaml dependencies, that are listed in `libpoly_bindings.opam`. These are the findlib libraries that are / would be installed by opam, and that you can still install automatically with

```
opam install . --deps-only
```
These dependencies are namely: `ocamlbuild`, `ctypes`, `ctypes-foreign`, `ppx_deriving`, `ppx_optcomp`, `sexplib`, `sexplib0`, and, for gmp support, `zarith`, and `ctypes-zarith`.

To build, run the following command:
```
make
```
in the directory of this `README.md`.

To install (in findlib), run the following command:
```
make install
```

You can also use `make reinstall` and `make clean`.