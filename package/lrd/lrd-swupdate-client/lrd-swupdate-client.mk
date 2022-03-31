################################################################################
#
# lrd-swupdate-client
#
################################################################################

LRD_SWUPDATE_CLIENT_VERSION = local
LRD_SWUPDATE_CLIENT_SITE = package/lrd/externals/lrd-userspace-examples/swclient
LRD_SWUPDATE_CLIENT_SITE_METHOD = local
LRD_SWUPDATE_CLIENT_SETUP_TYPE = setuptools
LRD_SWUPDATE_CLIENT_DEPENDENCIES = swupdate

$(eval $(python-package))
