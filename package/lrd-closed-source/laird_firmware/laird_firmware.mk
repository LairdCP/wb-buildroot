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
	$(INSTALL) -D -m 0644 $(@D)/brcm/4343w-*.hcd $(TARGET_DIR)/lib/firmware/brcm/
	cd $(TARGET_DIR)/lib/firmware/brcm/ && ln -sf 4343w-*.hcd 4343w.hcd
	$(INSTALL) -D -m 0644 $(@D)/brcm/bcmdhd_4343w*.cal $(TARGET_DIR)/lib/firmware/brcm/
	$(INSTALL) -D -m 0644 $(@D)/brcm/fw_bcmdhd_4343w*.bin $(TARGET_DIR)/lib/firmware/brcm/
	$(INSTALL) -D -m 0644 $(@D)/brcm/fw_bcmdhd_mfgtest_4343w*.bin $(TARGET_DIR)/lib/firmware/brcm/
	cd $(TARGET_DIR)/lib/firmware/brcm/ && ln -sf fw_bcmdhd_4343w-*.bin brcmfmac43430-sdio.bin
	cd $(TARGET_DIR)/lib/firmware/brcm/ && ln -sf bcmdhd_4343w_fcc-*.cal brcmfmac43430-sdio.txt
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_BCM4339),y)
define LAIRD_FW_BCM4339_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/brcm
	$(INSTALL) -D -m 0644 $(@D)/brcm/4339-*.hcd $(TARGET_DIR)/lib/firmware/brcm/
	cd $(TARGET_DIR)/lib/firmware/brcm/ && ln -sf 4339-*.hcd 4339.hcd
	$(INSTALL) -D -m 0644 $(@D)/brcm/bcmdhd_4339*.cal $(TARGET_DIR)/lib/firmware/brcm/
	$(INSTALL) -D -m 0644 $(@D)/brcm/fw_bcmdhd_4339*.bin $(TARGET_DIR)/lib/firmware/brcm/
	$(INSTALL) -D -m 0644 $(@D)/brcm/fw_bcmdhd_mfgtest_4339*.bin $(TARGET_DIR)/lib/firmware/brcm/
	cd $(TARGET_DIR)/lib/firmware/brcm/ && ln -sf fw_bcmdhd_4339-*.bin brcmfmac4339-sdio.bin
	cd $(TARGET_DIR)/lib/firmware/brcm/ && ln -sf bcmdhd_4339-??_??_????.cal brcmfmac4339-sdio.txt
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SD8997),y)
define LAIRD_FW_LRDMWL_SD8997_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/lrdmwl
	$(INSTALL) -D -m 0644 $(@D)/lrdmwl/88W8997_sdio-*.bin $(TARGET_DIR)/lib/firmware/lrdmwl/
	cd $(TARGET_DIR)/lib/firmware/lrdmwl/ && ln -sf 88W8997_sdio-*.bin 88W8997_sdio.bin
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_MRVL_SD8997),y)
define LAIRD_FW_MRVL_SD8997_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/mrvl
	$(INSTALL) -D -m 0644 $(@D)/mrvl/sdsd8997_combo_v2.bin $(TARGET_DIR)/lib/firmware/mrvl/
	cd $(TARGET_DIR)/lib/firmware/mrvl/ && ln -sf sdsd8997_combo_v2.bin sd8997_uapsta.bin
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_MWLWIFI_SD8997),y)
define LAIRD_FW_MWLWIFI_SD8997_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/mwlwifi
	$(INSTALL) -D -m 0644 $(@D)/mwlwifi/88W8997_sdio-*.bin $(TARGET_DIR)/lib/firmware/mwlwifi/
	cd $(TARGET_DIR)/lib/firmware/mwlwifi/ && ln -sf 88W8997_sdio-*.bin 88W8997_sdio.bin
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


define LAIRD_FIRMWARE_INSTALL_TARGET_CMDS
	$(LAIRD_FW_6003_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_6004_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_6004_PUBLIC_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_BCM4343_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_BCM4339_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_LRDMWL_SD8997_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_MRVL_SD8997_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_MWLWIFI_SD8997_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_WL18XX_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_BT50_INSTALL_TARGET_CMDS)
endef

$(eval $(generic-package))
