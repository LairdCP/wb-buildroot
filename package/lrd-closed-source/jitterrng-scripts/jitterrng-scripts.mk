#############################################################
#
#  JITTER RNG SCRIPTS
#
#############################################################

JITTERRNG_SCRIPTS_VERSION = local
JITTERRNG_SCRIPTS_SITE    = package/lrd-closed-source/externals/cavs_api/jitterrng-sp80090b/recording_kernelspace
JITTERRNG_SCRIPTS_SITE_METHOD = local

JITTERRNG_SCRIPTS_MAKE_ENV = \
	$(TARGET_MAKE_ENV) \
	CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include"

JITTERRNG_SCRIPTS_MAKE_ENV2 = CC="$(TARGET_CC)"

define JITTERRNG_SCRIPTS_COPY_JE
	cp $(LINUX_OVERRIDE_SRCDIR)/crypto/jitterentropy.c $(@D)
	$(APPLY_PATCHES) $(@D) $(JITTERRNG_SCRIPTS_PKGDIR)
endef

JITTERRNG_SCRIPTS_POST_RSYNC_HOOKS += JITTERRNG_SCRIPTS_COPY_JE

define JITTERRNG_SCRIPTS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) -f Makefile.lfsrtime $(JITTERRNG_SCRIPTS_MAKE_ENV2)
endef

define JITTERRNG_SCRIPTS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/jitterentropy-kernel-lfsrtime $(TARGET_DIR)/usr/bin/jitterentropy-kernel-lfsrtime
	$(INSTALL) -D -m 755 $(@D)/invoke_testing_lfsrtime.sh $(TARGET_DIR)/usr/bin/
endef

$(eval $(generic-package))
