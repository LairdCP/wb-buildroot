#####################################################################
# DBus Proxy Service
#####################################################################

DBPROXYSVC_VERSION = local
DBPROXYSVC_SITE = package/lrd/externals/ig/dbproxysvc
DBPROXYSVC_SITE_METHOD = local
DBPROXYSVC_SETUP_TYPE = setuptools
DBPROXYSVC_BUILD_OPTS = bdist_egg --exclude-source-files

DBPROXYSVC_POST_INSTALL_TARGET_HOOKS += DBPROXYSVC_INSTALL_TARGET_FILES

define DBPROXYSVC_INSTALL_TARGET_FILES
	$(INSTALL) -D -m 755 $(@D)/dist/dbproxysvc-1.0-py2.7.egg $(TARGET_DIR)/usr/bin/dbproxysvc
	$(INSTALL) -D -m 755 package/lrd/ig/dbproxysvc/S40dbproxysvc $(TARGET_DIR)/etc/init.d
endef

$(eval $(python-package))
