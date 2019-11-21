################################################################################
#
# python-cherrypy
#
################################################################################

PYTHON_CHERRYPY_VERSION = 18.4.0
PYTHON_CHERRYPY_SOURCE = CherryPy-$(PYTHON_CHERRYPY_VERSION).tar.gz
PYTHON_CHERRYPY_SITE = https://pypi.python.org/packages/90/9f/c45f5a6508764369971c04de098359c5b8e2ed4850b8b536ee02f3f80fff
PYTHON_CHERRYPY_LICENSE = BSD-3-Clause
PYTHON_CHERRYPY_LICENSE_FILES = LICENSE.md
PYTHON_CHERRYPY_SETUP_TYPE = setuptools
PYTHON_CHERRYPY_DEPENDENCIES = host-python-setuptools-scm

$(eval $(python-package))
