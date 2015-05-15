#
# Variables
#

TOOLCHAIN_EXTERNALS := binutils gcc newlib
TRIPLE_TYPE-binutils := target
TRIPLE_TYPE-gcc := target
TRIPLE_TYPE-newlib := host

#
# Phony targets
#

.PHONY: toolchain
toolchain: toolchain-disambiguate-cross-compile $(patsubst %,$(TOOLCHAIN_DIR)/install-%.stamp,$(TOOLCHAIN_EXTERNALS))

.PHONY: toolchain-clean
toolchain-clean:
	$(RM) -r $(addprefix toolchain/,$(TOOLCHAIN_EXTERNALS))

.PHONY: toolchain-distclean
toolchain-distclean: toolchain-clean
	$(RM) -r $(TOOLCHAIN_DIR)

.PHONY: toolchain-disambiguate-cross-compile
toolchain-disambiguate-cross-compile: external/binutils/config.sub
	[ $(CROSS_COMPILE) = $(shell $< $(CROSS_COMPILE)) ]

#
# Implicit targets
#

toolchain/%/Makefile: external/%/configure
	$(MD) $(@D)
	cd $(@D) && ../../external/$*/configure --prefix=$(abspath $(TOOLCHAIN_DIR)) \
			--$(TRIPLE_TYPE-$*)=$(CROSS_COMPILE) $(CFGFLAGS) $(CFGFLAGS-$*)

toolchain/%/build.stamp: toolchain/%/Makefile
	$(MAKE) -C $(@D)
	touch $@

$(TOOLCHAIN_DIR)/install-%.stamp: toolchain/%/build.stamp
	$(MAKE) -C $(<D) install
	touch $@

#
# Explicit targets
#

# Add pregenerated scanner before attempting to build gcc.
toolchain/gcc/build.stamp: external/gcc/gcc/gengtype-lex.c

#
# Special targets
#

.SECONDARY: external/binutils/config.sub
.SECONDARY: $(patsubst %,external/%/configure,$(TOOLCHAIN_EXTERNALS))
.SECONDARY: $(patsubst %,toolchain/%/Makefile,$(TOOLCHAIN_EXTERNALS))
