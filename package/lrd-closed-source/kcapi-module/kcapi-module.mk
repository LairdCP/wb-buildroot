#############################################################
#
#  KCAPI MODULE
#
#############################################################

KCAPI_MODULE_VERSION = local

ifeq ($(BR2_PACKAGE_PARSER_ACVP),y)
KCAPI_MODULE_SITE    = package/lrd-closed-source/externals/cavs_api/acvpparser/backend_interfaces/kcapi
else
KCAPI_MODULE_SITE    = package/lrd-closed-source/externals/cavs_api/kcapi-cavs
endif

KCAPI_MODULE_SITE_METHOD = local

$(eval $(kernel-module))
$(eval $(generic-package))
