#####################################################################
# LwM2M Python Client
#####################################################################

LWM2M_PYTHON_CLIENT_VERSION = 0.1
LWM2M_PYTHON_CLIENT_SITE = package/lrd/externals/lwm2m_python_client
LWM2M_PYTHON_CLIENT_SITE_METHOD = local
LWM2M_PYTHON_CLIENT_SETUP_TYPE = setuptools
LWM2M_PYTHON_CLIENT_BUILD_OPTS = bdist_egg --exclude-source-files

LWM2M_PYTHON_CLIENT_PYTHON_VERSION := 3.7

define LWM2M_PYTHON_CLIENT_INSTALL_TARGET_CMDS
        $(INSTALL) -D -m 755 $(@D)/dist/lwm2m_python_client-$(LWM2M_PYTHON_CLIENT_VERSION)-py$(LWM2M_PYTHON_CLIENT_PYTHON_VERSION).egg $(TARGET_DIR)/usr/bin/lwm2m-python-client
        $(INSTALL) -D -m 755 $(@D)/ig60_fw_update.sh $(TARGET_DIR)/usr/bin/ig60_fw_update.sh
endef

$(eval $(python-package))

