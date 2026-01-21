.PHONY: default build install uninstall reinstall test clean with-local-libpoly

OPAM_SWITCH_PREFIX ?= $(shell opam var prefix 2>/dev/null)
export OPAM_SWITCH_PREFIX

default: build

build:
	dune build

with-local-libpoly:
	LIBPOLY_FORCE_LOCAL=1 dune build

test:
	DYLD_LIBRARY_PATH="$(OPAM_SWITCH_PREFIX)/lib:$(PWD)/_build/default/vendor_install/lib$${DYLD_LIBRARY_PATH:+:$${DYLD_LIBRARY_PATH}}" \
	LD_LIBRARY_PATH="$(OPAM_SWITCH_PREFIX)/lib:$(PWD)/_build/default/vendor_install/lib$${LD_LIBRARY_PATH:+:$${LD_LIBRARY_PATH}}" \
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

reinstall: uninstall install

uninstall:
	./scripts/dune_uninstall_quiet.sh
	./scripts/cleanup_opam_install.sh
	./scripts/uninstall_vendor_deps.sh

clean:
	dune clean
