################################################################################
#
# toolchain-external-laird-arm
#
################################################################################

TOOLCHAIN_EXTERNAL_LAIRD_ARM_VERSION = 2018.02-2
TOOLCHAIN_EXTERNAL_LAIRD_ARM_SITE = https://toolchains.bootlin.com/downloads/releases/toolchains/armv7-eabihf/tarballs

TOOLCHAIN_EXTERNAL_LAIRD_ARM_SOURCE = armv7-eabihf--glibc--stable-$(TOOLCHAIN_EXTERNAL_LAIRD_ARM_VERSION).tar.bz2

$(eval $(toolchain-external-package))
