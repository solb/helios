# Default target (must come before includes)
.PHONY: all
all: src

#
# Includes
#

-include config.mk
include  external/build.mk
include  toolchain/build.mk
include  src/build.mk

#
# Program variables
#

AR := $(CROSS_COMPILE)-ar
AS := $(CROSS_COMPILE)-as
CC := $(CROSS_COMPILE)-gcc
CP := cp
CPP := $(CROSS_COMPILE)-cpp
LD := $(CROSS_COMPILE)-ld
MD := mkdir -p
PATH := $(abspath $(TOOLCHAIN_DIR)/bin):$(PATH)
OBJCOPY := $(CROSS_COMPILE)-objcopy

#
# Phony targets
#

.PHONY: clean
clean: src-clean

.PHONY: distclean
distclean: clean src-distclean
	$(RM) config.mk

#
# Explicit targets
#

config.mk:
	$(CP) config_template.mk $@
