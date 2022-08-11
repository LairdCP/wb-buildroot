#####################################################################
# Laird Web Configuration Utility
#####################################################################

WEBLCM_PYTHON_VERSION = local
WEBLCM_PYTHON_SITE = package/lrd/externals/weblcm-python
WEBLCM_PYTHON_SITE_METHOD = local
WEBLCM_PYTHON_SETUP_TYPE = setuptools
WEBLCM_PYTHON_DEPENDENCIES = lrd-swupdate-client

TARGET_PYTHON_VERSION := $$(find $(TARGET_DIR)/usr/lib -maxdepth 1 -type d -name python* -printf "%f\n" | egrep -o '[0-9].[0-9]')
WEBLCM_PYTHON_SET_KEY_LOCATION_VALUE = $(call qstrip,$(BR2_PACKAGE_WEBLCM_PYTHON_SWUPDATE_KEY_LOCATION))
WEBLCM_PYTHON_DEFAULT_USERNAME = $(call qstrip,$(BR2_PACKAGE_WEBLCM_PYTHON_DEFAULT_USERNAME))
WEBLCM_PYTHON_DEFAULT_PASSWORD = $(call qstrip,$(BR2_PACKAGE_WEBLCM_PYTHON_DEFAULT_PASSWORD))

ifeq ($(BR2_PACKAGE_WEBLCM_PYTHON_AWM),y)
	WEBLCM_PYTHON_EXTRA_PACKAGES += weblcm/awm
endif
ifeq ($(BR2_PACKAGE_WEBLCM_PYTHON_MODEM),y)
	WEBLCM_PYTHON_EXTRA_PACKAGES += weblcm/modem
endif
ifeq ($(BR2_PACKAGE_WEBLCM_PYTHON_BLUETOOTH),y)
	WEBLCM_PYTHON_EXTRA_PACKAGES += weblcm/bluetooth
endif
ifeq ($(BR2_PACKAGE_WEBLCM_PYTHON_HID),y)
	WEBLCM_PYTHON_EXTRA_PACKAGES += weblcm/hid
endif
ifeq ($(BR2_PACKAGE_WEBLCM_PYTHON_VSP),y)
	WEBLCM_PYTHON_EXTRA_PACKAGES += weblcm/vsp
endif
ifeq ($(BR2_PACKAGE_WEBLCM_PYTHON_UNAUTHENTICATED),y)
	WEBLCM_PYTHON_ENABLE_UNAUTHENTICATED = True
else
	WEBLCM_PYTHON_ENABLE_UNAUTHENTICATED = False
endif

WEBLCM_PYTHON_ENV = WEBLCM_PYTHON_EXTRA_PACKAGES='$(WEBLCM_PYTHON_EXTRA_PACKAGES)'

ifeq ($(BR2_REPRODUCIBLE),y)
define WEBLCM_PYTHON_FIX_TIME
	sed -i -e 's/ExecStart=python/ExecStart=python --check-hash-based-pycs never/g' $(TARGET_DIR)/usr/lib/systemd/system/weblcm-python.service
endef
endif

define WEBLCM_PYTHON_POST_INSTALL_TARGET_HOOK_CMDS
	$(INSTALL) -D -t $(TARGET_DIR)/var/www/assets/fonts -m 644 $(WEBLCM_PYTHON_SITE)/assets/fonts/*
	$(INSTALL) -D -t $(TARGET_DIR)/var/www/assets/css -m 644 $(WEBLCM_PYTHON_SITE)/assets/css/*.css
	$(INSTALL) -D -t $(TARGET_DIR)/var/www/assets/img -m 644 $(WEBLCM_PYTHON_SITE)/assets/img/*.png
	$(INSTALL) -D -t $(TARGET_DIR)/var/www/assets/js -m 644 $(WEBLCM_PYTHON_SITE)/assets/js/*.js
	$(INSTALL) -D -t $(TARGET_DIR)/var/www/assets/i18n -m 644 $(WEBLCM_PYTHON_SITE)/assets/i18n/*.json
	$(INSTALL) -D -t $(TARGET_DIR)/var/www -m 644 $(WEBLCM_PYTHON_SITE)/LICENSE

	cp -fr $(WEBLCM_PYTHON_SITE)/plugins $(TARGET_DIR)/var/www/

	$(INSTALL) -D -t $(TARGET_DIR)/usr/bin/weblcm-python.scripts -m 755 $(WEBLCM_PYTHON_SITE)/*.sh
	$(INSTALL) -D -t $(TARGET_DIR)/etc/weblcm-python -m 644 $(WEBLCM_PYTHON_SITE)/*.ini
	$(INSTALL) -D -t $(TARGET_DIR)/etc/weblcm-python/ssl -m 644 $(WEBLCM_PYTHON_SITE)/ssl/server.key
	$(INSTALL) -D -t $(TARGET_DIR)/etc/weblcm-python/ssl -m 644 $(WEBLCM_PYTHON_SITE)/ssl/server.crt
	$(INSTALL) -D -t $(TARGET_DIR)/etc/weblcm-python/ssl -m 644 $(WEBLCM_PYTHON_SITE)/ssl/ca.crt

	cat /dev/null > $(TARGET_DIR)/etc/weblcm-python/swcert.conf
	 ! grep -q 'CONFIG_SIGNED_IMAGES=y' ${BUILD_DIR}/swupdate*/include/config/auto.conf \
		|| echo 'SWCERT=-k $(WEBLCM_PYTHON_SET_KEY_LOCATION_VALUE) --cert-purpose codeSigning' > $(TARGET_DIR)/etc/weblcm-python/swcert.conf

	sed -i -e '/^default_/d' $(TARGET_DIR)/etc/weblcm-python/weblcm-python.ini
	sed -i -e '/\[weblcm\]/a default_password: \"$(WEBLCM_PYTHON_DEFAULT_PASSWORD)\"' $(TARGET_DIR)/etc/weblcm-python/weblcm-python.ini
	sed -i -e '/\[weblcm\]/a default_username: \"$(WEBLCM_PYTHON_DEFAULT_USERNAME)\"' $(TARGET_DIR)/etc/weblcm-python/weblcm-python.ini

	sed -i -e '/^managed_software_devices/d' $(TARGET_DIR)/etc/weblcm-python/weblcm-python.ini
	sed -i -e '/\[weblcm\]/a managed_software_devices: $(BR2_PACKAGE_WEBLCM_PYTHON_MANAGED_SOFTWARE_DEVICES)' $(TARGET_DIR)/etc/weblcm-python/weblcm-python.ini

	sed -i -e '/^unmanaged_hardware_devices/d' $(TARGET_DIR)/etc/weblcm-python/weblcm-python.ini
	sed -i -e '/\[weblcm\]/a unmanaged_hardware_devices: $(BR2_PACKAGE_WEBLCM_PYTHON_UNMANAGED_HARDWARE_DEVICES)' $(TARGET_DIR)/etc/weblcm-python/weblcm-python.ini

	sed -i -e '/^awm_cfg/d' $(TARGET_DIR)/etc/weblcm-python/weblcm-python.ini
	sed -i -e '/\[weblcm\]/a awm_cfg:$(BR2_PACKAGE_ADAPTIVE_WW_BINARIES_CFG_FILE)' $(TARGET_DIR)/etc/weblcm-python/weblcm-python.ini

	sed -i -e '/^enable_allow_unauthenticated_reboot_reset/d' $(TARGET_DIR)/etc/weblcm-python/weblcm-python.ini
	sed -i -e '/\[weblcm\]/a enable_allow_unauthenticated_reboot_reset:$(WEBLCM_PYTHON_ENABLE_UNAUTHENTICATED)' $(TARGET_DIR)/etc/weblcm-python/weblcm-python.ini

	sed -i -e '/^server.socket_host/d' $(TARGET_DIR)/etc/weblcm-python/weblcm-python.ini
	sed -i -e '/\[global\]/a server.socket_host: $(BR2_PACKAGE_WEBLCM_PYTHON_BIND_IP)' $(TARGET_DIR)/etc/weblcm-python/weblcm-python.ini
endef

WEBLCM_PYTHON_POST_INSTALL_TARGET_HOOKS += WEBLCM_PYTHON_POST_INSTALL_TARGET_HOOK_CMDS

define WEBLCM_PYTHON_INSTALL_INIT_SYSTEMD
	$(INSTALL) -d $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	$(INSTALL) -D -t $(TARGET_DIR)/usr/lib/systemd/system -m 644 $(WEBLCM_PYTHON_SITE)/weblcm-python.service
	ln -rsf $(TARGET_DIR)/usr/lib/systemd/system/weblcm-python.service $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/weblcm-python.service
	$(WEBLCM_PYTHON_FIX_TIME)

	$(INSTALL) -D -t $(TARGET_DIR)/usr/lib/systemd/system -m 644 $(WEBLCM_PYTHON_SITE)/swupdate.service
endef

$(eval $(python-package))
