#####################################################################
# Laird Industrial Gateway deviced
#####################################################################

DEVICED_VERSION = local
DEVICED_SITE = package/lrd/externals/ig/deviced
DEVICED_SITE_METHOD = local
DEVICED_SETUP_TYPE = setuptools
DEVICED_BUILD_OPTS = bdist_egg --exclude-source-files

define DEVICED_INSTALL_TARGET_FILES
        $(INSTALL) -D -m 755 $(@D)/dist/deviced-1.0-py2.7.egg $(TARGET_DIR)/usr/bin/deviced
        $(INSTALL) -D -m 755 package/lrd/ig/deviced/S98deviced $(TARGET_DIR)/etc/init.d
endef

DEVICED_POST_INSTALL_TARGET_HOOKS += DEVICED_INSTALL_TARGET_FILES

$(eval $(python-package))

