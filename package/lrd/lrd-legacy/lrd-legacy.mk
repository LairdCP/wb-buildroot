#############################################################
#
# Laird Legacy Software
#
#############################################################

define LRD_LEGACY_INSTALL_TARGET_CMDS
	rsync -rlpDWKv package/lrd/externals/lrd-legacy/rootfs-additions/ $(TARGET_DIR)/
endef

$(eval $(generic-package))
