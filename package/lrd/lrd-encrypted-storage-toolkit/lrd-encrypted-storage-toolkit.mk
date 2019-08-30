#############################################################
#
# lrd-encrypted-storage-toolkit
#
#############################################################

define POST_INSTALL_TARGET_HOOK
	rsync -rlptDWK package/lrd/lrd-encrypted-storage-toolkit/rootfs/ $(TARGET_DIR)/
	cp -f  package/lrd/lrd-encrypted-storage-toolkit/configs/* $(BINARIES_DIR)/
endef

LRD_ENCRYPTED_STORAGE_TOOLKIT_POST_INSTALL_TARGET_HOOKS += POST_INSTALL_TARGET_HOOK

$(eval $(generic-package))
