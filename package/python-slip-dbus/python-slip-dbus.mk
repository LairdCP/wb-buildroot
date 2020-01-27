################################################################################
#
# python-slip-dbus
#
################################################################################

PYTHON_SLIP_DBUS_VERSION_MAJOR = 0.6
PYTHON_SLIP_DBUS_VERSION = $(PYTHON_SLIP_DBUS_VERSION_MAJOR).5
PYTHON_SLIP_DBUS_SOURCE = python-slip-$(PYTHON_SLIP_DBUS_VERSION).tar.gz
PYTHON_SLIP_DBUS_SITE = https://github.com/nphilipp/python-slip/archive
PYTHON_SLIP_DBUS_LICENSE_FILES = COPYING
PYTHON_SLIP_DBUS_DEPENDENCIES = libglib2
PYTHON_SLIP_DBUS_SETUP_TYPE= setuptools
PYTHON_SLIP_DBUS_INSTALL_STAGING= YES
PYTHON_SLIP_DBUS_INSTALL_TARGET= YES

PYTHON_SITE_PACKAGET_PATH := $$(find $(TARGET_DIR)/usr/lib -maxdepth 1 -type d -name python* -printf "%f\n")

ifeq ($(BR2_PACKAGE_PYTHON),y)
PYTHON_SLIP_DBUS_DEPENDENCIES += python host-python
PYTHON_SLIP_DBUS_CONF_ENV = \
        PYTHON=$(HOST_DIR)/bin/python2 \
        PYTHON_INCLUDES="`$(STAGING_DIR)/usr/bin/python2-config --includes`"
else
PYTHON_SLIP_DBUS_DEPENDENCIES += python3 host-python3
PYTHON_SLIP_DBUS_CONF_ENV = \
        PYTHON=$(HOST_DIR)/bin/python3 \
        PYTHON_INCLUDES="`$(STAGING_DIR)/usr/bin/python3-config --includes`"
endif

define COPY_SLIP_OVER
	cp -r $(BUILD_DIR)/python-slip-dbus-$(PYTHON_SLIP_DBUS_VERSION)/slip $(TARGET_DIR)/usr/lib/$(PYTHON_SITE_PACKAGET_PATH)/site-packages/slip
endef

PYTHON_SLIP_DBUS_POST_INSTALL_TARGET_HOOKS= COPY_SLIP_OVER

$(eval $(generic-package))
$(eval $(host-generic-package))
