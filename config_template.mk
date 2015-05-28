ASFLAGS :=
CFGFLAGS := --disable-shared --disable-nls
CFGFLAGS-binutils := --disable-gdb --with-sysroot
CFGFLAGS-gcc := --disable-libquadmath --disable-libssp --enable-languages=c --without-headers
CFGFLAGS-newlib := --with-newlib --disable-multilib CFLAGS="-nostdlib"
CFLAGS := -Og -g3 -std=c99 -Werror -Wall -Wextra -Wpedantic -Wbuiltin-macro-redefined -Wcast-qual \
          -Wfloat-equal -Wformat=2 -Wjump-misses-init -Wmissing-include-dirs -Wmissing-prototypes \
          -Wstrict-prototypes -Wundef -Wwrite-strings
CPPFLAGS :=
CROSS_COMPILE := x86_64-pc-elf
LDFLAGS :=
LDLIBS :=
TOOLCHAIN_DIR := toolchain/dist
