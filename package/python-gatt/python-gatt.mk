PYTHON_GATT_VERSION = 0.2.7
PYTHON_GATT_SOURCE = $(PYTHON_GATT_VERSION).tar.gz
PYTHON_GATT_SITE = $(call github,getsenic,gatt-python,f9d955756b0b8aff0d30cb335602d977535f6298)
PYTHON_GATT_LICENSE = MIT
PYTHON_GATT_LICENSE_FILES = LICENSE
PYTHON_GATT_SETUP_TYPE = setuptools

$(eval $(python-package))
