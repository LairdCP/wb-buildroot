LAIRD_FIRMWARE_VERSION = local
LAIRD_FIRMWARE_SITE = package/lrd-closed-source/externals/firmware
LAIRD_FIRMWARE_SITE_METHOD = local
LAIRD_ADD_SOM_SYMLINK = y

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_AR6003),y)
define LAIRD_FW_6003_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/ath6k
	cp -r $(@D)/ath6k/AR6003 $(TARGET_DIR)/lib/firmware/ath6k
	rm $(TARGET_DIR)/lib/firmware/ath6k/AR6003/hw2.1.1/athtcmd*
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_AR6003_MFG),y)
define LAIRD_FW_6003_MFG_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/ath6k/AR6003/hw2.1.1
	cp $(@D)/ath6k/AR6003/hw2.1.1/athtcmd* $(TARGET_DIR)/lib/firmware/ath6k/AR6003/hw2.1.1/
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_AR6004),y)
define LAIRD_FW_6004_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/ath6k
	cp -r $(@D)/ath6k/AR6004 $(TARGET_DIR)/lib/firmware/ath6k
	rm $(TARGET_DIR)/lib/firmware/ath6k/AR6004/hw3.0/qca*
	rm $(TARGET_DIR)/lib/firmware/ath6k/AR6004/hw3.0/utf*
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_AR6004_MFG),y)
define LAIRD_FW_6004_MFG_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/ath6k/AR6004/hw3.0
	cp $(@D)/ath6k/AR6004/hw3.0/utf* $(TARGET_DIR)/lib/firmware/ath6k/AR6004/hw3.0/
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_AR6004_PUBLIC),y)
define LAIRD_FW_6004_PUBLIC_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/ath6k/AR6004/hw3.0
	$(INSTALL) -D -m 0644 $(@D)/ath6k/AR6004/hw3.0/qca* $(TARGET_DIR)/lib/firmware/ath6k/AR6004/hw3.0/
endef
endif

ifneq ($(filter y,$(BR2_PACKAGE_LAIRD_FIRMWARE_BCM4343) $(BR2_PACKAGE_LAIRD_FIRMWARE_BCM4343_MFG)),)
define LAIRD_FW_BCM4343_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/brcm
	cp -rad $(@D)/brcm/bcm4343w $(TARGET_DIR)/lib/firmware/brcm/
	find $(TARGET_DIR)/lib/firmware/brcm/bcm4343w -type d | xargs chmod 0755
	find $(TARGET_DIR)/lib/firmware/brcm/bcm4343w -type f | xargs chmod 0644
	cd $(TARGET_DIR)/lib/firmware/brcm/ && ln -sf ./bcm4343w/4343w.hcd 4343w.hcd
	cd $(TARGET_DIR)/lib/firmware/brcm/ && ln -sf ./bcm4343w/brcmfmac43430-sdio.bin brcmfmac43430-sdio.bin
	cd $(TARGET_DIR)/lib/firmware/brcm/ && ln -sf ./bcm4343w/brcmfmac43430-sdio.txt brcmfmac43430-sdio.txt
	cd $(TARGET_DIR)/lib/firmware/brcm/ && ln -sf ./bcm4343w/brcmfmac43430-sdio.clm_blob brcmfmac43430-sdio.clm_blob
endef
endif

ifneq ($(filter y,$(BR2_PACKAGE_LAIRD_FIRMWARE_BCM4339) $(BR2_PACKAGE_LAIRD_FIRMWARE_BCM4339_MFG)),)
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

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_ST60_SDIO_UART),y)
define LAIRD_FW_LRDMWL_ST60_SDIO_UART_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/lrdmwl
	cp -P $(@D)/lrdmwl/ST/88W8997_ST_sdio_uart_*.bin $(TARGET_DIR)/lib/firmware/lrdmwl
	cd $(TARGET_DIR)/lib/firmware/lrdmwl/ && ln -sf 88W8997_ST_sdio_uart_*.bin 88W8997_sdio.bin
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_ST60_SDIO_SDIO),y)
define LAIRD_FW_LRDMWL_ST60_SDIO_SDIO_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/lrdmwl
	cp -P $(@D)/lrdmwl/ST/88W8997_ST_sdio_sdio_*.bin $(TARGET_DIR)/lib/firmware/lrdmwl
	cd $(TARGET_DIR)/lib/firmware/lrdmwl/ && ln -sf 88W8997_ST_sdio_sdio_*.bin 88W8997_sdio.bin
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_ST60_PCIE_UART),y)
define LAIRD_FW_LRDMWL_ST60_PCIE_UART_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/lrdmwl
	cp -P $(@D)/lrdmwl/ST/88W8997_ST_pcie_uart_*.bin $(TARGET_DIR)/lib/firmware/lrdmwl
	cd $(TARGET_DIR)/lib/firmware/lrdmwl/ && ln -sf 88W8997_ST_pcie_uart_*.bin 88W8997_pcie.bin
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_ST60_PCIE_USB),y)
define LAIRD_FW_LRDMWL_ST60_PCIE_USB_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/lrdmwl
	cp -P $(@D)/lrdmwl/ST/88W8997_ST_pcie_usb_*.bin $(TARGET_DIR)/lib/firmware/lrdmwl
	cd $(TARGET_DIR)/lib/firmware/lrdmwl/ && ln -sf 88W8997_ST_pcie_usb_*.bin 88W8997_pcie.bin
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_ST60_USB_UART),y)
define LAIRD_FW_LRDMWL_ST60_USB_UART_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/lrdmwl
	cp -P $(@D)/lrdmwl/ST/88W8997_ST_usb_uart_*.bin $(TARGET_DIR)/lib/firmware/lrdmwl
	cd $(TARGET_DIR)/lib/firmware/lrdmwl/ && ln -sf 88W8997_ST_usb_uart_*.bin 88W8997_usb.bin
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_ST60_USB_USB),y)
define LAIRD_FW_LRDMWL_ST60_USB_USB_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/lrdmwl
	cp -P $(@D)/lrdmwl/ST/88W8997_ST_usb_usb_*.bin $(TARGET_DIR)/lib/firmware/lrdmwl
	cd $(TARGET_DIR)/lib/firmware/lrdmwl/ && ln -sf 88W8997_ST_usb_usb_*.bin 88W8997_usb.bin
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SU60_SDIO_UART),y)
define LAIRD_FW_LRDMWL_SU60_SDIO_UART_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/lrdmwl
	cp -P $(@D)/lrdmwl/SU/88W8997_SU_sdio_uart_*.bin $(TARGET_DIR)/lib/firmware/lrdmwl
	cd $(TARGET_DIR)/lib/firmware/lrdmwl/ && ln -sf 88W8997_SU_sdio_uart_*.bin 88W8997_sdio.bin
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SU60_SDIO_SDIO),y)
define LAIRD_FW_LRDMWL_SU60_SDIO_SDIO_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/lrdmwl
	cp -P $(@D)/lrdmwl/SU/88W8997_SU_sdio_sdio_*.bin $(TARGET_DIR)/lib/firmware/lrdmwl
	cd $(TARGET_DIR)/lib/firmware/lrdmwl/ && ln -sf 88W8997_SU_sdio_sdio_*.bin 88W8997_sdio.bin
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SU60_PCIE_UART),y)
define LAIRD_FW_LRDMWL_SU60_PCIE_UART_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/lrdmwl
	cp -P $(@D)/lrdmwl/SU/88W8997_SU_pcie_uart_*.bin $(TARGET_DIR)/lib/firmware/lrdmwl
	cd $(TARGET_DIR)/lib/firmware/lrdmwl/ && ln -sf 88W8997_SU_pcie_uart_*.bin 88W8997_pcie.bin
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SU60_PCIE_USB),y)
define LAIRD_FW_LRDMWL_SU60_PCIE_USB_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/lrdmwl
	cp -P $(@D)/lrdmwl/SU/88W8997_SU_pcie_usb_*.bin $(TARGET_DIR)/lib/firmware/lrdmwl
	cd $(TARGET_DIR)/lib/firmware/lrdmwl/ && ln -sf 88W8997_SU_pcie_usb_*.bin 88W8997_pcie.bin
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SU60_USB_UART),y)
define LAIRD_FW_LRDMWL_SU60_USB_UART_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/lrdmwl
	cp -P $(@D)/lrdmwl/SU/88W8997_SU_usb_uart_*.bin $(TARGET_DIR)/lib/firmware/lrdmwl
	cd $(TARGET_DIR)/lib/firmware/lrdmwl/ && ln -sf 88W8997_SU_usb_uart_*.bin 88W8997_usb.bin
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SU60_USB_USB),y)
define LAIRD_FW_LRDMWL_SU60_USB_USB_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/lrdmwl
	cp -P $(@D)/lrdmwl/SU/88W8997_SU_usb_usb_*.bin $(TARGET_DIR)/lib/firmware/lrdmwl
	cd $(TARGET_DIR)/lib/firmware/lrdmwl/ && ln -sf 88W8997_SU_usb_usb_*.bin 88W8997_usb.bin
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SOM60),y)
#if building MFG SOM and ST or SU fw included, don't set symlink to point to SOM
ifeq ($(findstring som60sd_mfg, $(BR2_DEFCONFIG)),som60sd_mfg)
ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SU60_SDIO_UART),y)
	LAIRD_ADD_SOM_SYMLINK = n
else ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_ST60_SDIO_UART),y)
	LAIRD_ADD_SOM_SYMLINK = n
endif
endif

ifeq ($(LAIRD_ADD_SOM_SYMLINK),y)
define LAIRD_FW_LRDMWL_SOM60_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/lrdmwl
	cp -P $(@D)/lrdmwl/SOM/88W8997_SOM_sdio_uart_*.bin $(TARGET_DIR)/lib/firmware/lrdmwl
	cd $(TARGET_DIR)/lib/firmware/lrdmwl/ && ln -sf 88W8997_SOM_sdio_uart_*.bin 88W8997_sdio.bin
endef
else
define LAIRD_FW_LRDMWL_SOM60_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/lrdmwl
	cp -P $(@D)/lrdmwl/SOM/88W8997_SOM_sdio_uart_*.bin $(TARGET_DIR)/lib/firmware/lrdmwl
endef
endif
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SD8997_MFG),y)
define LAIRD_FW_LRDMWL_SD8997_MFG_INSTALL_TARGET_CMDS
	rm -r -f $(TARGET_DIR)/lib/firmware/lrdmwl/mfg/*
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/lrdmwl
	cp $(@D)/lrdmwl/mfg/* $(TARGET_DIR)/lib/firmware/lrdmwl
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
	$(LAIRD_FW_6003_MFG_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_6004_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_6004_MFG_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_6004_PUBLIC_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_BCM4343_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_BCM4339_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_LRDMWL_ST60_SDIO_UART_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_LRDMWL_ST60_SDIO_SDIO_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_LRDMWL_ST60_PCIE_UART_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_LRDMWL_ST60_PCIE_USB_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_LRDMWL_ST60_USB_UART_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_LRDMWL_ST60_USB_USB_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_LRDMWL_SU60_SDIO_UART_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_LRDMWL_SU60_SDIO_SDIO_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_LRDMWL_SU60_PCIE_UART_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_LRDMWL_SU60_PCIE_USB_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_LRDMWL_SU60_USB_UART_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_LRDMWL_SU60_USB_USB_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_LRDMWL_SOM60_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_LRDMWL_SD8997_MFG_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_MRVL_SD8997_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_WL18XX_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_BT50_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_AR9271_INSTALL_TARGET_CMDS)
endef

$(eval $(generic-package))
