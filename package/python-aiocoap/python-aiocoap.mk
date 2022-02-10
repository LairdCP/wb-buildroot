################################################################################
#
# python-aiocoap
#
################################################################################

PYTHON_AIOCOAP_VERSION = 0.4.3
PYTHON_AIOCOAP_SOURCE = aiocoap-$(PYTHON_AIOCOAP_VERSION).tar.gz
PYTHON_AIOCOAP_SITE = https://files.pythonhosted.org/packages/de/7f/1b324936e63e6a22e22f8abcfb1e0b8a6e7fc4655216a17889520254529f
PYTHON_AIOCOAP_SETUP_TYPE = setuptools
PYTHON_AIOCOAP_LICENSE = MIT
PYTHON_AIOCOAP_LICENSE_FILES = LICENSE

$(eval $(python-package))
