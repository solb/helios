#
# Phony targets
#

.PHONY: external
external:
	git submodule update --init

.PHONY: external-clean
external-clean:
	git submodule deinit .

.PHONY: external-forceclean
external-forceclean:
	git submodule deinit -f .

#
# Implicit targets
#

.PRECIOUS: external/%
external/%:
	git submodule update --init $(@D)

#
# Explicit targets
#

# gcc doesn't ship its generated scanner, so we copy in the one distributed with the project's
# official release tarball. Any targets that need to build the project should depend on this.
.INTERMEDIATE: external/gcc/gcc/gengtype-lex.c
external/gcc/gcc/gengtype-lex.c: external/gcc-5.1.0/gcc/gengtype-lex.c
	$(CP) $< $@
