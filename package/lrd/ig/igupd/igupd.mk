#####################################################################
# Laird Industrial Gateway igupd
#####################################################################

IGUPD_VERSION = local
IGUPD_SITE = package/lrd/externals/ig/igupd
IGUPD_SITE_METHOD = local
IGUPD_SETUP_TYPE = setuptools
IGUPD_BUILD_OPTS = bdist_egg --exclude-source-files

define IGUPD_INSTALL_TARGET_FILES
	$(INSTALL) -D -m 755 $(@D)/dist/igupd-1.0-py2.7.egg $(TARGET_DIR)/usr/bin/igupd
	$(INSTALL) -D -m 755 package/lrd/ig/igupd/S98igupd $(TARGET_DIR)/etc/init.d
endef

IGUPD_POST_INSTALL_TARGET_HOOKS += IGUPD_INSTALL_TARGET_FILES

$(eval $(python-package))
