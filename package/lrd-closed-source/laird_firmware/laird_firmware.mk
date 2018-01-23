LAIRD_FIRMWARE_VERSION = local
LAIRD_FIRMWARE_SITE = package/lrd-closed-source/externals/firmware
LAIRD_FIRMWARE_SITE_METHOD = local

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_AR6003),y)
define LAIRD_FW_6003_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/ath6k
	cp -r $(@D)/ath6k/AR6003 $(TARGET_DIR)/lib/firmware/ath6k
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_AR6004),y)
define LAIRD_FW_6004_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/ath6k
	cp -r $(@D)/ath6k/AR6004 $(TARGET_DIR)/lib/firmware/ath6k
	rm $(TARGET_DIR)/lib/firmware/ath6k/AR6004/hw3.0/qca*
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_AR6004_PUBLIC),y)
define LAIRD_FW_6004_PUBLIC_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/ath6k/AR6004/hw3.0
	$(INSTALL) -D -m 0644 $(@D)/ath6k/AR6004/hw3.0/qca* $(TARGET_DIR)/lib/firmware/ath6k/AR6004/hw3.0/
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_BCM4343),y)
define LAIRD_FW_BCM4343_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/brcm
	cp -rad $(@D)/brcm/bcm4343w $(TARGET_DIR)/lib/firmware/brcm/
	find $(TARGET_DIR)/lib/firmware/brcm/bcm4343w -type d | xargs chmod 0755
	find $(TARGET_DIR)/lib/firmware/brcm/bcm4343w -type f | xargs chmod 0644
	cd $(TARGET_DIR)/lib/firmware/brcm/ && ln -sf ./bcm4343w/4343w.hcd 4343w.hcd
	cd $(TARGET_DIR)/lib/firmware/brcm/ && ln -sf ./bcm4343w/brcmfmac43430-sdio.bin brcmfmac43430-sdio.bin
	cd $(TARGET_DIR)/lib/firmware/brcm/ && ln -sf ./bcm4343w/brcmfmac43430-sdio.txt brcmfmac43430-sdio.txt
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_BCM4343_MFG),y)
define LAIRD_FW_BCM4343_MFG_INSTALL_TARGET_CMDS
    mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/brcm
    cp -rad $(@D)/brcm/bcm4343w $(TARGET_DIR)/lib/firmware/brcm/
    find $(TARGET_DIR)/lib/firmware/brcm/bcm4343w -type d | xargs chmod 0755
    find $(TARGET_DIR)/lib/firmware/brcm/bcm4343w -type f | xargs chmod 0644
    cd $(TARGET_DIR)/lib/firmware/brcm/ && ln -sf ./bcm4343w/4343w.hcd 4343w.hcd
    cd $(TARGET_DIR)/lib/firmware/brcm/ && ln -sf  brcmfmac43430-sdio-mfg.bin ./bcm4343w/brcmfmac43430-sdio.bin
    cd $(TARGET_DIR)/lib/firmware/brcm/ && ln -sf ./bcm4343w/brcmfmac43430-sdio.txt brcmfmac43430-sdio.txt
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_BCM4339),y)
define LAIRD_FW_BCM4339_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/brcm
	cp -rad $(@D)/brcm/bcm4339 $(TARGET_DIR)/lib/firmware/brcm/
	find $(TARGET_DIR)/lib/firmware/brcm/bcm4339 -type d | xargs chmod 0755
	find $(TARGET_DIR)/lib/firmware/brcm/bcm4339 -type f | xargs chmod 0644
	cd $(TARGET_DIR)/lib/firmware/brcm/ && ln -sf ./bcm4339/4339.hcd 4339.hcd
	cd $(TARGET_DIR)/lib/firmware/brcm/ && ln -sf ./bcm4339/brcmfmac4339-sdio.bin brcmfmac4339-sdio.bin
	cd $(TARGET_DIR)/lib/firmware/brcm/ && ln -sf ./bcm4339/brcmfmac4339-sdio.txt brcmfmac4339-sdio.txt
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_BCM4339_MFG),y)
define LAIRD_FW_BCM4339_MFG_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/brcm
	cp -rad $(@D)/brcm/bcm4339 $(TARGET_DIR)/lib/firmware/brcm/
	find $(TARGET_DIR)/lib/firmware/brcm/bcm4339 -type d | xargs chmod 0755
	find $(TARGET_DIR)/lib/firmware/brcm/bcm4339 -type f | xargs chmod 0644
	cd $(TARGET_DIR)/lib/firmware/brcm/ && ln -sf ./bcm4339/4339.hcd 4339.hcd
	cd $(TARGET_DIR)/lib/firmware/brcm/ && ln -sf  brcmfmac4339-sdio-mfg.bin ./bcm4339/brcmfmac4339-sdio.bin
	cd $(TARGET_DIR)/lib/firmware/brcm/ && ln -sf ./bcm4339/brcmfmac4339-sdio.txt brcmfmac4339-sdio.txt
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SD8997),y)
define LAIRD_FW_LRDMWL_SD8997_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/lrdmwl
	rm -r -f $(TARGET_DIR)/lib/firmware/lrdmwl/*
	cp -r $(@D)/lrdmwl/ $(TARGET_DIR)/lib/firmware
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_MRVL_SD8997),y)
define LAIRD_FW_MRVL_SD8997_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/mrvl
	rm -r -f $(TARGET_DIR)/lib/firmware/mrvl/*
	cp -r $(@D)/mrvl/ $(TARGET_DIR)/lib/firmware
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_WL18XX),y)
define LAIRD_FW_WL18XX_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware
	cp -r $(@D)/ti-connectivity $(TARGET_DIR)/lib/firmware
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_BT),y)
define LAIRD_FW_BT50_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware
	cp -r $(@D)/bluetopia $(TARGET_DIR)/lib/firmware
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_AR9271),y)
define LAIRD_FW_AR9271_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware
	cp -r $(@D)/ath9k_htc $(TARGET_DIR)/lib/firmware
endef
endif

define LAIRD_FIRMWARE_INSTALL_TARGET_CMDS
	$(LAIRD_FW_6003_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_6004_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_6004_PUBLIC_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_BCM4343_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_BCM4343_MFG_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_BCM4339_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_BCM4339_MFG_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_LRDMWL_SD8997_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_MRVL_SD8997_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_WL18XX_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_BT50_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_AR9271_INSTALL_TARGET_CMDS)
endef

$(eval $(generic-package))
