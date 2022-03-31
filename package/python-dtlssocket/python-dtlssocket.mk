################################################################################
#
# python-dtlssocket
#
################################################################################

PYTHON_DTLSSOCKET_VERSION = ba6ab0f6d9cbe14b392eac771b77286664837ff0
PYTHON_DTLSSOCKET_SITE = https://github.com/kabel42/DTLSSocket.git
PYTHON_DTLSSOCKET_SITE_METHOD = git
PYTHON_DTLSSOCKET_GIT_SUBMODULES = YES
PYTHON_DTLSSOCKET_SETUP_TYPE = distutils
PYTHON_DTLSSOCKET_LICENSE = EPL-1.0
PYTHON_DTLSSOCKET_LICENSE_FILES = LICENSE
PYTHON_DTLSSOCKET_DEPENDENCIES = host-python-cython

$(eval $(python-package))
