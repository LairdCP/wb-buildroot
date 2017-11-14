#############################################################
#
# openssl-fips
#
#############################################################

OPENSSL_FIPS_VERSION = 2.0.10
OPENSSL_FIPS_SITE = $(DL_DIR)
OPENSSL_FIPS_SITE_METHOD = file
#
# This is a certified source tarball from local archive only!!!
# For building, see proscribed method in OPENSSL-FIPS-2.0 Security Policy Appendix A
#
OPENSSL_FIPS_LICENSE = OpenSSL or SSLeay
OPENSSL_FIPS_INSTALL_STAGING = YES

OPENSSL_FIPS_DEPENDENCIES = zlib

OPENSSL_FIPS_CFLAGS = $(TARGET_CFLAGS)

ifeq ($(ARCH),arm)
OPENSSL_TARGET_ARCH = armv4
endif
ifeq ($(ARCH),powerpc)
# 4xx cores seem to have trouble with openssl's ASM optimizations
ifeq ($(BR2_powerpc_401)$(BR2_powerpc_403)$(BR2_powerpc_405)$(BR2_powerpc_405fp)$(BR2_powerpc_440)$(BR2_powerpc_440fp),)
OPENSSL_TARGET_ARCH = ppc
endif
endif
ifeq ($(ARCH),powerpc64)
OPENSSL_TARGET_ARCH = ppc64
endif
ifeq ($(ARCH),powerpc64le)
OPENSSL_TARGET_ARCH = ppc64le
endif
ifeq ($(ARCH),x86_64)
OPENSSL_TARGET_ARCH = x86_64
endif

# Workaround for bug #3445
ifeq ($(BR2_x86_i386),y)
OPENSSL_TARGET_ARCH = generic32 386
endif

define OPENSSL_FIPS_CONFIGURE_CMDS
endef

# BZ10856: set BR2_PASSTHRU_WRAPPER=1 to use base toolchain cross-compiler
define OPENSSL_FIPS_BUILD_CMDS
	( cd $(@D); \
	  export BR2_PASSTHRU_WRAPPER=1; \
	  export MACHINE=$(OPENSSL_TARGET_ARCH); \
	  export RELEASE=4.x; \
	  export SYSTEM=Linux; \
	  export BUILD=Laird; \
	  export CROSS_COMPILE=$(TARGET_CROSS); \
	  export HOSTCC=gcc; \
	  ./config; \
	  make \
	)
endef

define OPENSSL_FIPS_INSTALL_STAGING_CMDS
	$(MAKE1) -C $(@D) INSTALL_PREFIX=$(STAGING_DIR) install
	( cd $(@D); \
	  cp util/incore $(STAGING_DIR)/usr/local/ssl/fips-2.0/bin \
	)
endef

# NOTE: OPENSSL_FIPS_INSTALL_TARGET_CMDS is not required (see BZ2297)

#define OPENSSL_FIPS_UNINSTALL_CMDS
#	rm -rf $(addprefix $(TARGET_DIR)/,etc/ssl usr/bin/openssl usr/include/openssl)
#	rm -rf $(addprefix $(TARGET_DIR)/usr/lib/,ssl engines libcrypto* libssl* pkgconfig/libcrypto.pc)
#	rm -rf $(addprefix $(STAGING_DIR)/,etc/ssl usr/bin/openssl usr/include/openssl)
#	rm -rf $(addprefix $(STAGING_DIR)/usr/lib/,ssl engines libcrypto* libssl* pkgconfig/libcrypto.pc)
#endef

$(eval $(generic-package))
