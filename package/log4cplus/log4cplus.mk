################################################################################
#
# log4cplus
#
################################################################################

LOG4CPLUS_VERSION = 2.0.2
LOG4CPLUS_SOURCE = log4cplus-$(LOG4CPLUS_VERSION).tar.xz
LOG4CPLUS_SITE = http://downloads.sourceforge.net/project/log4cplus/log4cplus-stable/$(LOG4CPLUS_VERSION)
LOG4CPLUS_LICENSE = Apache-2.0, BSD-2-Clause, BSD-like (threadpool)
LOG4CPLUS_LICENSE_FILES = LICENSE
LOG4CPLUS_INSTALL_STAGING = YES

ifeq ($(BR2_TOOLCHAIN_HAS_LIBATOMIC),y)
LOG4CPLUS_CONF_ENV += LIBS='-latomic'
endif

$(eval $(autotools-package))
