ifeq ($(BR2_PACKAGE_LRD_LEGACY),y)
define LRD_FIPS_UTILS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(LRD_FIPS_UTILS_PKGDIR)/fips-set.legacy \
		$(TARGET_DIR)/usr/bin/fips-set
endef
else
define LRD_FIPS_UTILS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(LRD_FIPS_UTILS_PKGDIR)/fips-set \
		$(TARGET_DIR)/usr/bin/fips-set
endef
endif

$(eval $(generic-package))
