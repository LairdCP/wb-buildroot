#####################################################################
# Laird Web Configuration Utility
#####################################################################

WEBLCM_PYTHON_VERSION = local
WEBLCM_PYTHON_SITE = package/lrd/externals/weblcm-python
WEBLCM_PYTHON_SITE_METHOD = local
WEBLCM_PYTHON_SETUP_TYPE = setuptools
WEBLCM_PYTHON_BUILD_OPTS = bdist_egg --exclude-source-files
WEBLCM_PYTHON_DEPENDENCIES = lrd-swupdate-client

TARGET_PYTHON_VERSION := $$(find $(TARGET_DIR)/usr/lib -maxdepth 1 -type d -name python* -printf "%f\n" | egrep -o '[0-9].[0-9]')
WEBLCM_PYTHON_SET_KEY_LOCATION_VALUE = $(call qstrip,$(BR2_PACKAGE_WEBLCM_PYTHON_SWUPDATE_KEY_LOCATION))
WEBLCM_PYTHON_DEFAULT_USERNAME = $(call qstrip,$(BR2_PACKAGE_WEBLCM_PYTHON_DEFAULT_USERNAME))
WEBLCM_PYTHON_DEFAULT_PASSWORD = $(call qstrip,$(BR2_PACKAGE_WEBLCM_PYTHON_DEFAULT_PASSWORD))

ifeq ($(BR2_PACKAGE_WEBLCM_BLUETOOTH_PYTHON),y)
	WEBLCM_PYTHON_EXTRA_MODULES += weblcm_bluetooth weblcm_ble weblcm_bluetooth_plugin
endif
ifeq ($(BR2_PACKAGE_WEBLCM_HID_PYTHON),y)
	WEBLCM_PYTHON_EXTRA_MODULES += weblcm_hid_barcode_scanner
endif
ifeq ($(BR2_PACKAGE_WEBLCM_VSP_PYTHON),y)
	WEBLCM_PYTHON_EXTRA_MODULES += weblcm_vsp_connection
endif
ifneq ($(BR2_PACKAGE_WEBLCM_HID_PYTHON)$(BR2_PACKAGE_WEBLCM_VSP_PYTHON),)
	WEBLCM_PYTHON_EXTRA_MODULES += weblcm_tcp_connection
endif
WEBLCM_PYTHON_ENV = WEBLCM_PYTHON_EXTRA_MODULES='$(WEBLCM_PYTHON_EXTRA_MODULES)'

ifeq ($(BR2_REPRODUCIBLE),y)
define WEBLCM_PYTHON_FIX_TIME
	sed -i -e 's/ExecStart=python/ExecStart=python --check-hash-based-pycs never/g' $(TARGET_DIR)/usr/lib/systemd/system/weblcm-python.service
endef
endif

define POST_INSTALL_TARGET_HOOKS
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

endef
WEBLCM_PYTHON_POST_INSTALL_TARGET_HOOKS += POST_INSTALL_TARGET_HOOKS

define WEBLCM_PYTHON_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/dist/weblcm_python-1.0-py$(TARGET_PYTHON_VERSION).egg $(TARGET_DIR)/usr/bin/weblcm-python

	$(INSTALL) -D -t $(TARGET_DIR)/var/www/assets/fonts -m 644 $(WEBLCM_PYTHON_SITE)/assets/fonts/*
	$(INSTALL) -D -t $(TARGET_DIR)/var/www/assets/css -m 644 $(WEBLCM_PYTHON_SITE)/assets/css/*.css
	$(INSTALL) -D -t $(TARGET_DIR)/var/www/assets/img -m 644 $(WEBLCM_PYTHON_SITE)/assets/img/*.png
	$(INSTALL) -D -t $(TARGET_DIR)/var/www/assets/js -m 644 $(WEBLCM_PYTHON_SITE)/assets/js/*.js
	$(INSTALL) -D -t $(TARGET_DIR)/var/www/assets/i18n -m 644 $(WEBLCM_PYTHON_SITE)/assets/i18n/*.json
	$(INSTALL) -D -t $(TARGET_DIR)/var/www -m 644 $(WEBLCM_PYTHON_SITE)/LICENSE

	cp -fr $(WEBLCM_PYTHON_SITE)/plugins $(TARGET_DIR)/var/www/

	$(INSTALL) -D -t $(TARGET_DIR)/etc/weblcm-python/scripts -m 755 $(WEBLCM_PYTHON_SITE)/*.sh
	$(INSTALL) -D -t $(TARGET_DIR)/etc/weblcm-python -m 644 $(WEBLCM_PYTHON_SITE)/*.ini
	$(INSTALL) -D -t $(TARGET_DIR)/etc/weblcm-python -m 644 $(WEBLCM_PYTHON_SITE)/zonelist.db
	$(INSTALL) -D -t $(TARGET_DIR)/etc/weblcm-python/ssl -m 644 $(WEBLCM_PYTHON_SITE)/ssl/server.key
	$(INSTALL) -D -t $(TARGET_DIR)/etc/weblcm-python/ssl -m 644 $(WEBLCM_PYTHON_SITE)/ssl/server.crt
	$(INSTALL) -D -t $(TARGET_DIR)/etc/weblcm-python/ssl -m 644 $(WEBLCM_PYTHON_SITE)/ssl/ca.crt
endef

define WEBLCM_PYTHON_INSTALL_INIT_SYSTEMD
	$(INSTALL) -d $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	$(INSTALL) -D -t $(TARGET_DIR)/usr/lib/systemd/system -m 644 $(WEBLCM_PYTHON_SITE)/weblcm-python.service
	ln -rsf $(TARGET_DIR)/usr/lib/systemd/system/weblcm-python.service $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/weblcm-python.service
	$(WEBLCM_PYTHON_FIX_TIME)

	$(INSTALL) -D -t $(TARGET_DIR)/usr/lib/systemd/system -m 644 $(WEBLCM_PYTHON_SITE)/swupdate.service
endef

$(eval $(python-package))
