#############################################################
#
# openssl-fips
#
#############################################################

OPENSSL_FIPS_VERSION = 2.0.5
OPENSSL_FIPS_SITE = $(DL_DIR)/
OPENSSL_FIPS_SITE_METHOD = file
#
# This is a certified source tarball from local archive only!!!
# For building, see proscribed method in OPENSSL-FIPS-2.0 Security Policy Appendix A
#
OPENSSL_FIPS_LICENSE = OpenSSL or SSLeay
OPENSSL_FIPS_INSTALL_STAGING = YES

OPENSSL_FIPS_DEPENDENCIES = zlib

OPENSSL_FIPS_CFLAGS = $(TARGET_CFLAGS)


define OPENSSL_FIPS_CONFIGURE_CMDS
	( cd $(@D); \
	  export MACHINE=armv5tejl \
	  export RELEASE=3.8-laird1; \
	  export SYSTEM=Linux; \
	  export BUILD=sdc; \
	  export CROSS_COMPILE=arm-sdc-linux-gnueabi-; \
	  export HOSTCC=gcc; \
	  ./config \
	)
endef

define OPENSSL_FIPS_BUILD_CMDS
	$(MAKE1) -C $(@D)
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
