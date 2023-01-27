################################################################################
#
# python-cherrypy
#
################################################################################

PYTHON_CHERRYPY_VERSION = 18.6.1
PYTHON_CHERRYPY_SOURCE = CherryPy-$(PYTHON_CHERRYPY_VERSION).tar.gz
PYTHON_CHERRYPY_SITE = https://files.pythonhosted.org/packages/c6/0d/f6acfd12f098b9f05b9146b79b5a3fad02f4047a7831b5f5c9ee3fe54d56
PYTHON_CHERRYPY_LICENSE = BSD-3-Clause
PYTHON_CHERRYPY_LICENSE_FILES = LICENSE.md
PYTHON_CHERRYPY_SETUP_TYPE = setuptools
PYTHON_CHERRYPY_DEPENDENCIES = host-python-setuptools-scm

$(eval $(python-package))
