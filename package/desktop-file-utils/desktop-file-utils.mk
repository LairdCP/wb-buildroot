###############################################################################
#
# desktop-file-utils .mk file
#
################################################################################

DESKTOP_FILE_UTILS_VERSION = 0.23
DESKTOP_FILE_UTILS_SOURCE = desktop-file-utils-$(DESKTOP_FILE_UTILS_VERSION).tar.xz
DESKTOP_FILE_UTILS_SITE = https://www.freedesktop.org/software/desktop-file-utils/releases
DESKTOP_FILE_UTILS_INSTALL_STAGING = YES
DESKTOP_FILE_UTILS_INSTALL_TARGET = NO
DESKTOP_FILE_UTILS_AUTOCONF = YES
DESKTOP_FILE_UTILS_AUTOMAKE=YES
DESKTOP_FILE_UTILS__DEPENDENCIES = libglib2
$(eval $(autotools-package))
