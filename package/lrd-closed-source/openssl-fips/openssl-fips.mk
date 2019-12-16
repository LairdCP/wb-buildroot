#############################################################
#
# openssl-fips
#
#############################################################

ifeq ($(BR2_PACKAGE_LAIRD_OPENSSL_FIPS),y)
# building from closed source git repository
OPENSSL_FIPS_VERSION = local
OPENSSL_FIPS_SITE = package/lrd-closed-source/externals/lairdssl_fips_2_0
OPENSSL_FIPS_SITE_METHOD = local
else
OPENSSL_FIPS_VERSION = 2.0.10
OPENSSL_FIPS_SITE = https://www.openssl.org/source/old/fips
OPENSSL_FIPS_SOURCE = openssl-fips-$(OPENSSL_FIPS_VERSION).tar.gz
OPENSSL_FIPS_HMAC = af8bda4bb9739e35b4ef00a9bc40d21a6a97a780
OPENSSL_FIPS_LICENSE_FILES = LICENSE
endif

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

CALC_HMAC = $(shell openssl sha1 -r -hmac etaonrishdlcupfm $(OPENSSL_FIPS_DL_DIR)/$(OPENSSL_FIPS_SOURCE))

ifneq ($(OPENSSL_FIPS_VERSION),local)
define OPENSSL_FIPS_CONFIGURE_CMDS
$(if $(filter $(OPENSSL_FIPS_HMAC),$(CALC_HMAC)),,$(error Hash Mismatch $(OPENSSL_FIPS_SOURCE)))
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_OPENSSL_FIPS),y)
# building from git repository
OPENSSL_FIPS_CONFIG_CMD_EXEC=./config fipscanisteronly
else
# building from tarball
OPENSSL_FIPS_CONFIG_CMD_EXEC=./config
endif

# BZ10856: set BR2_PASSTHRU_WRAPPER=1 to use base toolchain cross-compiler
define OPENSSL_FIPS_BUILD_CMDS
	( cd $(@D); \
	  export BR2_PASSTHRU_WRAPPER=1; \
	  export MACHINE=$(OPENSSL_TARGET_ARCH); \
	  export RELEASE=7.x; \
	  export SYSTEM=Linux; \
	  export BUILD=Laird; \
	  export CROSS_COMPILE=$(TARGET_CROSS); \
	  export HOSTCC=gcc; \
	  $(OPENSSL_FIPS_CONFIG_CMD_EXEC); \
	  make \
	)
endef

define OPENSSL_FIPS_INSTALL_STAGING_CMDS
	$(MAKE1) -C $(@D) INSTALL_PREFIX=$(STAGING_DIR) install
	cp $(@D)/util/incore $(STAGING_DIR)/usr/local/ssl/fips-2.0/bin
endef

$(eval $(generic-package))
