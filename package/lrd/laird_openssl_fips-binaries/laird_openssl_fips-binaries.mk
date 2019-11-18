###############################################################################
#
# laird_openssl_fips (openssl 1.0.2) binaries
#
# this package is selected through buildroot/packages/openssl
#
################################################################################

ifneq ($(BR2_LRD_DEVEL_BUILD),)
LAIRD_OPENSSL_FIPS_BINARIES_VERSION = 0.$(BR2_LRD_BRANCH).0.0
else
LAIRD_OPENSSL_FIPS_BINARIES_VERSION = $(call qstrip,$(BR2_PACKAGE_LAIRD_OPENSSL_FIPS_BINARIES_VERSION_VALUE))
endif

LAIRD_OPENSSL_FIPS_BINARIES_SOURCE =
LAIRD_OPENSSL_FIPS_BINARIES_LICENSE = OpenSSL or SSLeay
LAIRD_OPENSSL_FIPS_BINARIES_EXTRA_DOWNLOADS = laird_openssl_fips-arm-eabihf-$(LAIRD_OPENSSL_FIPS_BINARIES_VERSION).tar.bz2

ifeq ($(MSD_BINARIES_SOURCE_LOCATION),laird_internal)
  LAIRD_OPENSSL_FIPS_BINARIES_SITE = https://files.devops.lairdtech.com/builds/linux/summit_supplicant/laird/$(LAIRD_OPENSSL_FIPS_BINARIES_VERSION)
else
  LAIRD_OPENSSL_FIPS_BINARIES_SITE = https://github.com/LairdCP/wb-package-archive/releases/download/LRD-REL-$(LAIRD_OPENSSL_FIPS_BINARIES_VERSION)
endif

define LAIRD_OPENSSL_FIPS_BINARIES_INSTALL_TARGET_CMDS
	tar -xjvf $($(PKG)_DL_DIR)/$(LAIRD_OPENSSL_FIPS_BINARIES_EXTRA_DOWNLOADS) -C $(TARGET_DIR) --keep-directory-symlink --no-overwrite-dir --touch --strip-components=1 target
	tar -xjvf $($(PKG)_DL_DIR)/$(LAIRD_OPENSSL_FIPS_BINARIES_EXTRA_DOWNLOADS) -C $(STAGING_DIR) --keep-directory-symlink --no-overwrite-dir --touch --strip-components=1 staging
endef

ifeq ($(BR2_PACKAGE_LIBOPENSSL_BIN),)
define LAIRD_OPENSSL_FIPS_BINARIES_REMOVE_BIN
	$(RM) -f $(TARGET_DIR)/usr/bin/openssl
	$(RM) -f $(TARGET_DIR)/etc/ssl/misc/{CA.*,c_*}
endef
LAIRD_OPENSSL_FIPS_BINARIES_POST_INSTALL_TARGET_HOOKS += LAIRD_OPENSSL_FIPS_BINARIES_REMOVE_BIN
endif

$(eval $(generic-package))
