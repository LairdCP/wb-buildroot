#############################################################
#
# FIPS Check Utility
#
#############################################################

FIPS_CHECK_VERSION = local
FIPS_CHECK_SITE = package/lrd/externals/fipscheck
FIPS_CHECK_SITE_METHOD = local
FIPS_CHECK_LICENSE = MIT
FIPS_CHECK_LICENSE_FILES = COPYING

FIPS_CHECK_DEPENDENCIES = openssl
FIPS_CHECK_AUTORECONF = YES

define FIPS_CHECK_CREATE_M4_DIR
	mkdir -p $(@D)/m4
endef

FIPS_CHECK_PRE_CONFIGURE_HOOKS += FIPS_CHECK_CREATE_M4_DIR

FIPS_CHECK_INSTALL_TARGET_OPTS = DESTDIR=$(TARGET_DIR) install-exec

$(eval $(autotools-package))
