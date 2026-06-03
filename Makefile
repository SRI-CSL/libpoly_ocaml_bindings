.PHONY: default build install install-with-local-libpoly uninstall reinstall test test-with-local-libpoly clean with-local-libpoly pin-deps opam-deps

OPAM_SWITCH_PREFIX ?= $(shell opam var prefix 2>/dev/null)
CTYPES_ZARITH_PIN ?= git+https://github.com/SRI-CSL/ctypes-zarith.git
export OPAM_SWITCH_PREFIX

default: build

build:
	dune build

with-local-libpoly:
	LIBPOLY_FORCE_LOCAL=1 dune build

pin-deps:
	opam pin add ctypes-zarith.0.2.0 "$(CTYPES_ZARITH_PIN)" -y

opam-deps: pin-deps
	opam install . --deps-only

test:
	DYLD_LIBRARY_PATH="$(OPAM_SWITCH_PREFIX)/lib:$(PWD)/_build/default/vendor_install/lib$${DYLD_LIBRARY_PATH:+:$${DYLD_LIBRARY_PATH}}" \
	LD_LIBRARY_PATH="$(OPAM_SWITCH_PREFIX)/lib:$(PWD)/_build/default/vendor_install/lib$${LD_LIBRARY_PATH:+:$${LD_LIBRARY_PATH}}" \
	dune build @runtest

test-with-local-libpoly:
	DYLD_LIBRARY_PATH="$(OPAM_SWITCH_PREFIX)/lib:$(PWD)/_build/default/vendor_install/lib$${DYLD_LIBRARY_PATH:+:$${DYLD_LIBRARY_PATH}}" \
	LD_LIBRARY_PATH="$(OPAM_SWITCH_PREFIX)/lib:$(PWD)/_build/default/vendor_install/lib$${LD_LIBRARY_PATH:+:$${LD_LIBRARY_PATH}}" \
	LIBPOLY_FORCE_LOCAL=1 \
	dune build @runtest

install:
	# Build vendored libpoly and copy it to the opam prefix first, so
	# the OCaml archive picks up the opam libdir instead of build paths.
	dune build @vendor_deps
	./scripts/install_vendor_deps.sh --from-prefix _build/default/vendor_install
	# Force a fresh configurator run with the opam libpoly now in place.
	dune clean
	dune build @install
	dune install

install-with-local-libpoly:
	LIBPOLY_FORCE_LOCAL=1 $(MAKE) install

reinstall: uninstall install

uninstall:
	./scripts/dune_uninstall_quiet.sh
	./scripts/cleanup_opam_install.sh
	./scripts/uninstall_vendor_deps.sh

clean:
	dune clean
