# Generic Make engine for customer builds
# Customer external repositories should be using this Makefile

export BR2_EXTERNAL ?= $(realpath $(MK_DIR))

CONFIG_DIR ?= $(realpath $(MK_DIR)/configs)
OUTPUT_DIR ?= $(abspath $(BR_DIR)/output)

TARGETS_ALL = $(TARGETS) $(TARGETS_COMPONENT)

ifeq ($(LAIRD_RELEASE_STRING),)
release_file = $(OUTPUT_DIR)/$(1)/images/$(1)-laird.tar
else
release_file = $(OUTPUT_DIR)/$(1)/images/$(1)-laird-$(LAIRD_RELEASE_STRING).tar
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

.PHONY: $(addsuffix -linux-menuconfig,$(TARGETS_ALL))
$(addsuffix -linux-menuconfig,$(TARGETS_ALL)): %-linux-menuconfig:
	$(MAKE) -C $(BR_DIR) O=$(OUTPUT_DIR)/$* linux-menuconfig

.PHONY: $(addsuffix -linux-savedefconfig,$(TARGETS_ALL))
$(addsuffix -linux-savedefconfig,$(TARGETS_ALL)): %-linux-savedefconfig:
	$(MAKE) -C $(BR_DIR) O=$(OUTPUT_DIR)/$* linux-update-defconfig

.PHONY: $(addsuffix -uboot-menuconfig,$(TARGETS_ALL))
$(addsuffix -uboot-menuconfig,$(TARGETS_ALL)): %:
	$(MAKE) -C $(BR_DIR) O=$(OUTPUT_DIR)/$* uboot-menuconfig

.PHONY: $(addsuffix -uboot-savedefconfig,$(TARGETS_ALL))
$(addsuffix -uboot-savedefconfig,$(TARGETS_ALL)): %-uboot-savedefconfig:
	$(MAKE) -C $(BR_DIR) O=$(OUTPUT_DIR)/$* uboot-update-defconfig

.PHONY: $(addsuffix -clean,$(TARGETS_ALL))
$(addsuffix -clean,$(TARGETS_ALL)): %-clean:
	$(MAKE) -C $(BR_DIR) O=$(OUTPUT_DIR)/$* distclean
	rm -rf $(OUTPUT_DIR)/$*

.PHONY: $(addsuffix -sdk,$(TARGETS_ALL))
$(addsuffix -sdk,$(TARGETS_ALL)): %-sdk:
	$(MAKE) -C $(BR_DIR) O=$(OUTPUT_DIR)/$* BR2_SDK_PREFIX=$@ sdk

.PHONY: $(addsuffix -sbom-gen,$(TARGETS_ALL))
$(addsuffix -sbom-gen,$(TARGETS_ALL)): %-sbom-gen:
	$(MAKE) -C $(BR_DIR) O=$(OUTPUT_DIR)/$* sbom-gen
	tar --exclude=*sources -C $(OUTPUT_DIR)/$*/legal-info/ \
		-cjf $(OUTPUT_DIR)/$*/images/legal-info.tar.bz2 .

# sbom target always creates legal-info, so legal-info target not really needed
.PHONY: $(addsuffix -legal-info,$(TARGETS_ALL))
$(addsuffix -legal-info,$(TARGETS_ALL)): %-legal-info:
	$(MAKE) -C $(BR_DIR) O=$(OUTPUT_DIR)/$* legal-info
	tar --exclude=*sources -C $(OUTPUT_DIR)/$*/legal-info/ \
		-cjf $(OUTPUT_DIR)/$*/images/legal-info.tar.bz2 .

.PHONY: $(addsuffix -full,$(TARGETS))
$(addsuffix -full,$(TARGETS)): %-full: % %-sbom-gen %-sdk
	bzip2 -d $(call release_file,$*).bz2
	tar -C $(OUTPUT_DIR)/$*/images -rf $(call release_file,$*)\
		legal-info.tar.bz2 host-sbom target-sbom $*-sdk.tar.gz
	bzip2 $(call release_file,$*)

.PHONY: $(addsuffix -full-legal,$(TARGETS))
$(addsuffix -full-legal,$(TARGETS)): %-full-legal: % %-legal-info
	bzip2 -d $(call release_file,$*).bz2
	tar -C "$(OUTPUT_DIR)/$*/images" -rf $(call release_file,$*) \
		legal-info.tar.bz2
	bzip2 $(call release_file,$*)
