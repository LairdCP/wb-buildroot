# Generic Make engine for customer builds
# Customer external repositories should be using this Makefile

BR2_EXTERNAL ?= $(realpath $(MK_DIR))

vigiles_name := $(realpath $(BR_DIR)/../vigiles-buildroot)

ifneq ($(vigiles_name),)
ifneq ($(BR2_EXTERNAL),)
BR2_EXTERNAL := $(addsuffix :$(vigiles_name),$(BR2_EXTERNAL))
else
BR2_EXTERNAL := $(vigiles_name)
endif
endif

export BR2_EXTERNAL

CONFIG_DIR ?= $(realpath $(MK_DIR)/configs)
OUTPUT_DIR ?= $(abspath $(BR_DIR)/output)

TARGETS_ALL = $(TARGETS) $(TARGETS_COMPONENT)

ifeq ($(VERSION),)
release_file = $(OUTPUT_DIR)/$(1)/images/$(1)-laird.tar
else
release_file = $(OUTPUT_DIR)/$(1)/images/$(1)-laird-$(VERSION).tar
endif

ifeq ($(VERSION),)
release_name = $(1)-laird
else
release_name = $(1)-laird-$(VERSION)
endif

.NOTPARALLEL:

.PHONY: all clean cleanall
all: $(TARGETS_ALL)
clean: $(addsuffix -clean,$(TARGETS_ALL))

$(patsubst %,$(OUTPUT_DIR)/%/.config,$(TARGETS_ALL)): $(OUTPUT_DIR)/%/.config: $(CONFIG_DIR)/%_defconfig
	$(MAKE) -C $(BR_DIR) O=$(OUTPUT_DIR)/$* $*_defconfig

.PHONY: $(TARGETS_ALL)
$(TARGETS_ALL): %: $(OUTPUT_DIR)/%/.config
	$(MAKE) -C $(BR_DIR) O=$(OUTPUT_DIR)/$*

.PHONY: $(addsuffix -menuconfig,$(TARGETS_ALL))
$(addsuffix -menuconfig,$(TARGETS_ALL)): %-menuconfig: $(OUTPUT_DIR)/%/.config
	$(MAKE) -C $(BR_DIR) O=$(OUTPUT_DIR)/$* menuconfig

.PHONY: $(addsuffix -savedefconfig,$(TARGETS_ALL))
$(addsuffix -savedefconfig,$(TARGETS_ALL)): %-savedefconfig:
	$(MAKE) -C $(BR_DIR) O=$(OUTPUT_DIR)/$* savedefconfig \
		BR2_DEFCONFIG=$(CONFIG_DIR)/$*_defconfig

.PHONY: $(addsuffix -linux-menuconfig,$(TARGETS))
$(addsuffix -linux-menuconfig,$(TARGETS)): %-linux-menuconfig:
	$(MAKE) -C $(BR_DIR) O=$(OUTPUT_DIR)/$* linux-menuconfig

.PHONY: $(addsuffix -linux-savedefconfig,$(TARGETS))
$(addsuffix -linux-savedefconfig,$(TARGETS)): %-linux-savedefconfig:
	$(MAKE) -C $(BR_DIR) O=$(OUTPUT_DIR)/$* linux-update-defconfig

.PHONY: $(addsuffix -uboot-menuconfig,$(TARGETS))
$(addsuffix -uboot-menuconfig,$(TARGETS)): %-uboot-menuconfig:
	$(MAKE) -C $(BR_DIR) O=$(OUTPUT_DIR)/$* uboot-menuconfig

.PHONY: $(addsuffix -uboot-savedefconfig,$(TARGETS))
$(addsuffix -uboot-savedefconfig,$(TARGETS)): %-uboot-savedefconfig:
	$(MAKE) -C $(BR_DIR) O=$(OUTPUT_DIR)/$* uboot-update-defconfig

.PHONY: $(addsuffix -clean,$(TARGETS_ALL))
$(addsuffix -clean,$(TARGETS_ALL)): %-clean:
	$(MAKE) -C $(BR_DIR) O=$(OUTPUT_DIR)/$* distclean
	rm -rf $(OUTPUT_DIR)/$*

.PHONY: $(addsuffix -sdk,$(TARGETS))
$(addsuffix -sdk,$(TARGETS)): %-sdk: $(OUTPUT_DIR)/%/.config
	$(MAKE) -C $(BR_DIR) O=$(OUTPUT_DIR)/$* BR2_SDK_PREFIX=$@ sdk

.PHONY: $(addsuffix -legal-info,$(TARGETS_ALL))
$(addsuffix -legal-info,$(TARGETS_ALL)): %-legal-info:
	$(MAKE) -C $(BR_DIR) O=$(OUTPUT_DIR)/$* legal-info
	tar --exclude=*sources -C $(OUTPUT_DIR)/$*/legal-info/ \
		--owner=0 --group=0 --numeric-owner \
		-cjf $(OUTPUT_DIR)/$*/images/legal-info.tar.bz2 .

.PHONY: $(addsuffix -vigiles,$(TARGETS))
$(addsuffix -vigiles,$(TARGETS)): %-vigiles:
ifneq ($(vigiles_name),)
	$(MAKE) -C $(OUTPUT_DIR)/$* vigiles-check
endif

.PHONY: $(addsuffix -full,$(TARGETS))
$(addsuffix -full,$(TARGETS)): %-full: % %-legal-info %-sdk
	bzip2 -d $(call release_file,$*).bz2
	tar -C $(OUTPUT_DIR)/$*/images -rf $(call release_file,$*) \
		--owner=0 --group=0 --numeric-owner \
		legal-info.tar.bz2 $*-sdk.tar.gz
	bzip2 $(call release_file,$*)

.PHONY: $(addsuffix -full-legal,$(TARGETS))
$(addsuffix -full-legal,$(TARGETS)): %-full-legal: % %-legal-info
	bzip2 -d $(call release_file,$*).bz2
	tar -C "$(OUTPUT_DIR)/$*/images" -rf $(call release_file,$*) \
		--owner=0 --group=0 --numeric-owner \
		legal-info.tar.bz2
	bzip2 $(call release_file,$*)

.PHONY: $(addsuffix -sdk-only,$(TARGETS))
$(addsuffix -sdk-only,$(TARGETS)): %-sdk-only: $(OUTPUT_DIR)/%/.config
	$(MAKE) -C $(BR_DIR) O=$(OUTPUT_DIR)/$* BR2_SDK_PREFIX=$(call release_name,$*) sdk
	sha256sum $(call release_file,$*).gz | sed 's, .*/, ,' > $(call release_file,$*).gz.sha
