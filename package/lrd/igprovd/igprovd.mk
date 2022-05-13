#####################################################################
# Laird IG igprovd
#####################################################################

IGPROVD_VERSION = local
IGPROVD_SITE = package/lrd/externals/igprovd
IGPROVD_SITE_METHOD = local
IGPROVD_SETUP_TYPE = setuptools

define IGPROVD_INSTALL_INIT_SYSTEMD
        $(INSTALL) -D -m 644 -t $(TARGET_DIR)/etc/systemd/system \
		    package/lrd/igprovd/igprovd.service
        $(INSTALL) -D -m 644 -t $(TARGET_DIR)/etc/systemd/system \
		    package/lrd/igprovd/edge.service
        $(INSTALL) -D -m 644 -t $(TARGET_DIR)/etc/dbus-1/system.d \
		    package/lrd/igprovd/com.lairdtech.IG.ProvService.conf
endef

$(eval $(python-package))

