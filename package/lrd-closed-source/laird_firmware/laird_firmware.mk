LAIRD_FIRMWARE_VERSION = local
LAIRD_FIRMWARE_SITE = package/lrd-closed-source/externals/firmware
LAIRD_FIRMWARE_SITE_METHOD = local

BRCM_DIR = $(TARGET_DIR)/lib/firmware/brcm
CYPRESS_DIR = $(TARGET_DIR)/lib/firmware/cypress
LRDMWL_DIR = $(TARGET_DIR)/lib/firmware/lrdmwl

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_AR6003),y)
define LAIRD_FW_6003_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/ath6k
	cp -ra $(@D)/ath6k/AR6003 $(TARGET_DIR)/lib/firmware/ath6k
	rm $(TARGET_DIR)/lib/firmware/ath6k/AR6003/hw2.1.1/athtcmd*
	rm -rf $(TARGET_DIR)/lib/firmware/ath6k/AR6003/hw2.1.1/info/
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_AR6003_MFG),y)
define LAIRD_FW_6003_MFG_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/ath6k/AR6003/hw2.1.1
	cp -a $(@D)/ath6k/AR6003/hw2.1.1/athtcmd* $(TARGET_DIR)/lib/firmware/ath6k/AR6003/hw2.1.1/
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_AR6004),y)
define LAIRD_FW_6004_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/ath6k
	cp -ra $(@D)/ath6k/AR6004 $(TARGET_DIR)/lib/firmware/ath6k
	rm $(TARGET_DIR)/lib/firmware/ath6k/AR6004/hw3.0/qca*
	rm $(TARGET_DIR)/lib/firmware/ath6k/AR6004/hw3.0/utf*
	rm -rf $(TARGET_DIR)/lib/firmware/ath6k/AR6004/hw3.0/info/
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_AR6004_MFG),y)
define LAIRD_FW_6004_MFG_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware/ath6k/AR6004/hw3.0
	cp -a $(@D)/ath6k/AR6004/hw3.0/utf* $(TARGET_DIR)/lib/firmware/ath6k/AR6004/hw3.0/
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
	mkdir -p -m 0755 $(BRCM_DIR)
	cp -rad $(@D)/brcm/brcmfmac43430-sdio-prod_*.bin $(BRCM_DIR)
	cd $(BRCM_DIR) && ln -srf brcmfmac43430-sdio-prod_*.bin brcmfmac43430-sdio.bin
	cp -rad $(@D)/brcm/brcmfmac43430-sdio*.txt $(BRCM_DIR)
	cp -rad $(@D)/brcm/brcmfmac43430-sdio.clm_blob $(BRCM_DIR)
	cp -rad $(@D)/brcm/BCM43430A1_*.hcd $(BRCM_DIR)
	cd $(BRCM_DIR) && ln -srf BCM43430A1_*.hcd BCM43430A1.hcd
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_BCM4343_MFG),y)
define LAIRD_FW_BCM4343_MFG_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(BRCM_DIR)
	cp -rad $(@D)/brcm/brcmfmac43430-sdio-mfg_*.bin $(BRCM_DIR)
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_BCM43439),y)
define LAIRD_FW_BCM43439_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(BRCM_DIR)
	cp -rad $(@D)/brcm/brcmfmac43439-sdio-prod_*.bin $(BRCM_DIR)
	cd $(BRCM_DIR) && ln -srf brcmfmac43439-sdio-prod_*.bin brcmfmac43439-sdio.bin
	cp -rad $(@D)/brcm/brcmfmac43439-sdio.txt $(BRCM_DIR)
	cp -rad $(@D)/brcm/brcmfmac43439-sdio.clm_blob $(BRCM_DIR)
	cp -rad $(@D)/brcm/BCM4343A2_*.hcd $(BRCM_DIR)
	cd $(BRCM_DIR) && ln -srf BCM4343A2_*.hcd BCM4343A2.hcd
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_BCM43439_MFG),y)
define LAIRD_FW_BCM43439_MFG_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(BRCM_DIR)
	cp -rad $(@D)/brcm/brcmfmac43439-sdio-mfg_*.bin $(BRCM_DIR)
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_BCM4339),y)
define LAIRD_FW_BCM4339_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(BRCM_DIR)
	cp -rad $(@D)/brcm/brcmfmac4339-sdio-prod_*.bin $(BRCM_DIR)
	cd $(BRCM_DIR) && ln -srf brcmfmac4339-sdio-prod_*.bin brcmfmac4339-sdio.bin
	cp -rad $(@D)/brcm/brcmfmac4339-sdio*.txt $(BRCM_DIR)
	cp -rad $(@D)/brcm/BCM4335C0_*.hcd $(BRCM_DIR)
	cd $(BRCM_DIR) && ln -srf BCM4335C0_*.hcd BCM4335C0.hcd
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_BCM4339_MFG),y)
define LAIRD_FW_BCM4339_MFG_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(BRCM_DIR)
	cp -rad $(@D)/brcm/brcmfmac4339-sdio-mfg_*.bin $(BRCM_DIR)
endef
endif

define make_bcm4373sdio_fw
	mkdir -p -m 0755 $(BRCM_DIR)
	cp -rad $(@D)/brcm/brcmfmac4373-clm-$(3).clm_blob $(BRCM_DIR)/brcmfmac4373-clm-$(1).clm_blob
	cd $(BRCM_DIR) && ln -srf brcmfmac4373-clm-$(1).clm_blob brcmfmac4373-sdio.clm_blob
	for file in $(@D)/brcm/BCM4373A0-sdio-$(3)_*.hcd; do basename=$${file##*/}; cp -rad "$$file" "$(BRCM_DIR)/$${basename/$(3)/$(1)}"; done
	cd $(BRCM_DIR) && ln -srf BCM4373A0-sdio-$(1)_*.hcd BCM4373A0.hcd
	cp -rad $(@D)/brcm/brcmfmac4373-$(2).txt $(BRCM_DIR)/brcmfmac4373-$(1).txt
	cd $(BRCM_DIR) && ln -srf brcmfmac4373-$(1).txt brcmfmac4373-sdio.txt
	cp -rad $(@D)/brcm/brcmfmac4373-sdio-prod_*.bin $(BRCM_DIR)
	cd $(BRCM_DIR) && ln -srf brcmfmac4373-sdio-prod_*.bin brcmfmac4373-sdio.bin
endef

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_BCM4373_SDIO_DIV),y)
define LAIRD_FW_BCM4373_SDIO_DIV_INSTALL_TARGET_CMDS
	$(call make_bcm4373sdio_fw,div,div-switch,switch)
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_BCM4373_SDIO_SA),y)
define LAIRD_FW_BCM4373_SDIO_SA_INSTALL_TARGET_CMDS
	$(call make_bcm4373sdio_fw,sa,sa-noswitch,noswitch)
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_BCM4373_SDIO_SA_M2),y)
define LAIRD_FW_BCM4373_SDIO_SA_M2_INSTALL_TARGET_CMDS
	$(call make_bcm4373sdio_fw,sa-m2,sa-switch,switch)
endef
endif

NVRAM_FILE = $(@D)/brcm/brcmfmac4373-$(1).txt
FW_BASE_FILE=$(wildcard $(@D)/brcm/brcmfmac4373-usb-base-$(1)_*.bin)
# Final file will be e.g. brcmfmac4373-usb-div-prod_v13.10.246.261.bin
FW_FINAL_FILE=$(BRCM_DIR)/$(subst usb-base-$(2)_,usb-$(1)-$(2)_,$(notdir $(call FW_BASE_FILE,$(2))))
define make_bcm4373usb_fw
	grep -v NVRAMRev $(call NVRAM_FILE,$(2)) > $(BRCM_DIR)/tmp_nvram.txt
	$(@D)/brcm/bin/nvserial -a -o $(BRCM_DIR)/tmp_nvram.nvm $(BRCM_DIR)/tmp_nvram.txt
	$(@D)/brcm/bin/trxv2 -f 0x20 \
		-x $$(stat -c %s $(call FW_BASE_FILE,$(3))) \
		-x 0x160881 \
		-x $$(stat -c %s $(BRCM_DIR)/tmp_nvram.nvm) \
		-o $(call FW_FINAL_FILE,$(1),$(3)) \
		$(call FW_BASE_FILE,$(3)) $(BRCM_DIR)/tmp_nvram.nvm
	rm -f $(BRCM_DIR)/tmp_nvram.*
endef

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_BCM4373_USB_DIV),y)
define LAIRD_FW_BCM4373_USB_DIV_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(BRCM_DIR)
	cp -rad $(@D)/brcm/brcmfmac4373-clm-switch.clm_blob $(BRCM_DIR)/brcmfmac4373-clm-div.clm_blob
	cd $(BRCM_DIR) && ln -srf brcmfmac4373-clm-div.clm_blob brcmfmac4373.clm_blob
	for file in $(@D)/brcm/BCM4373A0-usb-switch_*.hcd; do basename=$${file##*/}; cp -rad "$$file" "$(BRCM_DIR)/$${basename/usb-switch/usb-div}"; done
	cd $(BRCM_DIR) && ln -srf BCM4373A0-usb-div_*.hcd BCM4373A0-04b4-640c.hcd
	$(call make_bcm4373usb_fw,div,div-switch,prod)
	cd $(BRCM_DIR) && ln -srf $(BRCM_DIR)/brcmfmac4373-usb-div-prod_*.bin brcmfmac4373.bin
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_BCM4373_USB_SA),y)
define LAIRD_FW_BCM4373_USB_SA_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(BRCM_DIR)
	cp -rad $(@D)/brcm/brcmfmac4373-clm-noswitch.clm_blob $(BRCM_DIR)/brcmfmac4373-clm-sa.clm_blob
	cd $(BRCM_DIR) && ln -srf brcmfmac4373-clm-sa.clm_blob brcmfmac4373.clm_blob
	for file in $(@D)/brcm/BCM4373A0-usb-noswitch_*.hcd; do basename=$${file##*/}; cp -rad "$$file" "$(BRCM_DIR)/$${basename/usb-noswitch/usb-sa}"; done
	cd $(BRCM_DIR) && ln -srf BCM4373A0-usb-sa_*.hcd BCM4373A0-04b4-640c.hcd
	$(call make_bcm4373usb_fw,sa,sa-noswitch,prod)
	cd $(BRCM_DIR) && ln -srf $(BRCM_DIR)/brcmfmac4373-usb-sa-prod_*.bin brcmfmac4373.bin
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_BCM4373_USB_SA_M2),y)
define LAIRD_FW_BCM4373_USB_SA_M2_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(BRCM_DIR)
	cp -rad $(@D)/brcm/brcmfmac4373-clm-switch.clm_blob $(BRCM_DIR)/brcmfmac4373-clm-sa-m2.clm_blob
	cd $(BRCM_DIR) && ln -srf brcmfmac4373-clm-sa-m2.clm_blob brcmfmac4373.clm_blob
	for file in $(@D)/brcm/BCM4373A0-usb-switch_*.hcd; do basename=$${file##*/}; cp -rad "$$file" "$(BRCM_DIR)/$${basename/usb-switch/usb-sa-m2}"; done
	cd $(BRCM_DIR) && ln -srf BCM4373A0-usb-sa-m2_*.hcd BCM4373A0-04b4-640c.hcd
	$(call make_bcm4373usb_fw,sa-m2,sa-switch,prod)
	cd $(BRCM_DIR) && ln -srf $(BRCM_DIR)/brcmfmac4373-usb-sa-m2-prod_*.bin brcmfmac4373.bin
endef
endif

# Note - A custom NVRAM file is used for SDIO and USB diversity mfg firmware
#        to disable software diversity and allow manual antenna control
#
#        The NVRAM file is included directly in the regulatory package for SDIO and
#        is also used to build the USB diversity mfg firmware
#        The standard single antenna NVRAM files are used to build USB non-diversity
#        mfg firmware
ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_BCM4373_MFG),y)
define LAIRD_FW_BCM4373_MFG_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(BRCM_DIR)
	$(call make_bcm4373usb_fw,div,div-mfg,mfg)
	$(call make_bcm4373usb_fw,sa,sa-noswitch,mfg)
	$(call make_bcm4373usb_fw,sa-m2,sa-switch,mfg)
	cp -rad $(@D)/brcm/brcmfmac4373-sdio-mfg_*.bin $(BRCM_DIR)
	cp -rad $(@D)/brcm/brcmfmac4373-div-mfg.txt $(BRCM_DIR)
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_CYW55571_PCIE),y)
define LAIRD_FW_CYW55571_PCIE_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(CYPRESS_DIR)
	mkdir -p -m 0755 $(BRCM_DIR)
	cp -rad $(@D)/cypress/cyfmac55560-lwb6x_*.clm_blob $(CYPRESS_DIR)
	cd $(CYPRESS_DIR) && ln -srf cyfmac55560-lwb6x_*.clm_blob cyfmac55560-pcie.clm_blob
	cp -rad $(@D)/cypress/cyfmac55560-pcie-prod_*.trxse $(CYPRESS_DIR)
	cd $(CYPRESS_DIR) && ln -srf cyfmac55560-pcie-prod_*.trxse cyfmac55560-pcie.trxse
	cp -rad $(@D)/cypress/cyfmac55560-lwb6.txt $(CYPRESS_DIR)
	cd $(CYPRESS_DIR) && ln -srf cyfmac55560-lwb6.txt cyfmac55560-pcie.txt
	cp -rad $(@D)/cypress/CYW55560A1_*.hcd $(CYPRESS_DIR)
	cd $(CYPRESS_DIR) && ln -srf CYW55560A1_*.hcd $(BRCM_DIR)/CYW55560A1.hcd
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_CYW55571_SDIO),y)
define LAIRD_FW_CYW55571_SDIO_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(CYPRESS_DIR)
	mkdir -p -m 0755 $(BRCM_DIR)
	cp -rad $(@D)/cypress/cyfmac55560-lwb6x_*.clm_blob $(CYPRESS_DIR)
	cd $(CYPRESS_DIR) && ln -srf cyfmac55560-lwb6x_*.clm_blob cyfmac55560-sdio.clm_blob
	cp -rad $(@D)/cypress/cyfmac55560-sdio-prod_*.trxse $(CYPRESS_DIR)
	cd $(CYPRESS_DIR) && ln -srf cyfmac55560-sdio-prod_*.trxse cyfmac55560-sdio.trxse
	cp -rad $(@D)/cypress/cyfmac55560-lwb6.txt $(CYPRESS_DIR)
	cd $(CYPRESS_DIR) && ln -srf cyfmac55560-lwb6.txt cyfmac55560-sdio.txt
	cp -rad $(@D)/cypress/CYW55560A1_*.hcd $(CYPRESS_DIR)
	cd $(CYPRESS_DIR) && ln -srf CYW55560A1_*.hcd $(BRCM_DIR)/CYW55560A1.hcd
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_CYW55573_PCIE),y)
define LAIRD_FW_CYW55573_PCIE_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(CYPRESS_DIR)
	mkdir -p -m 0755 $(BRCM_DIR)
	cp -rad $(@D)/cypress/cyfmac55560-lwb6x_*.clm_blob $(CYPRESS_DIR)
	cd $(CYPRESS_DIR) && ln -srf cyfmac55560-lwb6x_*.clm_blob cyfmac55560-pcie.clm_blob
	cp -rad $(@D)/cypress/cyfmac55560-pcie-prod_*.trxse $(CYPRESS_DIR)
	cd $(CYPRESS_DIR) && ln -srf cyfmac55560-pcie-prod_*.trxse cyfmac55560-pcie.trxse
	cp -rad $(@D)/cypress/cyfmac55560-lwb6plus.txt $(CYPRESS_DIR)
	cd $(CYPRESS_DIR) && ln -srf cyfmac55560-lwb6plus.txt cyfmac55560-pcie.txt
	cp -rad $(@D)/cypress/CYW55560A1_*.hcd $(CYPRESS_DIR)
	cd $(CYPRESS_DIR) && ln -srf CYW55560A1_*.hcd $(BRCM_DIR)/CYW55560A1.hcd
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_CYW55573_SDIO),y)
define LAIRD_FW_CYW55573_SDIO_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(CYPRESS_DIR)
	mkdir -p -m 0755 $(BRCM_DIR)
	cp -rad $(@D)/cypress/cyfmac55560-lwb6x_*.clm_blob $(CYPRESS_DIR)
	cd $(CYPRESS_DIR) && ln -srf cyfmac55560-lwb6x_*.clm_blob cyfmac55560-sdio.clm_blob
	cp -rad $(@D)/cypress/cyfmac55560-sdio-prod_*.trxse $(CYPRESS_DIR)
	cd $(CYPRESS_DIR) && ln -srf cyfmac55560-sdio-prod_*.trxse cyfmac55560-sdio.trxse
	cp -rad $(@D)/cypress/cyfmac55560-lwb6plus.txt $(CYPRESS_DIR)
	cd $(CYPRESS_DIR) && ln -srf cyfmac55560-lwb6plus.txt cyfmac55560-sdio.txt
	cp -rad $(@D)/cypress/CYW55560A1_*.hcd $(CYPRESS_DIR)
	cd $(CYPRESS_DIR) && ln -srf CYW55560A1_*.hcd $(BRCM_DIR)/CYW55560A1.hcd
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_CYW5557X_MFG),y)
define LAIRD_FW_CYW5557X_MFG_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(CYPRESS_DIR)
	cp -rad $(@D)/cypress/cyfmac55560-pcie-mfg_*.trxse $(CYPRESS_DIR)
	cp -rad $(@D)/cypress/cyfmac55560-sdio-mfg_*.trxse $(CYPRESS_DIR)
endef
endif

define LAIRD_FW_LRDMWL_INSTALL_CMDS
	$(INSTALL) -D -m 0644 -t $(LRDMWL_DIR) \
		$(@D)/lrdmwl/regpwr_60.db \
		$(@D)/lrdmwl/$(1)/88W8997_$(1)_$(2)_$(3)_*.bin
	ln -rsf $(LRDMWL_DIR)/88W8997_$(1)_$(2)_$(3)_*.bin $(LRDMWL_DIR)/88W8997_$(2).bin
	ln -rsf ${LRDMWL_DIR}/regpwr_60.db ${LRDMWL_DIR}/regpwr.db
endef

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_ST60_SDIO_UART),y)
LAIRD_FW_LRDMWL_ST60_SDIO_UART_INSTALL_TARGET_CMDS = $(call LAIRD_FW_LRDMWL_INSTALL_CMDS,ST,sdio,uart)
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_ST60_SDIO_SDIO),y)
LAIRD_FW_LRDMWL_ST60_SDIO_SDIO_INSTALL_TARGET_CMDS = $(call LAIRD_FW_LRDMWL_INSTALL_CMDS,ST,sdio,sdio)
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_ST60_PCIE_UART),y)
LAIRD_FW_LRDMWL_ST60_PCIE_UART_INSTALL_TARGET_CMDS = $(call LAIRD_FW_LRDMWL_INSTALL_CMDS,ST,pcie,uart)
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_ST60_PCIE_USB),y)
LAIRD_FW_LRDMWL_ST60_PCIE_USB_INSTALL_TARGET_CMDS = $(call LAIRD_FW_LRDMWL_INSTALL_CMDS,ST,pcie,usb)
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_ST60_USB_UART),y)
LAIRD_FW_LRDMWL_ST60_USB_UART_INSTALL_TARGET_CMDS = $(call LAIRD_FW_LRDMWL_INSTALL_CMDS,ST,usb,uart)
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_ST60_USB_USB),y)
LAIRD_FW_LRDMWL_ST60_USB_USB_INSTALL_TARGET_CMDS = $(call LAIRD_FW_LRDMWL_INSTALL_CMDS,ST,usb,usb)
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SU60_SDIO_UART),y)
LAIRD_FW_LRDMWL_SU60_SDIO_UART_INSTALL_TARGET_CMDS = $(call LAIRD_FW_LRDMWL_INSTALL_CMDS,SU,sdio,uart)
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SU60_SDIO_SDIO),y)
LAIRD_FW_LRDMWL_SU60_SDIO_SDIO_INSTALL_TARGET_CMDS = $(call LAIRD_FW_LRDMWL_INSTALL_CMDS,SU,sdio,sdio)
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SU60_PCIE_UART),y)
LAIRD_FW_LRDMWL_SU60_PCIE_UART_INSTALL_TARGET_CMDS = $(call LAIRD_FW_LRDMWL_INSTALL_CMDS,SU,pcie,uart)
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SU60_PCIE_USB),y)
LAIRD_FW_LRDMWL_SU60_PCIE_USB_INSTALL_TARGET_CMDS = $(call LAIRD_FW_LRDMWL_INSTALL_CMDS,SU,pcie,usb)
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SU60_USB_UART),y)
LAIRD_FW_LRDMWL_SU60_USB_UART_INSTALL_TARGET_CMDS = $(call LAIRD_FW_LRDMWL_INSTALL_CMDS,SU,usb,uart)
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SU60_USB_USB),y)
LAIRD_FW_LRDMWL_SU60_USB_USB_INSTALL_TARGET_CMDS = $(call LAIRD_FW_LRDMWL_INSTALL_CMDS,SU,usb,usb)
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SOM60),y)
LAIRD_FW_LRDMWL_SOM60_INSTALL_TARGET_CMDS = $(call LAIRD_FW_LRDMWL_INSTALL_CMDS,SOM,sdio,uart)
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SOM8MP),y)
define LAIRD_FW_LRDMWL_SOM8MP_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 -t $(LRDMWL_DIR) \
		$(@D)/lrdmwl/regpwr_som8mp.db \
		$(@D)/lrdmwl/SOM8MP/88W8997_SOM8MP_*.bin
	ln -rsf $(LRDMWL_DIR)/88W8997_SOM8MP_sdio_uart_*.bin $(LRDMWL_DIR)/88W8997_sdio.bin
	ln -rsf $(LRDMWL_DIR)/88W8997_SOM8MP_pcie_uart_*.bin $(LRDMWL_DIR)/88W8997_pcie.bin
	ln -rsf ${LRDMWL_DIR}/regpwr_som8mp.db ${LRDMWL_DIR}/regpwr.db
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_LRDMWL_SD8997_MFG),y)
define LAIRD_FW_LRDMWL_SD8997_MFG_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 -t $(LRDMWL_DIR) $(@D)/lrdmwl/mfg/*
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
	cp -ra $(@D)/ti-connectivity $(TARGET_DIR)/lib/firmware
endef
endif

ifeq ($(BR2_PACKAGE_LAIRD_FIRMWARE_BT),y)
define LAIRD_FW_BT50_INSTALL_TARGET_CMDS
	mkdir -p -m 0755 $(TARGET_DIR)/lib/firmware
	cp -ra $(@D)/bluetopia $(TARGET_DIR)/lib/firmware
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
	$(LAIRD_FW_BCM4343_MFG_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_BCM43439_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_BCM43439_MFG_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_BCM4339_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_BCM4339_MFG_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_BCM4373_SDIO_DIV_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_BCM4373_SDIO_SA_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_BCM4373_SDIO_SA_M2_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_BCM4373_USB_DIV_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_BCM4373_USB_SA_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_BCM4373_USB_SA_M2_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_BCM4373_MFG_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_CYW55571_SDIO_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_CYW55571_PCIE_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_CYW55573_SDIO_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_CYW55573_PCIE_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_CYW5557X_MFG_INSTALL_TARGET_CMDS)
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
	$(LAIRD_FW_LRDMWL_SOM8MP_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_LRDMWL_SD8997_MFG_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_MRVL_SD8997_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_WL18XX_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_BT50_INSTALL_TARGET_CMDS)
	$(LAIRD_FW_AR9271_INSTALL_TARGET_CMDS)
endef

$(eval $(generic-package))
