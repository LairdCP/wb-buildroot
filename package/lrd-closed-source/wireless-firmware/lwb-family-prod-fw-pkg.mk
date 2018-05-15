
ST_IMAGE_DIR := $(BA_DIR)/images
TMP_DIR := $(TAR_DIR)/tmp
RELEASE_STRING ?= $(shell date +%Y%m%d)

LWB_MFG_NAME := laird-lwb-firmware-mfg-$(RELEASE_STRING)
LWB5_MFG_NAME := laird-lwb5-firmware-mfg-$(RELEASE_STRING)
60_NAME := laird-sterling-60-$(RELEASE_STRING)
WL_FMAC_930_0081_NAME := 930-0081-$(RELEASE_STRING)

LWB_MFG_OUT := $(TAR_DIR)/root/$(LWB_MFG_NAME)
LWB5_MFG_OUT := $(TAR_DIR)/root/$(LWB5_MFG_NAME)
60_OUT := $(TAR_DIR)/root/$(60_NAME)

ST_BRCM_DIR := $(BUD_DIR)/wireless-firmware-$(RELEASE_STRING)/brcm
ST_LRDMWL_DIR := $(BUD_DIR)/wireless-firmware-$(RELEASE_STRING)/lrdmwl

ZIP := zip
TAR_CJF := tar --owner=root --group=root -cjf

$(LWB_MFG_OUT):
	rm $(LWB_MFG_OUT) -fr
	mkdir -p $(LWB_MFG_OUT)

$(LWB5_MFG_OUT):
	rm $(LWB5_MFG_OUT) -fr
	mkdir -p $(LWB5_MFG_OUT)

$(60_OUT):
	rm $(60_OUT)  -fr
	mkdir -p $(60_OUT)

$(ST_IMAGE_DIR)/$(LWB_MFG_NAME).tar.bz2: lwb-mfg-staging
	cd $(LWB_MFG_OUT); $(TAR_CJF) $(@F) lib
	cp $(LWB_MFG_OUT)/$(@F) $(ST_IMAGE_DIR)/

$(ST_IMAGE_DIR)/480-0108-$(RELEASE_STRING).zip: $(ST_IMAGE_DIR)/$(LWB_MFG_NAME).tar.bz2
	cd $(ST_IMAGE_DIR); zip $@ $(LWB_MFG_NAME).tar.bz2

$(ST_IMAGE_DIR)/$(LWB5_MFG_NAME).tar.bz2: lwb5-mfg-staging
	cd $(LWB5_MFG_OUT); $(TAR_CJF) $(@F) lib
	cp $(LWB5_MFG_OUT)/$(@F) $(ST_IMAGE_DIR)/

$(ST_IMAGE_DIR)/480-0109-$(RELEASE_STRING).zip: $(ST_IMAGE_DIR)/$(LWB5_MFG_NAME).tar.bz2
	cd $(ST_IMAGE_DIR) ; zip $@ $(LWB5_MFG_NAME).tar.bz2

$(ST_IMAGE_DIR)/$(60_NAME).tar.bz2: 60-staging
	cd $(60_OUT) ; $(TAR_CJF) $@ lib

$(ST_IMAGE_DIR)/$(WL_FMAC_930_0081_NAME).zip:$(TMP_DIR)/$(WL_FMAC_930_0081_NAME).zip
	cp -f $^ $@

lwb-mfg-staging:$(LWB_MFG_OUT)
	mkdir -p $(LWB_MFG_OUT)/lib/firmware/brcm/bcm4343w
	cd $(LWB_MFG_OUT)/lib/firmware/brcm/bcm4343w ; \
	cp $(ST_BRCM_DIR)/bcm4343w/brcmfmac43430-sdio-*.bin . ; \
	ln -s brcmfmac43430-sdio-mfg.bin brcmfmac43430-sdio.bin ; \
	cp $(ST_BRCM_DIR)/bcm4343w/brcmfmac43430-sdio-*.txt . ; \
	ln -s brcmfmac43430-sdio-fcc.txt brcmfmac43430-sdio.txt ; \
	cp $(ST_BRCM_DIR)/bcm4343w/4343w.hcd .
	cd $(LWB_MFG_OUT)/lib/firmware/brcm ; \
	ln -sf ./bcm4343w/brcmfmac43430-sdio.bin . ; \
	ln -sf ./bcm4343w/brcmfmac43430-sdio.txt . ; \
	ln -sf ./bcm4343w/4343w.hcd .

lwb5-mfg-staging:$(LWB5_MFG_OUT)
	mkdir -p $(LWB5_MFG_OUT)/lib/firmware/brcm/bcm4339
	cd $(LWB5_MFG_OUT)/lib/firmware/brcm/bcm4339 ; \
	cp $(ST_BRCM_DIR)/bcm4339/brcmfmac4339-sdio-*.bin . ; \
	ln -s brcmfmac4339-sdio-mfg.bin brcmfmac4339-sdio.bin ; \
	cp $(ST_BRCM_DIR)/bcm4339/brcmfmac4339-sdio-*.txt . ; \
	ln -s brcmfmac4339-sdio-fcc.txt brcmfmac4339-sdio.txt ; \
	cp $(ST_BRCM_DIR)/bcm4339/4339.hcd . ; \
	cd $(LWB5_MFG_OUT)/lib/firmware/brcm ; \
	ln -sf ./bcm4339/brcmfmac4339-sdio.bin . ; \
	ln -sf ./bcm4339/brcmfmac4339-sdio.txt . ; \
	ln -sf ./bcm4339/4339.hcd .

60-staging: $(60_OUT)
	mkdir -p $(60_OUT)/lib/firmware/
	mkdir -p $(60_OUT)/lib/firmware/lrdmwl
	cp -d $(ST_LRDMWL_DIR)/*.bin $(60_OUT)/lib/firmware/lrdmwl

$(TMP_DIR)/$(WL_FMAC_930_0081_NAME).zip: $(T_DIR)/package/lrd-closed-source/externals/wl_fmac/bin/930-0081/wl_fmac
	zip --junk-paths $@ $^

lwb-mfg: $(ST_IMAGE_DIR)/480-0108-$(RELEASE_STRING).zip $(ST_IMAGE_DIR)/$(LWB_MFG_NAME).tar.bz2

lwb5-mfg: $(ST_IMAGE_DIR)/480-0109-$(RELEASE_STRING).zip $(ST_IMAGE_DIR)/$(LWB5_MFG_NAME).tar.bz2

60: $(ST_IMAGE_DIR)/$(60_NAME).tar.bz2

wl: $(ST_IMAGE_DIR)/$(WL_FMAC_930_0081_NAME).zip
