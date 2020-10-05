################################################################################
#
# python-slip-dbus
#
################################################################################

PYTHON_SLIP_DBUS_VERSION = 0.6.5
PYTHON_SLIP_DBUS_SOURCE = python-slip-$(PYTHON_SLIP_DBUS_VERSION).tar.gz
PYTHON_SLIP_DBUS_SITE = https://github.com/nphilipp/python-slip/archive
PYTHON_SLIP_DBUS_LICENSE = GPL-2.0+
PYTHON_SLIP_DBUS_LICENSE_FILES = COPYING
PYTHON_SLIP_DBUS_SETUP_TYPE = distutils
PYTHON_SLIP_DBUS_DEPENDENCIES = python-gobject

define PYTHON_SLIP_DBUS_APPEND_VERSION
	cd $(@D); sed -e 's/@VERSION@/$(PYTHON_SLIP_DBUS_VERSION)/g' setup.py.in > setup.py
endef
PYTHON_SLIP_DBUS_PRE_CONFIGURE_HOOKS += PYTHON_SLIP_DBUS_APPEND_VERSION

$(eval $(python-package))
