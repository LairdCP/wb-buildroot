#############################################################
#
# lrd-encrypted-storage-toolkit
#
#############################################################

define LRD_ENCRYPTED_STORAGE_TOOLKIT_INSTALL_TARGET_CMDS
	rsync -rlpDWK package/lrd/lrd-encrypted-storage-toolkit/rootfs/ $(TARGET_DIR)/
endef

# setup files for factory reset and /data usage
BACKUP_DIR = $(TARGET_DIR)/usr/share/factory/etc

define LRD_ENCRYPTED_STORAGE_TOOLKIT_ROOTFS_PRE_CMD_HOOK
	for BACKUP_TARGET in "firewalld" "weblcm-python" "modem"; do \
		if [ -d $(TARGET_DIR)/etc/"$${BACKUP_TARGET}" ];then \
			cp -r $(TARGET_DIR)/etc/$${BACKUP_TARGET}/ $(BACKUP_DIR); \
			rm -rf $(TARGET_DIR)/etc/$${BACKUP_TARGET}; \
			ln -sf /data/secret/$${BACKUP_TARGET} $(TARGET_DIR)/etc/$${BACKUP_TARGET}; \
		fi; \
	done
	set -x
	for SM_SUB_DIR in "certs" "system-connections"; do \
		mkdir -p $(BACKUP_DIR)/NetworkManager/$${SM_SUB_DIR}; \
		if [ -d $(TARGET_DIR)/etc/NetworkManager/$${SM_SUB_DIR} ]; then \
			cp -r  $(TARGET_DIR)/etc/NetworkManager/$${SM_SUB_DIR} $(BACKUP_DIR)/NetworkManager/; \
		fi; \
		rm -rf $(TARGET_DIR)/etc/NetworkManager/$${SM_SUB_DIR}; \
		ln -sf /data/secret/NetworkManager/$${SM_SUB_DIR} $(TARGET_DIR)/etc/NetworkManager; \
	done
	cp $(TARGET_DIR)/etc/timezone $(BACKUP_DIR)/timezone
	ln -sf /data/secret/timezone $(TARGET_DIR)/etc/timezone
	ln -sf /data/secret/localtime $(TARGET_DIR)/etc/localtime
	ln -sf /data/secret/adjtime $(TARGET_DIR)/etc/adjtime
endef

LRD_ENCRYPTED_STORAGE_TOOLKIT_ROOTFS_PRE_CMD_HOOKS += LRD_ENCRYPTED_STORAGE_TOOLKIT_ROOTFS_PRE_CMD_HOOK

$(eval $(generic-package))
