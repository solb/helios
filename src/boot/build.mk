#
# Phony targets
#

.PHONY: src-boot
src-boot: $(OBJDIR)/boot/mbr.bin

.PHONY: src-boot-clean
src-boot-clean:
	$(RM) -r $(OBJDIR)/boot

.PHONY: src-boot-distclean
src-boot-distclean: src-boot-clean

#
# Implicit targets
#

$(OBJDIR)/boot/%: ASFLAGS := -m32
$(OBJDIR)/boot/%: LDFLAGS := -nostdlib -Ttext=0x0 -Wl,--section-start=.bootsig=0x1fe -Tdata=0x200 -Wl,-m,elf_i386
