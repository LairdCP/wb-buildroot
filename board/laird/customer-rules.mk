# Generic Make engine for customer builds
# Customer external repositories should be using this Makefile

BUILDROOT_MENU_SUFFIX = -menuconfig
BUILDROOT_SAVE_SUFFIX = -savedefconfig

LINUX_MENU_SUFFIX = -linux-menuconfig
LINUX_SAVE_SUFFIX = -linux-savedefconfig

UBOOT_MENU_SUFFIX = -uboot-menuconfig
UBOOT_SAVE_SUFFIX = -uboot-savedefconfig

CLEAN_PREFIX = clean-

BUILDROOT_MENU = $(addsuffix $(BUILDROOT_MENU_SUFFIX),$(TARGETS))
BUILDROOT_SAVE = $(addsuffix $(BUILDROOT_SAVE_SUFFIX),$(TARGETS))

LINUX_MENU = $(addsuffix $(LINUX_MENU_SUFFIX),$(TARGETS))
LINUX_SAVE = $(addsuffix $(LINUX_SAVE_SUFFIX),$(TARGETS))

UBOOT_MENU = $(addsuffix $(UBOOT_MENU_SUFFIX),$(TARGETS))
UBOOT_SAVE = $(addsuffix $(UBOOT_SAVE_SUFFIX),$(TARGETS))

TARGETS_CLEAN  = $(addprefix $(CLEAN_PREFIX),$(TARGETS))

strip_target = $(subst $(1),,$@)

all: $(TARGETS)

clean cleanall: $(TARGETS_CLEAN)

$(TARGETS):
	# first check/do config, because can't use $@ in dependency
	$(MAKE) -C buildroot O=output/$@ $@_defconfig
	$(MAKE) -C buildroot O=output/$@

$(BUILDROOT_MENU):
	$(MAKE) -C buildroot O=output/$(call strip_target,$(BUILDROOT_MENU_SUFFIX)) menuconfig

$(BUILDROOT_SAVE):
	$(MAKE) -C buildroot O=output/$(call strip_target,$(BUILDROOT_SAVE_SUFFIX)) savedefconfig \
		BR2_DEFCONFIG=$(BR2_EXTERNAL)/configs/$(call strip_target,$(BUILDROOT_SAVE_SUFFIX))_defconfig

$(LINUX_MENU):
	$(MAKE) -C buildroot O=output/$(call strip_target,$(LINUX_MENU_SUFFIX)) linux-menuconfig

$(LINUX_SAVE):
	$(MAKE) -C buildroot O=output/$(call strip_target,$(LINUX_SAVE_SUFFIX)) linux-update-defconfig

$(UBOOT_MENU):
	$(MAKE) -C buildroot O=output/$(call strip_target,$(UBOOT_MENU_SUFFIX)) uboot-menuconfig

$(UBOOT_SAVE):
	$(MAKE) -C buildroot O=output/$(call strip_target,$(UBOOT_SAVE_SUFFIX)) uboot-update-defconfig

$(TARGETS_CLEAN):
	$(MAKE) -C buildroot O=output/$(call strip_target,$(CLEAN_PREFIX)) distclean

.PHONY: all clean cleanall \
	$(TARGETS) $(TARGETS_CLEAN) $(BUILDROOT_MENU) $(BUILDROOT_SAVE) \
	$(LINUX_MENU) $(LINUX_SAVE) $(UBOOT_MENU) $(UBOOT_SAVE)
