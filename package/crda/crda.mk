#############################################################
#
# crda
#
#############################################################

CRDA_VERSION = 1.1.3
CRDA_SOURCE = crda-$(CRDA_VERSION).tar.bz2
CRDA_SITE = https://www.kernel.org/pub/software/network/crda
CRDA_DEPENDENCIES = host-pkgconf libnl openssl wireless-regdb
CRDA_LICENSE = ISC
CRDA_LICENSE_FILES = LICENSE

define CRDA_BUILD_CMDS
	rsync package/crda/keys-gcrypt.c package/crda/keys-ssl.c $(@D)
	$(TARGET_CONFIGURE_OPTS) $(MAKE) USE_OPENSSL=1 all_noverify -C $(@D)
endef

define CRDA_INSTALL_TARGET_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) USE_OPENSSL=1 install -C $(@D) DESTDIR=$(TARGET_DIR)
endef

define CRDA_REMOVE_DOCS
	rm -f $(TARGET_DIR)/usr/share/man/man8/crda.8.gz
	rm -f $(TARGET_DIR)/usr/share/man/man8/regdbdump.8.gz
endef

ifneq ($(BR2_HAVE_DOCUMENTATION),y)
	CRDA_POST_INSTALL_TARGET_HOOKS += CRDA_REMOVE_DOCS
endif

$(eval $(generic-package))
