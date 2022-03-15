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

FIPSCHECK_DEPENDENCIES += openssl host-pkgconf
FIPSCHECK_AUTORECONF = YES

HOST_FIPSCHECK_DEPENDENCIES += host-openssl host-pkgconf
HOST_FIPSCHECK_AUTORECONF = YES

$(eval $(autotools-package))
$(eval $(host-autotools-package))
