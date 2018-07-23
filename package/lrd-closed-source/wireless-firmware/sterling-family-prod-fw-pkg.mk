
OUT_DIR := $(dir $(OUT_FILE))
ARCHIVE_ROOT := $(TAR_DIR)/root/$(FW_PKG_LSR_PN)
TMP_DIR := $(TAR_DIR)/tmp
HINT_FILE := $(OUT_FILE)-$(CHIP_NAME)-$(REGION).hint

ZIP := zip
TAR_F := tar --owner=root --group=root -cjf
CP_F := cp -f

#  .clm_blob files may or may not be present for a particular
#  $(BRCMFMAC_CHIP_ID).  If present, we need to include it.  If not
#  present, this will expand to an empty string so there will not be a
#  dependency for it.
BLOB_FILE := $(shell [ -e $(FW_REPO_DIR)/brcm/bcm$(CHIP_NAME)/brcmfmac$(BRCMFMAC_CHIP_ID)-sdio.clm_blob ] && echo $(ARCHIVE_ROOT)/lib/firmware/brcm/brcmfmac$(BRCMFMAC_CHIP_ID)-sdio.clm_blob)


$(OUT_FILE): $(TMP_DIR)/$(FW_PKG_LSR_PN).zip | $(OUT_DIR) $(HINT_FILE)
	$(CP_F) $< $@

$(HINT_FILE): $(OUT_DIR)
	touch $@

$(TMP_DIR)/$(FW_PKG_LSR_PN).zip: $(TMP_DIR)/$(FW_PKG_LSR_PN).tar.bz2
	$(ZIP) -j $@ $<

$(TMP_DIR)/$(FW_PKG_LSR_PN).tar.bz2: $(ARCHIVE_ROOT)/lib/firmware/brcm/brcmfmac$(BRCMFMAC_CHIP_ID)-sdio.bin $(ARCHIVE_ROOT)/lib/firmware/brcm/brcmfmac$(BRCMFMAC_CHIP_ID)-sdio.txt $(ARCHIVE_ROOT)/lib/firmware/brcm/$(CHIP_NAME).hcd $(BLOB_FILE) $(ARCHIVE_ROOT)/lib/firmware/regulatory.db | $(OUT_DIR)
	$(TAR_F) $@ -C $(ARCHIVE_ROOT) lib

$(ARCHIVE_ROOT)/lib/firmware/brcm/brcmfmac$(BRCMFMAC_CHIP_ID)-sdio.bin: $(ARCHIVE_ROOT)/lib/firmware/brcm/bcm$(CHIP_NAME)/brcmfmac$(BRCMFMAC_CHIP_ID)-sdio.bin
	ln -rsf $< $@

$(ARCHIVE_ROOT)/lib/firmware/brcm/brcmfmac$(BRCMFMAC_CHIP_ID)-sdio.clm_blob: $(ARCHIVE_ROOT)/lib/firmware/brcm/bcm$(CHIP_NAME)/brcmfmac$(BRCMFMAC_CHIP_ID)-sdio.clm_blob
	ln -rsf $< $@

$(ARCHIVE_ROOT)/lib/firmware/brcm/brcmfmac$(BRCMFMAC_CHIP_ID)-sdio.txt: $(ARCHIVE_ROOT)/lib/firmware/brcm/bcm$(CHIP_NAME)/brcmfmac$(BRCMFMAC_CHIP_ID)-sdio.txt
	ln -rsf $< $@

$(ARCHIVE_ROOT)/lib/firmware/brcm/$(CHIP_NAME).hcd: $(ARCHIVE_ROOT)/lib/firmware/brcm/bcm$(CHIP_NAME)/$(CHIP_NAME).hcd
	ln -rsf $< $@

$(ARCHIVE_ROOT)/lib/firmware/brcm/bcm$(CHIP_NAME)/brcmfmac$(BRCMFMAC_CHIP_ID)-sdio.bin: $(ARCHIVE_ROOT)/lib/firmware/brcm/bcm$(CHIP_NAME)/brcmfmac$(BRCMFMAC_CHIP_ID)-sdio-prod.bin
	ln -rsf $< $@

$(ARCHIVE_ROOT)/lib/firmware/brcm/bcm$(CHIP_NAME)/brcmfmac$(BRCMFMAC_CHIP_ID)-sdio.txt: $(ARCHIVE_ROOT)/lib/firmware/brcm/bcm$(CHIP_NAME)/brcmfmac$(BRCMFMAC_CHIP_ID)-sdio-$(REGION).txt
	ln -rsf $< $@

$(ARCHIVE_ROOT)/lib/firmware/brcm/bcm$(CHIP_NAME)/brcmfmac$(BRCMFMAC_CHIP_ID)-sdio-prod.bin: $(FW_REPO_DIR)/brcm/bcm$(CHIP_NAME)/brcmfmac$(BRCMFMAC_CHIP_ID)-sdio-prod.bin | $(ARCHIVE_ROOT)/lib/firmware/brcm/bcm$(CHIP_NAME)
	$(CP_F) $< $@

$(ARCHIVE_ROOT)/lib/firmware/brcm/bcm$(CHIP_NAME)/brcmfmac$(BRCMFMAC_CHIP_ID)-sdio.clm_blob: $(FW_REPO_DIR)/brcm/bcm$(CHIP_NAME)/brcmfmac$(BRCMFMAC_CHIP_ID)-sdio.clm_blob | $(ARCHIVE_ROOT)/lib/firmware/brcm/bcm$(CHIP_NAME)
	$(CP_F) $< $@

$(ARCHIVE_ROOT)/lib/firmware/brcm/bcm$(CHIP_NAME)/brcmfmac$(BRCMFMAC_CHIP_ID)-sdio-$(REGION).txt: $(FW_REPO_DIR)/brcm/bcm$(CHIP_NAME)/brcmfmac$(BRCMFMAC_CHIP_ID)-sdio-$(REGION).txt | $(ARCHIVE_ROOT)/lib/firmware/brcm/bcm$(CHIP_NAME)
	$(CP_F) $< $@

$(ARCHIVE_ROOT)/lib/firmware/brcm/bcm$(CHIP_NAME)/$(CHIP_NAME).hcd: $(FW_REPO_DIR)/brcm/bcm$(CHIP_NAME)/$(CHIP_NAME).hcd | $(ARCHIVE_ROOT)/lib/firmware/brcm/bcm$(CHIP_NAME)
	$(CP_F) $< $@

$(ARCHIVE_ROOT)/lib/firmware/brcm/bcm$(CHIP_NAME):
	mkdir -p $@

$(ARCHIVE_ROOT)/lib/firmware/regulatory.db:
	$(CP_F) $(TAR_DIR)/lib/firmware/regulatory_$(REGION).db $(ARCHIVE_ROOT)/lib/firmware
	ln -rsf $(ARCHIVE_ROOT)/lib/firmware/regulatory_$(REGION).db $(ARCHIVE_ROOT)/lib/firmware/regulatory.db
	mkdir -p $(ARCHIVE_ROOT)/usr/lib/crda
	$(CP_F) $(TAR_DIR)/usr/lib/crda/regulatory_$(REGION).bin $(ARCHIVE_ROOT)/usr/lib/crda
	ln -rsf $(ARCHIVE_ROOT)/usr/lib/crda/regulatory_$(REGION).bin $(ARCHIVE_ROOT)/usr/lib/crda/regulatory.bin
