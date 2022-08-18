#############################################################
#
# lrd-encrypted-storage-toolkit
#
#############################################################

define LRD_ENCRYPTED_STORAGE_TOOLKIT_INSTALL_TARGET_CMDS
	rsync -rlpDWK package/lrd/lrd-encrypted-storage-toolkit/rootfs/ $(TARGET_DIR)/
endef

BACKUP_DIR = $(TARGET_DIR)/usr/share/factory/etc
NM_SYS_CONS = NetworkManager/system-connections
# setup files for factory reset and /data usage
define LRD_ENCRYPTED_STORAGE_TOOLKIT_ROOTFS_PRE_CMD_HOOK
	mkdir -p $(BACKUP_DIR)/$(NM_SYS_CONS)
	cp -r  $(TARGET_DIR)/etc/$(NM_SYS_CONS)/* $(BACKUP_DIR)/$(NM_SYS_CONS)/.;
	rm -rf $(TARGET_DIR)/etc/$(NM_SYS_CONS);
	ln -sf /data/secret/$(NM_SYS_CONS) $(TARGET_DIR)/etc/$(NM_SYS_CONS)
	for BACKUP_TARGET in "firewalld" "weblcm-python" "modem"; do \
		if [ -d $(TARGET_DIR)/etc/"$${BACKUP_TARGET}" ];then \
			cp -r $(TARGET_DIR)/etc/$${BACKUP_TARGET}/ $(BACKUP_DIR)/$${BACKUP_TARGET}/; \
			rm -rf $(TARGET_DIR)/etc/$${BACKUP_TARGET}; \
			ln -sf /data/secret/$${BACKUP_TARGET} $(TARGET_DIR)/etc/$${BACKUP_TARGET}; \
		fi; \
	done
	cp $(TARGET_DIR)/etc/timezone $(BACKUP_DIR)/timezone
	ln -sf /data/secret/timezone $(TARGET_DIR)/etc/timezone
	ln -sf /data/secret/localtime $(TARGET_DIR)/etc/localtime
	ln -sf /data/secret/adjtime $(TARGET_DIR)/etc/adjtime
endef

LRD_ENCRYPTED_STORAGE_TOOLKIT_ROOTFS_PRE_CMD_HOOKS += LRD_ENCRYPTED_STORAGE_TOOLKIT_ROOTFS_PRE_CMD_HOOK

$(eval $(generic-package))
