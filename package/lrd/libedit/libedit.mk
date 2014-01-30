LIBEDIT_VERSION = 20110802-3.0
LIBEDIT_SITE = http://www.thrysoee.dk/editline
LIBEDIT_SOURCE = libedit-$(LIBEDIT_VERSION).tar.gz
LIBEDIT_DEPENDENCIES = ncurses host-pkgconf
LIBEDIT_INSTALL_STAGING = YES

$(eval $(autotools-package))
