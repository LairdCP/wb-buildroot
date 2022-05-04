################################################################################
#
# python-pyudev
#
################################################################################

PYTHON_PYUDEV_VERSION = 0.23.2
PYTHON_PYUDEV_SOURCE = pyudev-$(PYTHON_PYUDEV_VERSION).tar.gz
PYTHON_PYUDEV_SITE = https://files.pythonhosted.org/packages/f8/fa/ae6c1a1a75f19560bbd875a579b2ca9b32deeae6a4c4a1997f4ec69a013e
PYTHON_PYUDEV_LICENSE = LGPL-2.1+
PYTHON_PYUDEV_LICENSE_FILES = COPYING
PYTHON_PYUDEV_SETUP_TYPE = setuptools

$(eval $(python-package))
