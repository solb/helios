#
# Includes
#

include src/boot/build.mk

#
# Phony targets
#

.PHONY: src
src: src-boot

.PHONY: src-clean
src-clean: src-boot-clean

.PHONY: src-distclean
src-distclean: src-clean src-boot-distclean

#
# Implicit targets
#

.PRECIOUS: %.elf
%.elf: %.o
	$(CC) $(LDFLAGS) $^ -o $@ $(LOADLIBES) $(LDLIBS)

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

$(OBJDIR)/%: src/%
	$(MD) $(@D)
	$(CP) $< $@
