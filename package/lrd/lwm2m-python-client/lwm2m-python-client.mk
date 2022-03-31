#####################################################################
# LwM2M Python Client
#####################################################################

LWM2M_PYTHON_CLIENT_VERSION = 0.2
LWM2M_PYTHON_CLIENT_SITE = package/lrd/externals/lwm2m_python_client
LWM2M_PYTHON_CLIENT_SITE_METHOD = local
LWM2M_PYTHON_CLIENT_SETUP_TYPE = setuptools
LWM2M_PYTHON_CLIENT_BUILD_OPTS = bdist_egg --exclude-source-files

define LWM2M_PYTHON_CLIENT_INSTALL_TARGET_CMDS
        $(INSTALL) -D -m 755 $(@D)/dist/lwm2m_python_client-$(LWM2M_PYTHON_CLIENT_VERSION)-py$(PYTHON3_VERSION_MAJOR).egg $(TARGET_DIR)/usr/bin/lwm2m-python-client
        $(INSTALL) -D -m 755 $(@D)/ig60_fw_update.sh $(TARGET_DIR)/usr/bin/ig60_fw_update.sh
        $(INSTALL) -D -m 755 $(@D)/ig60_lwm2m_client.sh $(TARGET_DIR)/usr/bin/ig60_lwm2m_client.sh
endef

$(eval $(python-package))

