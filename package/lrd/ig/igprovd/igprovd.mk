#####################################################################
# Laird Industrial Gateway igprovd
#####################################################################

IGPROVD_VERSION = local
IGPROVD_SITE = package/lrd/externals/ig/igprovd
IGPROVD_SITE_METHOD = local
IGPROVD_SETUP_TYPE = setuptools
IGPROVD_BUILD_OPTS = bdist_egg --exclude-source-files

IGPROVD_POST_INSTALL_TARGET_HOOKS += IGPROVD_INSTALL_TARGET_FILES

define IGPROVD_INSTALL_TARGET_FILES
	$(INSTALL) -D -m 755 $(@D)/dist/igprovd-1.0-py2.7.egg $(TARGET_DIR)/usr/bin/igprovd
	$(INSTALL) -D -m 755 $(@D)/ggconf $(TARGET_DIR)/usr/bin
	$(INSTALL) -D -m 755 package/lrd/ig/igprovd/S96igprovd $(TARGET_DIR)/etc/init.d
endef

$(eval $(python-package))
