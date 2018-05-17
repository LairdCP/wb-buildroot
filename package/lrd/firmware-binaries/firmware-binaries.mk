FIRMWARE_BINARIES_VERSION = 0.0.0.0
FIRMWARE_BINARIES_SOURCE = firmware-binaries-$(FIRMWARE_BINARIES_VERSION).tar.bz2
FIRMWARE_BINARIES_LICENSE = GPL-2.0
FIRMWARE_BINARIES_LICENSE_FILES = COPYING
FIRMWARE_BINARIES_SITE = http://devops.lairdtech.com/share/builds/linux/firmware

STERLING-LWB-FCC=480-0079
STERLING-LWB-ETSI=480-0080
STERLING-LWB-JP=480-0116
STERLING-LWB5-FCC=480-0081
STERLING-LWB5-ETSI=480-0082
STERLING-LWB5-IC=480-0094
STERLING-LWB5-JP=480-0095
STERLING-LWB-MFG=laird-lwb-firmware-mfg
STERLING-LWB5-MFG=laird-lwb5-firmware-mfg
WL-FMAC=930-0081
STERLING-60=laird-sterling-60

# Each firmware needs to be released individually. We don't want to have a monolithic
# firmware tarball. However, we need a fake one to make buildroot work.

define FIRMWARE_BINARIES_PRE_DOWNLOAD_FAKE_TARBALL
	touch $(BR2_DL_DIR)/$(FIRMWARE_BINARIES_SOURCE)
	if [ -d $(BUILD_DIR)/firmware-binaries-$(FIRMWARE_BINARIES_VERSION) ]; \
	then	\
		mkdir $(BUILD_DIR)/firmware-binaries-$(FIRMWARE_BINARIES_VERSION);\
	fi;
endef
FIRMWARE_BINARIES_PRE_DOWNLOAD_HOOKS += FIRMWARE_BINARIES_PRE_DOWNLOAD_FAKE_TARBALL

define FIRMWARE_BINARIES_EXTRACT_CMDS

endef

define download-firmware-func
	if [ ! -f $(BR2_DL_DIR)/$(1)-$(FIRMWARE_BINARIES_VERSION).$(2) ];	\
	then	\
		wget -P $(BR2_DL_DIR)/ $(FIRMWARE_BINARIES_SITE)/$(FIRMWARE_BINARIES_VERSION)/$(1)-$(FIRMWARE_BINARIES_VERSION).$(2);\
	fi
endef

define install-firmware-func
	rm $(@D)/lib -fr;
	cp $(BR2_DL_DIR)/$(1)-$(FIRMWARE_BINARIES_VERSION).$(2) $(@D)/ -fr;
	if [ $(2) == zip ];\
	then \
		cd $(@D); unzip -u $(1)-$(FIRMWARE_BINARIES_VERSION).$(2);\
	fi;
	cd $(@D) && tar -xjf $(1)*.tar.bz2;
	cp $(@D)/lib/firmware/* $(TARGET_DIR)/lib/firmware/ -dprf;
endef


define FIRMWARE_BINARIES_480_0079_INSTALL_TARGET
	$(call download-firmware-func,$(STERLING-LWB-FCC),zip)
	$(call install-firmware-func,$(STERLING-LWB-FCC),zip)
endef
ifeq ($(BR2_FIRMWARE_BINARIES_480_0079),y)
	FIRMWARE_BINARIES_POST_INSTALL_TARGET_HOOKS += FIRMWARE_BINARIES_480_0079_INSTALL_TARGET
endif

define FIRMWARE_BINARIES_480_0080_INSTALL_TARGET
	$(call download-firmware-func,$(STERLING-LWB-ETSI),zip)
	$(call install-firmware-func,$(STERLING-LWB-ETSI),zip)
endef
ifeq ($(BR2_FIRMWARE_BINARIES_480_0080),y)
	FIRMWARE_BINARIES_POST_INSTALL_TARGET_HOOKS += FIRMWARE_BINARIES_480_0080_INSTALL_TARGET
endif

define FIRMWARE_BINARIES_480_0081_INSTALL_TARGET
	$(call download-firmware-func,$(STERLING-LWB5-FCC),zip)
	$(call install-firmware-func,$(STERLING-LWB5-FCC),zip)
endef
ifeq ($(BR2_FIRMWARE_BINARIES_480_0081),y)
	FIRMWARE_BINARIES_POST_INSTALL_TARGET_HOOKS += FIRMWARE_BINARIES_480_0081_INSTALL_TARGET
endif

define FIRMWARE_BINARIES_480_0082_INSTALL_TARGET
	$(call download-firmware-func,$(STERLING-LWB5-ETSI),zip)
	$(call install-firmware-func,$(STERLING-LWB5-ETSI),zip)
endef
ifeq ($(BR2_FIRMWARE_BINARIES_480_0082),y)
	FIRMWARE_BINARIES_POST_INSTALL_TARGET_HOOKS += FIRMWARE_BINARIES_480_0082_INSTALL_TARGET
endif

define FIRMWARE_BINARIES_480_0094_INSTALL_TARGET
	$(call download-firmware-func,$(STERLING-LWB5-IC),zip)
	$(call install-firmware-func,$(STERLING-LWB5-IC),zip)
endef
ifeq ($(BR2_FIRMWARE_BINARIES_480_0094),y)
	FIRMWARE_BINARIES_POST_INSTALL_TARGET_HOOKS += FIRMWARE_BINARIES_480_0094_INSTALL_TARGET
endif

define FIRMWARE_BINARIES_480_0095_INSTALL_TARGET
	$(call download-firmware-func,$(STERLING-LWB5-JP),zip)
	$(call install-firmware-func,$(STERLING-LWB5-JP),zip)
endef
ifeq ($(BR2_FIRMWARE_BINARIES_480_0095),y)
	FIRMWARE_BINARIES_POST_INSTALL_TARGET_HOOKS += FIRMWARE_BINARIES_480_0095_INSTALL_TARGET
endif

define FIRMWARE_BINARIES_480_0116_INSTALL_TARGET
	$(call download-firmware-func,$(STERLING-LWB-JP),zip)
	$(call install-firmware-func,$(STERLING-LWB-JP),zip)
endef
ifeq ($(BR2_FIRMWARE_BINARIES_480_0116),y)
	FIRMWARE_BINARIES_POST_INSTALL_TARGET_HOOKS += FIRMWARE_BINARIES_480_0116_INSTALL_TARGET
endif

define FIRMWARE_BINARIES_480_0108_INSTALL_TARGET
	rm $(@D)/lib -fr;
	$(call download-firmware-func,$(STERLING-LWB-MFG),tar.bz2)
	$(call install-firmware-func,$(STERLING-LWB-MFG),tar.bz2)
endef
ifeq ($(BR2_FIRMWARE_BINARIES_480_0108),y)
	FIRMWARE_BINARIES_POST_INSTALL_TARGET_HOOKS += FIRMWARE_BINARIES_480_0108_INSTALL_TARGET
endif

define FIRMWARE_BINARIES_480_0109_INSTALL_TARGET
	rm $(@D)/lib -fr;
	$(call download-firmware-func,$(STERLING-LWB5-MFG),tar.bz2)
	$(call install-firmware-func,$(STERLING-LWB5-MFG),tar.bz2)
endef
ifeq ($(BR2_FIRMWARE_BINARIES_480_0109),y)
	FIRMWARE_BINARIES_POST_INSTALL_TARGET_HOOKS += FIRMWARE_BINARIES_480_0109_INSTALL_TARGET
endif

define FIRMWARE_BINARIES_930_0081_INSTALL_TARGET
	rm $(@D)/wl_fmac -fr
	$(call download-firmware-func,$(WL-FMAC),zip)
	cp $(BR2_DL_DIR)/$(WL-FMAC)-$(FIRMWARE_BINARIES_VERSION).zip $(@D)/ -fr
	cd $(@D) && unzip -u $(WL-FMAC)-$(FIRMWARE_BINARIES_VERSION).zip;
	cp $(@D)/wl_fmac $(TARGET_DIR)/usr/bin/ -f;
endef
ifeq ($(BR2_FIRMWARE_BINARIES_930_0081),y)
	FIRMWARE_BINARIES_POST_INSTALL_TARGET_HOOKS += FIRMWARE_BINARIES_930_0081_INSTALL_TARGET
endif

define FIRMWARE_BINARIES_STERLING_60_INSTALL_TARGET
	rm $(@D)/lib/ -fr;
	$(call download-firmware-func,$(STERLING-60),tar.bz2)
	$(call install-firmware-func,$(STERLING-60),tar.bz2)
endef
ifeq ($(BR2_FIRMWARE_BINARIES_STERLING_60),y)
	FIRMWARE_BINARIES_POST_INSTALL_TARGET_HOOKS += FIRMWARE_BINARIES_STERLING_60_INSTALL_TARGET
endif

FIRMWARE_BINARIES_DEPENDENCIES += linux

$(eval $(generic-package))
