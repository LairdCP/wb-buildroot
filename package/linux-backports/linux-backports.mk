################################################################################
#
# linux-backports
#
################################################################################

LINUX_BACKPORTS_VERSION = 6.0.0.7

LINUX_BACKPORTS_SOURCE = backports-laird-$(LINUX_BACKPORTS_VERSION).tar.bz2
BR_NO_CHECK_HASH_FOR += $(LINUX_BACKPORTS_SOURCE)
LINUX_BACKPORTS_LICENSE = GPL-2.0
LINUX_BACKPORTS_LICENSE_FILES = COPYING
LINUX_BACKPORTS_SITE = http://devops.lairdtech.com/share/builds/linux/backports/laird/$(LINUX_BACKPORTS_VERSION)
LINUX_BACKPORTS_SITE_METHOD = wget

ifeq ($(BR2_PACKAGE_LINUX_BACKPORTS_USE_DEFCONFIG),y)
LINUX_BACKPORTS_KCONFIG_FILE = $(LINUX_BACKPORTS_DIR)/defconfigs/$(call qstrip,$(BR2_PACKAGE_LINUX_BACKPORTS_DEFCONFIG))
else ifeq ($(BR2_PACKAGE_LINUX_BACKPORTS_USE_CUSTOM_CONFIG),y)
LINUX_BACKPORTS_KCONFIG_FILE = $(call qstrip,$(BR2_PACKAGE_LINUX_BACKPORTS_CUSTOM_CONFIG_FILE))
endif

# linux-backports' build system expects the config options to be present
# in the environment, and it is so when using their custom buildsystem,
# because they are set in the main Makefile, which then calls a second
# Makefile.
#
# In our case, we do not use that first Makefile. So, we parse the
# .config file, filter-out comment lines and put the rest as command
# line variables.
#
# LINUX_BACKPORTS_MAKE_OPTS is used by the kconfig-package infra, while
# LINUX_BACKPORTS_MODULE_MAKE_OPTS is used by the kernel-module infra.
#
LINUX_BACKPORTS_MAKE_OPTS = \
	BACKPORT_DIR=$(@D) \
	KLIB_BUILD=$(LINUX_DIR) \
	KLIB=$(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED) \
	INSTALL_MOD_DIR=backports \
	`sed -r -e '/^\#/d;' $(@D)/.config`

LINUX_BACKPORTS_DEPENDENCIES += linux
LINUX_BACKPORTS_KCONFIG_EDITORS = menuconfig xconfig gconfig
LINUX_BACKPORTS_KCONFIG_OPTS = $(LINUX_BACKPORTS_MAKE_OPTS)
LINUX_BACKPORTS_BUILD_CONFIG = $(@D)/.config


# Checks to give errors that the user can understand
ifeq ($(BR_BUILDING),y)

ifeq ($(BR2_PACKAGE_LINUX_BACKPORTS_USE_DEFCONFIG),y)
ifeq ($(call qstrip,$(BR2_PACKAGE_LINUX_BACKPORTS_DEFCONFIG)),)
$(error No linux-backports defconfig name specified, check your BR2_PACKAGE_LINUX_BACKPORTS_DEFCONFIG setting)
endif
endif

ifeq ($(BR2_PACKAGE_LINUX_BACKPORTS_USE_CUSTOM_CONFIG),y)
ifeq ($(call qstrip,$(BR2_PACKAGE_LINUX_BACKPORTS_CUSTOM_CONFIG_FILE)),)
$(error No linux-backports configuration file specified, check your BR2_PACKAGE_LINUX_BACKPORTS_CUSTOM_CONFIG_FILE setting)
endif
endif

endif # BR_BUILDING

define	LINUX_BACKPORTS_PRE_PATCH_CMDS
	test ! -f $(@D)/.config && \
		CROSS_COMPILE=$(TARGET_CROSS) KLIB_BUILD=$(LINUX_DIR) ARCH=$(ARCH) $(MAKE) -C $(@D) defconfig-$(BR2_PACKAGE_LINUX_BACKPORTS_DEFCONFIG)
endef
LINUX_BACKPORTS_PRE_PATCH_HOOKS += LINUX_BACKPORTS_PRE_PATCH_CMDS

#define LINUX_BACKPORTS_CONFIGURE_CMDS
#CROSS_COMPILE=$(TARGET_CROSS) KLIB_BUILD=$(LINUX_DIR) ARCH=$(ARCH) $(MAKE) -C $(@D) defconfig-$(BR2_PACKAGE_LINUX_BACKPORTS_DEFCONFIG)
#endef

define LINUX_BACKPORTS_BUILD_CMDS
	cd $(@D) && make ARCH=$(ARCH) CROSS_COMPILE=$(TARGET_CROSS) KLIB_BUILD=$(LINUX_DIR)
endef

KLIB=$(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED)

define LINUX_BACKPORTS_INSTALL_TARGET_CMDS
	cd $(@D) && find ./ -name *.ko | xargs tar cf laird-backport-ko.tar \
	&& mv laird-backport-ko.tar $(KLIB)/kernel/ -f
	cd $(KLIB)/kernel && tar xf laird-backport-ko.tar && rm laird-backport-ko.tar -fr;
	depmod -b $(TARGET_DIR) $(LINUX_VERSION_PROBED)
endef

$(eval $(kconfig-package))

# linux-backports' own .config file needs options from the kernel's own
# .config file. The dependencies handling in the infrastructure does not
# allow to express this kind of dependencies. Besides, linux.mk might
# not have been parsed yet, so the Linux build dir LINUX_DIR is not yet
# known. Thus, we use a "secondary expansion" so the rule is re-evaluated
# after all Makefiles are parsed, and thus at that time we will have the
# LINUX_DIR variable set to the proper value.
#
# Furthermore, we want to check the kernel version, since linux-backports
# only supports kernels >= 3.0. To avoid overriding linux-backports'
# .config rule defined in the kconfig-package infra, we use an
# intermediate stamp-file.
#
# Finally, it must also come after the call to kconfig-package, so we get
# LINUX_BACKPORTS_DIR properly defined (because the target part of the
# rule is not re-evaluated).
#
$(LINUX_BACKPORTS_DIR)/.config: $(LINUX_BACKPORTS_DIR)/.stamp_check_kernel_version

.SECONDEXPANSION:
$(LINUX_BACKPORTS_DIR)/.stamp_check_kernel_version: $$(LINUX_DIR)/.config
	$(Q)LINUX_VERSION_PROBED=$(LINUX_VERSION_PROBED); \
	if [ $${LINUX_VERSION_PROBED%%.*} -lt 3 ]; then \
		printf "Linux version '%s' is too old for linux-backports (needs 3.0 or later)\n" \
			"$${LINUX_VERSION_PROBED}"; \
		exit 1; \
	fi
	$(Q)touch $(@)
