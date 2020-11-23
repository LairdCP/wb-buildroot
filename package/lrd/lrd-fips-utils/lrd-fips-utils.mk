define LRD_FIPS_UTILS_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/sbin/
	$(INSTALL) -D -m 755 package/lrd/lrd-fips-utils/* $(TARGET_DIR)/usr/bin/
endef

$(eval $(generic-package))
