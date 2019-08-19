################################################################################
#
# backports regression test
#
################################################################################


BACKPORTS_TEST_VERSION = $(call qstrip,$(BR2_PACKAGE_LINUX_BACKPORTS_VERSION))
ifeq ($(BACKPORTS_TEST_VERSION),)
BACKPORTS_TEST_VERSION = 0.$(BR2_LRD_BRANCH).0.0
endif

BACKPORTS_TEST_SOURCE = backports-laird-$(BACKPORTS_TEST_VERSION).tar.bz2
BR_NO_CHECK_HASH_FOR += $(BACKPORTS_TEST_SOURCE)
BACKPORTS_TEST_LICENSE = GPL-2.0
BACKPORTS_TEST_LICENSE_FILES = COPYING
BACKPORTS_TEST_SITE_METHOD = wget

ifeq ($(MSD_BINARIES_SOURCE_LOCATION),laird_internal)
  BACKPORTS_TEST_SITE = http://devops.lairdtech.com/share/builds/linux/backports/laird/$(BACKPORTS_TEST_VERSION)
else
  BACKPORTS_TEST_SITE = https://github.com/LairdCP/wb-package-archive/releases/download/LRD-REL-$(BACKPORTS_TEST_VERSION)
endif

define HOST_BACKPORTS_TEST_BUILD_CMDS
	cd $(@D) \
		&& ../../../../package/lrd/externals/backports/devel/backports-update-manager --yes \
		&& ../../../../package/lrd/externals/backports/devel/ckmake --develdebug --nocurses \
		&& ../../../../package/lrd/externals/backports/devel/ckmake --defconfig=regression-test --nocurses
endef

$(eval $(host-generic-package))
