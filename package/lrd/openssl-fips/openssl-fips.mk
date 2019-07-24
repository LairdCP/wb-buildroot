#############################################################
#
# openssl-fips
#
#############################################################

OPENSSL_FIPS_VERSION = 2.0.16
OPENSSL_FIPS_SITE = $(TOPDIR)/../archive
OPENSSL_FIPS_SITE_METHOD = file
OPENSSL_FIPS_SOURCE = openssl-fips-$(OPENSSL_FIPS_VERSION).tar.gz
OPENSSL_FIPS_HMAC = e8dbfa6cb9e22a049ec625ffb7ccaf33e6116598

ifeq ($(BR2_PACKAGE_LAIRD_OPENSSL_FIPS),y)
# LAIRD FIPS PATCHES
OPENSSL_FIPS_LOCAL_PATCH_FILES = \
	$(TOPDIR)/package/lrd-closed-source/externals/wpa_supplicant/laird/laird-fips-ssl-patches/0010-laird-fips-openssl-fips-2.0.16.patch
define OPENSSL_FIPS_APPLY_LOCAL_PATCHES
	for p in $(OPENSSL_FIPS_LOCAL_PATCH_FILES) ; do \
		if test -d $$p ; then \
			$(APPLY_PATCHES) $(@D) $$p \*.patch || exit 1 ; \
		else \
			$(APPLY_PATCHES) $(@D) `dirname $$p` `basename $$p` || exit 1; \
		fi \
	done
endef
OPENSSL_FIPS_POST_PATCH_HOOKS += OPENSSL_FIPS_APPLY_LOCAL_PATCHES
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

define OPENSSL_FIPS_CONFIGURE_CMDS
$(if $(filter $(OPENSSL_FIPS_HMAC),$(CALC_HMAC)),,$(error Hash Mismatch $(OPENSSL_FIPS_SOURCE)))
endef

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
	  ./config; \
	  make \
	)
endef

define OPENSSL_FIPS_INSTALL_STAGING_CMDS
	$(MAKE1) -C $(@D) INSTALL_PREFIX=$(STAGING_DIR) install
	cp $(@D)/util/incore $(STAGING_DIR)/usr/local/ssl/fips-2.0/bin
endef

$(eval $(generic-package))
