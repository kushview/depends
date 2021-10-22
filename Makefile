.NOTPARALLEL :

# Pattern rule to print variables, e.g. make print-top_srcdir
print-%:
	@echo '$*'='$($*)'

# When invoking a sub-make, keep only the command line variable definitions
# matching the pattern in the filter function.
#
# e.g. invoking:
#   $ make A=1 C=1 print-MAKEOVERRIDES print-MAKEFLAGS
#
# with the following in the Makefile:
#   MAKEOVERRIDES := $(filter A=% B=%,$(MAKEOVERRIDES))
#
# will print:
#   MAKEOVERRIDES = A=1
#   MAKEFLAGS = -- A=1
#
# this is because as the GNU make manual says:
#   The command line variable definitions really appear in the variable
#   MAKEOVERRIDES, and MAKEFLAGS contains a reference to this variable.
#
# and since the GNU make manual also says:
#   variables defined on the command line are passed to the sub-make through
#   MAKEFLAGS
#
# this means that sub-makes will be invoked as if:
#   $(MAKE) A=1 blah blah
MAKEOVERRIDES := $(filter V=%,$(MAKEOVERRIDES))
SOURCES_PATH ?= $(BASEDIR)/sources
WORK_PATH = $(BASEDIR)/work
BASE_CACHE ?= $(BASEDIR)/built
SDK_PATH ?= $(BASEDIR)/SDKs
NO_QT ?=
NO_QR ?=
NO_WALLET ?=
NO_ZMQ ?=
NO_UPNP ?=
NO_NATPMP ?=
MULTIPROCESS ?=
FALLBACK_DOWNLOAD_PATH ?= https://bitcoincore.org/depends-sources

BUILD = $(shell ./config.guess)
HOST ?= $(BUILD)
PATCHES_PATH = $(BASEDIR)/patches
BASEDIR = $(CURDIR)
HASH_LENGTH:=11
DOWNLOAD_CONNECT_TIMEOUT:=30
DOWNLOAD_RETRIES:=3
HOST_ID_SALT ?= salt
BUILD_ID_SALT ?= salt

host:=$(BUILD)
ifneq ($(HOST),)
host:=$(HOST)
endif

ifneq ($(DEBUG),)
release_type=debug
else
release_type=release
endif

base_build_dir=$(WORK_PATH)/build
base_staging_dir=$(WORK_PATH)/staging
base_download_dir=$(WORK_PATH)/download
canonical_host:=$(shell ./config.sub $(HOST))
build:=$(shell ./config.sub $(BUILD))

build_arch =$(firstword $(subst -, ,$(build)))
build_vendor=$(word 2,$(subst -, ,$(build)))
full_build_os:=$(subst $(build_arch)-$(build_vendor)-,,$(build))
build_os:=$(findstring linux,$(full_build_os))
build_os+=$(findstring darwin,$(full_build_os))
build_os:=$(strip $(build_os))
ifeq ($(build_os),)
build_os=$(full_build_os)
endif

host_arch=$(firstword $(subst -, ,$(canonical_host)))
host_vendor=$(word 2,$(subst -, ,$(canonical_host)))
full_host_os:=$(subst $(host_arch)-$(host_vendor)-,,$(canonical_host))
host_os:=$(findstring linux,$(full_host_os))
host_os+=$(findstring darwin,$(full_host_os))
host_os+=$(findstring mingw32,$(full_host_os))

ifeq (android,$(findstring android,$(full_host_os)))
host_os:=android
endif

host_os:=$(strip $(host_os))
ifeq ($(host_os),)
host_os=$(full_host_os)
endif

$(host_arch)_$(host_os)_prefix=$(BASEDIR)/$(host)
$(host_arch)_$(host_os)_host=$(host)
host_prefix=$($(host_arch)_$(host_os)_prefix)
build_prefix=$(host_prefix)/native
build_host=$(build)

AT_$(V):=
AT_:=@
AT:=$(AT_$(V))

all: install

include hosts/$(host_os).mk
include hosts/default.mk
include builders/$(build_os).mk
include builders/default.mk
include packages/packages.mk

full_env=$(shell printenv)

build_id_string:=$(BUILD_ID_SALT)

# GCC only prints COLLECT_LTO_WRAPPER when invoked with just "-v", but we want
# the information from "-v -E -" as well, so just include both.
#
# '3>&1 1>&2 2>&3 > /dev/null' is supposed to swap stdin and stdout and silence
# stdin, since we only want the stderr output
build_id_string+=$(shell $(build_CC) -v < /dev/null 3>&1 1>&2 2>&3 > /dev/null) $(shell $(build_CC) -v -E - < /dev/null 3>&1 1>&2 2>&3 > /dev/null)
build_id_string+=$(shell $(build_AR) --version 2>/dev/null) $(filter AR_%,$(full_env)) ZERO_AR_DATE=$(ZERO_AR_DATE)
build_id_string+=$(shell $(build_CXX) -v < /dev/null 3>&1 1>&2 2>&3 > /dev/null) $(shell $(build_CXX) -v -E - < /dev/null 3>&1 1>&2 2>&3 > /dev/null)
build_id_string+=$(shell $(build_RANLIB) --version 2>/dev/null) $(filter RANLIB_%,$(full_env))
build_id_string+=$(shell $(build_STRIP) --version 2>/dev/null) $(filter STRIP_%,$(full_env))

$(host_arch)_$(host_os)_id_string:=$(HOST_ID_SALT)
$(host_arch)_$(host_os)_id_string+=$(shell $(host_CC) -v < /dev/null 3>&1 1>&2 2>&3 > /dev/null) $(shell $(host_CC) -v -E - < /dev/null 3>&1 1>&2 2>&3 > /dev/null)
$(host_arch)_$(host_os)_id_string+=$(shell $(host_AR) --version 2>/dev/null) $(filter AR_%,$(full_env)) ZERO_AR_DATE=$(ZERO_AR_DATE)
$(host_arch)_$(host_os)_id_string+=$(shell $(host_CXX) -v < /dev/null 3>&1 1>&2 2>&3 > /dev/null) $(shell $(host_CXX) -v -E - < /dev/null 3>&1 1>&2 2>&3 > /dev/null)
$(host_arch)_$(host_os)_id_string+=$(shell $(host_RANLIB) --version 2>/dev/null) $(filter RANLIB_%,$(full_env))
$(host_arch)_$(host_os)_id_string+=$(shell $(host_STRIP) --version 2>/dev/null) $(filter STRIP_%,$(full_env))

ifneq ($(strip $(FORCE_USE_SYSTEM_CLANG)),)
# Make sure that cache is invalidated when switching between system and
# depends-managed, pinned clang
build_id_string+=system_clang
$(host_arch)_$(host_os)_id_string+=system_clang
endif

build_id_string+=GUIX_ENVIRONMENT=$(realpath $(GUIX_ENVIRONMENT))
$(host_arch)_$(host_os)_id_string+=GUIX_ENVIRONMENT=$(realpath $(GUIX_ENVIRONMENT))

qrencode_packages_$(NO_QR) = $(qrencode_packages)

qt_packages_$(NO_QT) = $(qt_packages) $(qt_$(host_os)_packages) $(qt_$(host_arch)_$(host_os)_packages) $(qrencode_packages_)

bdb_packages_$(NO_BDB) = $(bdb_packages)
sqlite_packages_$(NO_SQLITE) = $(sqlite_packages)
wallet_packages_$(NO_WALLET) = $(bdb_packages_) $(sqlite_packages_)

upnp_packages_$(NO_UPNP) = $(upnp_packages)
natpmp_packages_$(NO_NATPMP) = $(natpmp_packages)

zmq_packages_$(NO_ZMQ) = $(zmq_packages)
multiprocess_packages_$(MULTIPROCESS) = $(multiprocess_packages)

# packages += $($(host_arch)_$(host_os)_packages) $($(host_os)_packages) $(qt_packages_) $(wallet_packages_) $(upnp_packages_) $(natpmp_packages_)
packages += $($(host_arch)_$(host_os)_packages) $($(host_os)_packages) $(lv2_packages)
native_packages += $($(host_arch)_$(host_os)_native_packages) $($(host_os)_native_packages)

# ifneq ($(zmq_packages_),)
# packages += $(zmq_packages)
# endif

ifeq ($(multiprocess_packages_),)
packages += $(multiprocess_packages)
native_packages += $(multiprocess_native_packages)
endif

all_packages = $(packages) $(native_packages)

meta_depends = Makefile funcs.mk builders/default.mk hosts/default.mk hosts/$(host_os).mk builders/$(build_os).mk

$(host_arch)_$(host_os)_native_binutils?=$($(host_os)_native_binutils)
$(host_arch)_$(host_os)_native_toolchain?=$($(host_os)_native_toolchain)

include funcs.mk

final_build_id_long+=$(shell $(build_SHA256SUM) config.site.in)
final_build_id+=$(shell echo -n "$(final_build_id_long)" | $(build_SHA256SUM) | cut -c-$(HASH_LENGTH))
$(host_prefix)/.stamp_$(final_build_id): $(native_packages) $(packages)
	$(AT)rm -rf $(@D)
	$(AT)mkdir -p $(@D)
	$(AT)echo copying packages: $^
	$(AT)echo to: $(@D)
	$(AT)cd $(@D); $(foreach package,$^, tar xf $($(package)_cached); )
	$(AT)touch $@

# $PATH is not preserved between ./configure and make by convention. Its
# modification and overriding at ./configure time is (as I understand it)
# supposed to be captured by the AC_{PROG_{,OBJ}CXX,PATH_{PROG,TOOL}} macros,
# which will expand the program names to their full absolute paths. The notable
# exception is command line overriding: ./configure CC=clang, which skips the
# program name expansion step, and works because the user implicitly indicates
# with CC=clang that clang will be available in $PATH at all times, and is most
# likely part of the user's system.
#
# Therefore, when we "seed the autoconf cache"/"override well-known program
# vars" by setting AR=<blah> in our config.site, either one of two things needs
# to be true for the build system to work correctly:
#
#   1. If we refer to the program by name (e.g. AR=riscv64-gnu-linux-ar), the
#      tool needs to be available in $PATH at all times.
#
#   2. If the tool is _**not**_ expected to be available in $PATH at all times
#      (such as is the case for our native_cctools binutils tools), it needs to
#      be referred to by its absolute path, such as would be output by the
#      AC_PATH_{PROG,TOOL} macros.
#
# Minor note: it is also okay to refer to tools by their absolute path even if
# we expect them to be available in $PATH at all times, more specificity does
# not hurt.
$(host_prefix)/share/config.site : config.site.in $(host_prefix)/.stamp_$(final_build_id)
	$(AT)@mkdir -p $(@D)
	$(AT)sed -e 's|@HOST@|$(host)|' \
						-e 's|@CC@|$(host_CC)|' \
						-e 's|@CXX@|$(host_CXX)|' \
						-e 's|@AR@|$(host_AR)|' \
						-e 's|@RANLIB@|$(host_RANLIB)|' \
						-e 's|@NM@|$(host_NM)|' \
						-e 's|@STRIP@|$(host_STRIP)|' \
						-e 's|@build_os@|$(build_os)|' \
						-e 's|@host_os@|$(host_os)|' \
						-e 's|@CFLAGS@|$(strip $(host_CFLAGS) $(host_$(release_type)_CFLAGS))|' \
						-e 's|@CXXFLAGS@|$(strip $(host_CXXFLAGS) $(host_$(release_type)_CXXFLAGS))|' \
						-e 's|@CPPFLAGS@|$(strip $(host_CPPFLAGS) $(host_$(release_type)_CPPFLAGS))|' \
						-e 's|@LDFLAGS@|$(strip $(host_LDFLAGS) $(host_$(release_type)_LDFLAGS))|' \
						-e 's|@allow_host_packages@|$(ALLOW_HOST_PACKAGES)|' \
						-e 's|@no_qt@|$(NO_QT)|' \
						-e 's|@no_qr@|$(NO_QR)|' \
						-e 's|@no_zmq@|$(NO_ZMQ)|' \
						-e 's|@no_wallet@|$(NO_WALLET)|' \
						-e 's|@no_upnp@|$(NO_UPNP)|' \
						-e 's|@no_natpmp@|$(NO_NATPMP)|' \
						-e 's|@multiprocess@|$(MULTIPROCESS)|' \
						-e 's|@debug@|$(DEBUG)|' \
						$< > $@
	$(AT)touch $@

$(host_prefix)/share/config.json : config.json.in $(host_prefix)/share/config.site
	$(AT)@mkdir -p $(@D)
	$(AT)sed -e 's|@HOST@|$(host)|' \
				-e 's|@CC@|$(host_CC)|' \
				-e 's|@CXX@|$(host_CXX)|' \
				-e 's|@AR@|$(host_AR)|' \
				-e 's|@RANLIB@|$(host_RANLIB)|' \
				-e 's|@NM@|$(host_NM)|' \
				-e 's|@STRIP@|$(host_STRIP)|' \
				-e 's|@build_os@|$(build_os)|' \
				-e 's|@host_os@|$(host_os)|' \
				-e 's|@CFLAGS@|$(strip $(host_CFLAGS) $(host_$(release_type)_CFLAGS))|' \
				-e 's|@CXXFLAGS@|$(strip $(host_CXXFLAGS) $(host_$(release_type)_CXXFLAGS))|' \
				-e 's|@CPPFLAGS@|$(strip $(host_CPPFLAGS) $(host_$(release_type)_CPPFLAGS))|' \
				-e 's|@LDFLAGS@|$(strip $(host_LDFLAGS) $(host_$(release_type)_LDFLAGS))|' \
				-e 's|@allow_host_packages@|$(ALLOW_HOST_PACKAGES)|' \
				-e 's|@no_qt@|$(NO_QT)|' \
				-e 's|@no_qr@|$(NO_QR)|' \
				-e 's|@no_zmq@|$(NO_ZMQ)|' \
				-e 's|@no_wallet@|$(NO_WALLET)|' \
				-e 's|@no_upnp@|$(NO_UPNP)|' \
				-e 's|@no_natpmp@|$(NO_NATPMP)|' \
				-e 's|@multiprocess@|$(MULTIPROCESS)|' \
				-e 's|@debug@|$(DEBUG)|' \
				$< > $@
	$(AT)touch $@

define check_or_remove_cached
	mkdir -p $(BASE_CACHE)/$(host)/$(package) && cd $(BASE_CACHE)/$(host)/$(package); \
	$(build_SHA256SUM) -c $($(package)_cached_checksum) >/dev/null 2>/dev/null || \
	( rm -f $($(package)_cached_checksum); \
		if test -f "$($(package)_cached)"; then echo "Checksum mismatch for $(package). Forcing rebuild.."; rm -f $($(package)_cached_checksum) $($(package)_cached); fi )
endef

define check_or_remove_sources
	mkdir -p $($(package)_source_dir); cd $($(package)_source_dir); \
	test -f $($(package)_fetched) && ( $(build_SHA256SUM) -c $($(package)_fetched) >/dev/null 2>/dev/null || \
		( echo "Checksum missing or mismatched for $(package) source. Forcing re-download."; \
			rm -f $($(package)_all_sources) $($(1)_fetched))) || true
endef

check-packages:
	@$(foreach package,$(all_packages),$(call check_or_remove_cached,$(package));)
check-sources:
	@$(foreach package,$(all_packages),$(call check_or_remove_sources,$(package));)

$(host_prefix)/share/config.site: check-packages

check-packages: check-sources

clean-all: clean
	@rm -rf $(SOURCES_PATH) x86_64* i686* mips* arm* aarch64* powerpc* riscv32* riscv64* s390x* universal*

clean:
	@rm -rf $(WORK_PATH) $(BASE_CACHE) $(BUILD)

install: check-packages $(host_prefix)/share/config.site $(host_prefix)/share/config.json

lipo:
	@python3 $(BASEDIR)/lipo.py

download-one: check-sources $(all_sources)

download-osx:
	@$(MAKE) -s HOST=x86_64-apple-darwin download-one
download-linux:
	@$(MAKE) -s HOST=x86_64-unknown-linux-gnu download-one
download-win:
	@$(MAKE) -s HOST=x86_64-w64-mingw32 download-one
download: download-osx download-linux download-win

$(foreach package,$(all_packages),$(eval $(call ext_add_stages,$(package))))

.PHONY: install cached clean clean-all download-one download-osx download-linux download-win download check-packages check-sources
