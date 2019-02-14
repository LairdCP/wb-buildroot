################################################################################
#
# python3-gobject
#
################################################################################

PYTHON3_GOBJECT_VERSION_MAJOR = 3.28
PYTHON3_GOBJECT_VERSION = $(PYTHON3_GOBJECT_VERSION_MAJOR).3
PYTHON3_GOBJECT_SOURCE = pygobject-$(PYTHON3_GOBJECT_VERSION).tar.xz
PYTHON3_GOBJECT_SITE = http://ftp.gnome.org/pub/gnome/sources/pygobject/$(PYTHON3_GOBJECT_VERSION_MAJOR)
PYTHON3_GOBJECT_LICENSE = LGPL-2.1+
PYTHON3_GOBJECT_LICENSE_FILES = COPYING
PYTHON3_GOBJECT_DEPENDENCIES = host-pkgconf libglib2 gobject-introspection
PYTHON3_GOBJECT_CONF_OPTS= --enable-shared --enable-cairo=no
PYTHON3_GOBJECT_AUTORECONF = YES

PYTHON3_GOBJECT_DEPENDENCIES += python3 host-python3

PYTHON3_GOBJECT_CONF_ENV = \
	PYTHON=$(HOST_DIR)/bin/python3 \
	PYTHON_INCLUDES="`$(STAGING_DIR)/usr/bin/python3-config --includes`"

ifeq ($(BR2_PACKAGE_LIBFFI),y)
PYTHON3_GOBJECT_CONF_OPTS += --with-ffi
PYTHON3_GOBJECT_DEPENDENCIES += libffi
else
PYTHON3_GOBJECT_CONF_OPTS += --without-ffi
endif

SO_FILEPATH := $$(find $(TARGET_DIR)/usr/lib -name "gi")

define PYTHON3_GOBJECT_FIX_TARGET
	cd $(SO_FILEPATH) && ln -sf _gi.cpython*.so _gi.so
endef

PYTHON3_GOBJECT_POST_INSTALL_TARGET_HOOKS += PYTHON3_GOBJECT_FIX_TARGET

$(eval $(autotools-package))
