#############################################################
#
# lrd-encrypted-storage-toolkit
#
#############################################################

define LRD_ENCRYPTED_STORAGE_TOOLKIT_INSTALL_TARGET_CMDS
	rsync -rlptDWK package/lrd/lrd-encrypted-storage-toolkit/rootfs/ $(TARGET_DIR)/
	$(INSTALL) -D -t $(BINARIES_DIR)/ package/lrd/lrd-encrypted-storage-toolkit/configs/*
endef

$(eval $(generic-package))
