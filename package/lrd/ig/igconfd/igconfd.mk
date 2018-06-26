#####################################################################
# Laird Industrial Gateway igconfd
#####################################################################

IGCONFD_VERSION = local
IGCONFD_SITE = package/lrd/externals/ig/igconfd
IGCONFD_SITE_METHOD = local
IGCONFD_SETUP_TYPE = setuptools
IGCONFD_BUILD_OPTS = bdist_egg --exclude-source-files

define IGCONFD_INSTALL_TARGET_FILES
        $(INSTALL) -D -m 755 $(@D)/dist/igconfd-1.0-py2.7.egg $(TARGET_DIR)/usr/bin/igconfd
        $(INSTALL) -D -m 755 package/lrd/ig/igconfd/S97igconfd $(TARGET_DIR)/etc/init.d
endef

IGCONFD_POST_INSTALL_TARGET_HOOKS += IGCONFD_INSTALL_TARGET_FILES

$(eval $(python-package))

