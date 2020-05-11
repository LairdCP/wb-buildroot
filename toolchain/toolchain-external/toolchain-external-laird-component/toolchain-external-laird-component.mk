################################################################################
#
# toolchain-external-laird-component
#
################################################################################

TOOLCHAIN_EXTERNAL_LAIRD_COMPONENT_VERSION = 2020.05
TOOLCHAIN_EXTERNAL_LAIRD_COMPONENT_SOURCE = $(call qstrip,$(BR2_TOOLCHAIN_EXTERNAL_PREFIX)).tar.xz

ifeq ($(MSD_BINARIES_SOURCE_LOCATION),laird_internal)
TOOLCHAIN_EXTERNAL_LAIRD_COMPONENT_SITE = https://files.devops.rfpros.com/tools/toolchain/$(BR2_PACKAGE_PROVIDES_TOOLCHAIN_EXTERNAL)
else
TOOLCHAIN_EXTERNAL_LAIRD_COMPONENT_SITE = https://github.com/LairdCP/wb-package-archive/releases/download/LRD-REL-$(TOOLCHAIN_EXTERNAL_LAIRD_COMPONENT_VERSION)
endif

$(eval $(toolchain-external-package))
