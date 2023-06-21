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
This expects the libpoly library to be present in the relevant paths (e.g. `/usr/local/lib`), and likewise for its header files (e.g. `/usr/local/include`). If for some reason they are not in the usual paths, you can specify the paths by setting 
the environment variables `LDFLAGS` and `C_INCLUDE_PATH`, e.g.:

```
export LDFLAGS="-L[UNCONVENTIONAL_PATH]"
export C_INCLUDE_PATH="[UNCONVENTIONAL_PATH]"
```

#### Without opam

Besides libpoly, the bindings need some OCaml dependencies, that are listed in `libpoly_bindings.opam`. These are the findlib libraries that are / would be installed by opam, and that you can still install automatically with

```
opam install . --deps-only
```

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