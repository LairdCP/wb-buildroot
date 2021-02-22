#############################################################
#
# FIPS Check Utility
#
#############################################################

FIPSCHECK_VERSION = local
FIPSCHECK_SITE = package/lrd/externals/fipscheck
FIPSCHECK_SITE_METHOD = local
FIPSCHECK_LICENSE = MIT
FIPSCHECK_LICENSE_FILES = COPYING

FIPSCHECK_DEPENDENCIES = openssl
FIPSCHECK_AUTORECONF = YES

HOST_FIPSCHECK_DEPENDENCIES = host-openssl
HOST_FIPSCHECK_AUTORECONF = YES

define FIPSCHECK_CREATE_M4_DIR
	mkdir -p $(@D)/m4
endef

FIPSCHECK_PRE_CONFIGURE_HOOKS += FIPSCHECK_CREATE_M4_DIR
HOST_FIPSCHECK_PRE_CONFIGURE_HOOKS += FIPSCHECK_CREATE_M4_DIR

$(eval $(autotools-package))
$(eval $(host-autotools-package))
