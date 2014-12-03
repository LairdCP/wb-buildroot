#############################################################
#
# at91bootstrap3
#
################################################################################

AT91BOOTSTRAP3_VERSION = v3.7.1
AT91BOOTSTRAP3_SITE = $(call github,linux4sam,at91bootstrap,$(AT91BOOTSTRAP3_VERSION))

AT91BOOTSTRAP3_INSTALL_IMAGES = YES
AT91BOOTSTRAP3_INSTALL_TARGET = NO

AT91BOOTSTRAP3_DEFCONFIG = \
	$(call qstrip,$(BR2_TARGET_AT91BOOTSTRAP3_DEFCONFIG))
AT91BOOTSTRAP3_CUSTOM_CONFIG_FILE = \
	$(call qstrip,$(BR2_TARGET_AT91BOOTSTRAP3_CUSTOM_CONFIG_FILE))
AT91BOOTSTRAP3_CUSTOM_PATCH_DIR = \
	$(call qstrip,$(BR2_TARGET_AT91BOOTSTRAP3_CUSTOM_PATCH_DIR))

AT91BOOTSTRAP3_MAKE_OPTS = CROSS_COMPILE=$(TARGET_CROSS) DESTDIR=$(BINARIES_DIR)

ifneq ($(AT91BOOTSTRAP3_CUSTOM_PATCH_DIR),)
define AT91BOOTSTRAP3_REMOVE_SPECIFIC_PATCHES
	rm -fv boot/at91bootstrap3/at91bootstrap3-u-boot-relocation-fix.patch
endef
define AT91BOOTSTRAP3_APPLY_CUSTOM_PATCHES
	support/scripts/apply-patches.sh $(@D) $(AT91BOOTSTRAP3_CUSTOM_PATCH_DIR) \
		at91bootstrap3-\*.patch
endef
AT91BOOTSTRAP3_PRE_PATCH_HOOKS += AT91BOOTSTRAP3_REMOVE_SPECIFIC_PATCHES
AT91BOOTSTRAP3_POST_PATCH_HOOKS += AT91BOOTSTRAP3_APPLY_CUSTOM_PATCHES
endif

ifeq ($(BR2_TARGET_AT91BOOTSTRAP3_USE_DEFCONFIG),y)
define AT91BOOTSTRAP3_CONFIGURE_CMDS
	$(MAKE) $(AT91BOOTSTRAP3_MAKE_OPTS) -C $(@D) $(AT91BOOTSTRAP3_DEFCONFIG)_defconfig
endef
else ifeq ($(BR2_TARGET_AT91BOOTSTRAP3_USE_CUSTOM_CONFIG),y)
define AT91BOOTSTRAP3_CONFIGURE_CMDS
	cp $(BR2_TARGET_AT91BOOTSTRAP3_CUSTOM_CONFIG_FILE) $(@D)/.config
endef
endif

define AT91BOOTSTRAP3_BUILD_CMDS
	$(MAKE) $(AT91BOOTSTRAP3_MAKE_OPTS) -C $(@D)
endef

AT91BOOTSTRAP3_BIN_FILE = $(call qstrip,$(BR2_LRD_PLATFORM))-nandflashboot-uboot.bin
ifeq ($(call qstrip,$(BR2_LRD_PLATFORM)),wb45n)
AT91BOOTSTRAP3_BIN_FILE = at91sam9x5ek-nandflashboot-uboot.bin
endif

define AT91BOOTSTRAP3_INSTALL_IMAGES_CMDS
	$(INSTALL) -m 644 $(@D)/binaries/$(AT91BOOTSTRAP3_BIN_FILE) \
	                  $(BINARIES_DIR)/$(call qstrip,$(BR2_LRD_PLATFORM)).bin
endef

$(eval $(generic-package))

# Checks to give errors that the user can understand
ifeq ($(filter source,$(MAKECMDGOALS)),)
ifeq ($(BR2_TARGET_AT91BOOTSTRAP3_USE_DEFCONFIG),y)
ifeq ($(AT91BOOTSTRAP3_DEFCONFIG),)
$(error No at91bootstrap3 defconfig name specified, check your BR2_TARGET_AT91BOOTSTRAP3_DEFCONFIG setting)
endif
endif

ifeq ($(BR2_TARGET_AT91BOOTSTRAP3_USE_CUSTOM_CONFIG),y)
ifeq ($(AT91BOOTSTRAP3_CUSTOM_CONFIG_FILE),)
$(error No at91bootstrap3 configuration file specified, check your BR2_TARGET_AT91BOOTSTRAP3_CUSTOM_CONFIG_FILE setting)
endif
endif
endif
