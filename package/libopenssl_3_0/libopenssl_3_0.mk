################################################################################
#
# libopenssl
#
################################################################################

LIBOPENSSL_3_0_VERSION = 3.0.5
LIBOPENSSL_3_0_SITE = https://www.openssl.org/source
LIBOPENSSL_3_0_SOURCE = openssl-$(LIBOPENSSL_3_0_VERSION).tar.gz
LIBOPENSSL_3_0_LICENSE = OpenSSL or SSLeay
LIBOPENSSL_3_0_LICENSE_FILES = LICENSE
LIBOPENSSL_3_0_INSTALL_STAGING = YES
LIBOPENSSL_3_0_DEPENDENCIES = zlib
HOST_LIBOPENSSL_3_0_DEPENDENCIES = host-zlib
LIBOPENSSL_3_0_TARGET_ARCH = $(call qstrip,$(BR2_PACKAGE_LIBOPENSSL_3_0_TARGET_ARCH))
LIBOPENSSL_3_0_CFLAGS = $(TARGET_CFLAGS)
LIBOPENSSL_3_0_PROVIDES = openssl
LIBOPENSSL_3_0_CPE_ID_VENDOR = $(LIBOPENSSL_3_0_PROVIDES)
LIBOPENSSL_3_0_CPE_ID_PRODUCT = $(LIBOPENSSL_3_0_PROVIDES)

ifeq ($(BR2_m68k_cf),y)
# relocation truncated to fit: R_68K_GOT16O
LIBOPENSSL_3_0_CFLAGS += -mxgot
# resolves an assembler "out of range error" with blake2 and sha512 algorithms
LIBOPENSSL_3_0_CFLAGS += -DOPENSSL_SMALL_FOOTPRINT
endif

ifeq ($(BR2_USE_MMU),)
LIBOPENSSL_3_0_CFLAGS += -DHAVE_FORK=0 -DOPENSSL_NO_MADVISE
endif

ifeq ($(BR2_PACKAGE_HAS_CRYPTODEV),y)
LIBOPENSSL_3_0_DEPENDENCIES += cryptodev
endif

# fixes the following build failures:
#
# - musl
#   ./libcrypto.so: undefined reference to `getcontext'
#   ./libcrypto.so: undefined reference to `setcontext'
#   ./libcrypto.so: undefined reference to `makecontext'
#
# - uclibc:
#   crypto/async/arch/../arch/async_posix.h:32:5: error: unknown type name 'ucontext_t'
#

ifeq ($(BR2_TOOLCHAIN_USES_MUSL),y)
LIBOPENSSL_3_0_CFLAGS += -DOPENSSL_NO_ASYNC
endif
ifeq ($(BR2_TOOLCHAIN_HAS_UCONTEXT),)
LIBOPENSSL_3_0_CFLAGS += -DOPENSSL_NO_ASYNC
endif

ifeq ($(BR2_PACKAGE_LIBOPENSSL_3_0_ENABLE_FIPS),y)
LIBOPENSSL_3_0_FIPS_EXT_PATCH_DIR=package/lrd-closed-source/externals/wpa_supplicant/laird/openssl-3.0-fips-patches/libopenssl_3_0
define LIBOPENSSL_3_0_POST_PATCH_CMD
	$(APPLY_PATCHES) $(@D) $(LIBOPENSSL_3_0_FIPS_EXT_PATCH_DIR) \*.patch
endef
LIBOPENSSL_3_0_POST_PATCH_HOOKS += LIBOPENSSL_3_0_POST_PATCH_CMD
LIBOPENSSL_3_0_DEVRANDOM = "'"'"/dev/hwrng"'"'"
else
LIBOPENSSL_3_0_DEVRANDOM = "'"'"/dev/hwrng","/dev/urandom"'"'"
endif

define HOST_LIBOPENSSL_3_0_CONFIGURE_CMDS
	(cd $(@D); \
		$(HOST_CONFIGURE_OPTS) \
		./config \
		--prefix=$(HOST_DIR) \
		--openssldir=$(HOST_DIR)/etc/ssl \
		no-tests \
		no-fuzz-libfuzzer \
		no-fuzz-afl \
		shared \
		zlib-dynamic \
	)
	$(SED) "s#-O[0-9sg]#$(HOST_CFLAGS)#" $(@D)/Makefile
endef

define LIBOPENSSL_3_0_CONFIGURE_CMDS
	(cd $(@D); \
		$(TARGET_CONFIGURE_ARGS) \
		$(TARGET_CONFIGURE_OPTS) \
		./Configure \
			$(LIBOPENSSL_TARGET_ARCH) \
			--prefix=/usr \
			--openssldir=/etc/ssl \
			$(if $(BR2_TOOLCHAIN_HAS_LIBATOMIC),-latomic) \
			$(if $(BR2_TOOLCHAIN_HAS_THREADS),threads,no-threads) \
			$(if $(BR2_STATIC_LIBS),no-shared,shared) \
			$(if $(BR2_PACKAGE_HAS_CRYPTODEV),enable-devcryptoeng) \
			no-rc5 \
			enable-camellia \
			enable-mdc2 \
			no-tests \
			no-fuzz-libfuzzer \
			no-fuzz-afl \
			$(if $(BR2_PACKAGE_LIBOPENSSL_ENABLE_CHACHA),,no-chacha) \
			$(if $(BR2_PACKAGE_LIBOPENSSL_ENABLE_RC5),,no-rc5) \
			$(if $(BR2_PACKAGE_LIBOPENSSL_ENABLE_RC2),,no-rc2) \
			$(if $(BR2_PACKAGE_LIBOPENSSL_ENABLE_RC4),,no-rc4) \
			$(if $(BR2_PACKAGE_LIBOPENSSL_ENABLE_MD2),,no-md2) \
			$(if $(BR2_PACKAGE_LIBOPENSSL_ENABLE_MD4),,no-md4) \
			$(if $(BR2_PACKAGE_LIBOPENSSL_ENABLE_MDC2),,no-mdc2) \
			$(if $(BR2_PACKAGE_LIBOPENSSL_ENABLE_BLAKE2),,no-blake2) \
			$(if $(BR2_PACKAGE_LIBOPENSSL_ENABLE_IDEA),,no-idea) \
			$(if $(BR2_PACKAGE_LIBOPENSSL_ENABLE_SEED),,no-seed) \
			$(if $(BR2_PACKAGE_LIBOPENSSL_ENABLE_DES),,no-des) \
			$(if $(BR2_PACKAGE_LIBOPENSSL_ENABLE_RMD160),,no-rmd160) \
			$(if $(BR2_PACKAGE_LIBOPENSSL_ENABLE_WHIRLPOOL),,no-whirlpool) \
			$(if $(BR2_PACKAGE_LIBOPENSSL_ENABLE_BLOWFISH),,no-bf) \
			$(if $(BR2_PACKAGE_LIBOPENSSL_ENABLE_SSL),,no-ssl) \
			$(if $(BR2_PACKAGE_LIBOPENSSL_ENABLE_SSL2),,no-ssl2) \
			$(if $(BR2_PACKAGE_LIBOPENSSL_ENABLE_SSL3),,no-ssl3) \
			$(if $(BR2_PACKAGE_LIBOPENSSL_ENABLE_WEAK_SSL),,no-weak-ssl-ciphers) \
			$(if $(BR2_PACKAGE_LIBOPENSSL_ENABLE_PSK),,no-psk) \
			$(if $(BR2_PACKAGE_LIBOPENSSL_ENABLE_CAST),,no-cast) \
			$(if $(BR2_PACKAGE_LIBOPENSSL_UNSECURE),,no-unit-test no-crypto-mdebug-backtrace no-crypto-mdebug no-autoerrinit) \
			$(if $(BR2_PACKAGE_LIBOPENSSL_DYNAMIC_ENGINE),,no-dynamic-engine ) \
			$(if $(BR2_PACKAGE_LIBOPENSSL_ENABLE_COMP),,no-comp) \
			$(if $(BR2_PACKAGE_LIBOPENSSL_3_0_ENABLE_FIPS),enable-fips) \
			$(if $(BR2_STATIC_LIBS),zlib,zlib-dynamic) \
			$(if $(BR2_STATIC_LIBS),no-dso) \
			-DDEVRANDOM=$(LIBOPENSSL_3_0_DEVRANDOM) \
	)
	$(SED) "s#-march=[-a-z0-9] ##" -e "s#-mcpu=[-a-z0-9] ##g" $(@D)/Makefile
	$(SED) "s#-O[0-9sg]#$(LIBOPENSSL_3_0_CFLAGS)#" $(@D)/Makefile
	$(SED) "s# build_tests##" $(@D)/Makefile
endef

# libdl is not available in a static build, and this is not implied by no-dso
ifeq ($(BR2_STATIC_LIBS),y)
define LIBOPENSSL_3_0_FIXUP_STATIC_MAKEFILE
	$(SED) 's#-ldl##g' $(@D)/Makefile
endef
LIBOPENSSL_3_0_POST_CONFIGURE_HOOKS += LIBOPENSSL_3_0_FIXUP_STATIC_MAKEFILE
endif

define HOST_LIBOPENSSL_3_0_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D)
endef

define LIBOPENSSL_3_0_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define LIBOPENSSL_3_0_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
endef

define HOST_LIBOPENSSL_3_0_INSTALL_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) install
endef

define LIBOPENSSL_3_0_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) install
	rm -rf $(TARGET_DIR)/usr/lib/ssl
	rm -f $(TARGET_DIR)/usr/bin/c_rehash
endef

# libdl has no business in a static build
ifeq ($(BR2_STATIC_LIBS),y)
define LIBOPENSSL_3_0_FIXUP_STATIC_PKGCONFIG
	$(SED) 's#-ldl##' $(STAGING_DIR)/usr/lib/pkgconfig/libcrypto.pc
	$(SED) 's#-ldl##' $(STAGING_DIR)/usr/lib/pkgconfig/libssl.pc
	$(SED) 's#-ldl##' $(STAGING_DIR)/usr/lib/pkgconfig/openssl.pc
endef
LIBOPENSSL_3_0_POST_INSTALL_STAGING_HOOKS += LIBOPENSSL_3_0_FIXUP_STATIC_PKGCONFIG
endif

ifeq ($(BR2_PACKAGE_PERL),)
define LIBOPENSSL_3_0_REMOVE_PERL_SCRIPTS
	$(RM) -f $(TARGET_DIR)/etc/ssl/misc/{CA.pl,tsget}
endef
LIBOPENSSL_3_0_POST_INSTALL_TARGET_HOOKS += LIBOPENSSL_3_0_REMOVE_PERL_SCRIPTS
endif

ifeq ($(BR2_PACKAGE_LIBOPENSSL_BIN),)
define LIBOPENSSL_3_0_REMOVE_BIN
	$(RM) -f $(TARGET_DIR)/usr/bin/openssl
	$(RM) -f $(TARGET_DIR)/etc/ssl/misc/{CA.*,c_*}
endef
LIBOPENSSL_3_0_POST_INSTALL_TARGET_HOOKS += LIBOPENSSL_3_0_REMOVE_BIN
endif

ifneq ($(BR2_PACKAGE_LIBOPENSSL_3_0_ENGINES),y)
define LIBOPENSSL_3_0_REMOVE_LIBOPENSSL_3_0_ENGINES
	rm -rf $(TARGET_DIR)/usr/lib/engines-3
endef
LIBOPENSSL_3_0_POST_INSTALL_TARGET_HOOKS += LIBOPENSSL_3_0_REMOVE_LIBOPENSSL_3_0_ENGINES
endif

$(eval $(generic-package))
$(eval $(host-generic-package))
