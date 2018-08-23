
ST_IMAGE_DIR := $(BA_DIR)/images
TMP_DIR := $(TAR_DIR)/tmp
RELEASE_STRING ?= $(shell date +%Y%m%d)

6003_NAME := laird-ath6k-6003-firmware-$(RELEASE_STRING)
6004_NAME := laird-ath6k-6004-firmware-$(RELEASE_STRING)

6003_OUT := $(TAR_DIR)/root/$(6003_NAME)
6004_OUT := $(TAR_DIR)/root/$(6004_NAME)

ZIP := zip
TAR_CJF := tar --owner=root --group=root -cjf

ST_ATH6K_DIR := $(BUD_DIR)/wireless-firmware-$(RELEASE_STRING)/ath6k

$(6003_OUT):
	rm $(6003_OUT)  -fr
	mkdir -p $(6003_OUT)

$(6004_OUT):
	rm $(6004_OUT)  -fr
	mkdir -p $(6004_OUT)

$(ST_IMAGE_DIR)/$(6003_NAME).tar.bz2: 6003-staging
	$(TAR_CJF) $@ -C $(6003_OUT) lib

$(ST_IMAGE_DIR)/$(6004_NAME).tar.bz2: 6004-staging
	$(TAR_CJF) $@ -C $(6004_OUT) lib

6003-staging: $(6003_OUT)
	mkdir -p $(6003_OUT)/lib/firmware/ath6k/AR6003
	cp -dr $(ST_ATH6K_DIR)/AR6003 $(6003_OUT)/lib/firmware/ath6k/
	cp -dr $(TAR_DIR)/lib/firmware/regulatory.* $(6003_OUT)/lib/firmware/
	cp $(TAR_DIR)/lib/firmware/regulatory_default.db $(6003_OUT)/lib/firmware/ -f

6004-staging: $(6004_OUT)
	mkdir -p $(6004_OUT)/lib/firmware/ath6k/AR6004
	cp -dr $(ST_ATH6K_DIR)/AR6004 $(6004_OUT)/lib/firmware/ath6k/
	cp -dr $(TAR_DIR)/lib/firmware/regulatory.* $(6004_OUT)/lib/firmware/
	cp $(TAR_DIR)/lib/firmware/regulatory_default.db $(6004_OUT)/lib/firmware/ -f
	rm -f $(6004_OUT)/lib/firmware/ath6k/AR6004/hw3.0/qca*

ath6k-6003: $(ST_IMAGE_DIR)/$(6003_NAME).tar.bz2
ath6k-6004: $(ST_IMAGE_DIR)/$(6004_NAME).tar.bz2
