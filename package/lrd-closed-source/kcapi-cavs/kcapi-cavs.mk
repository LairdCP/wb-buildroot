#############################################################
#
#  KCAPI CAVS
#
#############################################################

KCAPI_CAVS_VERSION = local
KCAPI_CAVS_SITE    = package/lrd-closed-source/externals/cavs_api/kcapi-cavs
KCAPI_CAVS_SITE_METHOD = local

$(eval $(kernel-module))
$(eval $(generic-package))
