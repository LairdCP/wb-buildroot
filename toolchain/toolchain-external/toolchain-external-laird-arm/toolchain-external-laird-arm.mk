################################################################################
#
# toolchain-external-laird-arm
#
################################################################################

TOOLCHAIN_EXTERNAL_LAIRD_ARM_VERSION = 7.0.0.276
TOOLCHAIN_EXTERNAL_LAIRD_ARM_SITE = https://files.devops.rfpros.com/builds/linux/toolchain/$(TOOLCHAIN_EXTERNAL_LAIRD_ARM_VERSION)
TOOLCHAIN_EXTERNAL_LAIRD_ARM_SOURCE = som60_toolchain-laird-$(TOOLCHAIN_EXTERNAL_LAIRD_ARM_VERSION).tar.gz

$(eval $(toolchain-external-package))
