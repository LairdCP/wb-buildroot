#####################################################################
# Laird Web Configuration Utility
#####################################################################

WEBLCM_PYTHON_VERSION = local
WEBLCM_PYTHON_SITE = package/lrd/externals/weblcm-python
WEBLCM_PYTHON_SITE_METHOD = local
WEBLCM_PYTHON_SETUP_TYPE = setuptools
WEBLCM_PYTHON_DEPENDENCIES = openssl

ifeq ($(BR2_PACKAGE_HOST_PYTHON_CYTHON),y)
WEBLCM_PYTHON_DEPENDENCIES += host-python-cython
endif

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
ifeq ($(BR2_PACKAGE_WEBLCM_ENABLE_STUNNEL_CONTROL),y)
	WEBLCM_PYTHON_EXTRA_PACKAGES += weblcm/stunnel
endif
ifeq ($(BR2_PACKAGE_WEBLCM_PYTHON_IPTABLES_FIREWALL),y)
	WEBLCM_PYTHON_EXTRA_PACKAGES += weblcm/iptables
endif

WEBLCM_PYTHON_ENV = WEBLCM_PYTHON_EXTRA_PACKAGES='$(WEBLCM_PYTHON_EXTRA_PACKAGES)'

ifeq ($(BR2_REPRODUCIBLE),y)
define WEBLCM_PYTHON_FIX_TIME
	$(SED) 's/ExecStart=python/ExecStart=python --check-hash-based-pycs never/g' $(TARGET_DIR)/usr/lib/systemd/system/weblcm-python.service
endef
endif

define WEBLCM_PYTHON_POST_INSTALL_TARGET_HOOK_CMDS
	$(INSTALL) -d $(TARGET_DIR)/etc/weblcm-python

	$(INSTALL) -D -t $(TARGET_DIR)/var/www/assets/fonts -m 644 $(@D)/assets/fonts/*
	$(INSTALL) -D -t $(TARGET_DIR)/var/www/assets/css -m 644 $(@D)/assets/css/*.css
	$(INSTALL) -D -t $(TARGET_DIR)/var/www/assets/img -m 644 $(@D)/assets/img/*.png
	$(INSTALL) -D -t $(TARGET_DIR)/var/www/assets/js -m 644 $(@D)/assets/js/*.js
	$(INSTALL) -D -t $(TARGET_DIR)/var/www/assets/i18n -m 644 $(@D)/assets/i18n/*.json
	$(INSTALL) -D -t $(TARGET_DIR)/var/www -m 644 $(@D)/LICENSE

	cp -fr $(@D)/plugins $(TARGET_DIR)/var/www/

	$(INSTALL) -D -t $(TARGET_DIR)/usr/bin/weblcm-python.scripts -m 755 $(@D)/*.sh
	$(INSTALL) -D -t $(TARGET_DIR)/etc -m 644 $(@D)/weblcm-python.ini

	$(SED) '/^default_/d' $(TARGET_DIR)/etc/weblcm-python.ini
	$(SED) '/\[weblcm\]/a default_password: \"$(WEBLCM_PYTHON_DEFAULT_PASSWORD)\"' $(TARGET_DIR)/etc/weblcm-python.ini
	$(SED) '/\[weblcm\]/a default_username: \"$(WEBLCM_PYTHON_DEFAULT_USERNAME)\"' $(TARGET_DIR)/etc/weblcm-python.ini

	$(SED) '/^managed_software_devices/d' $(TARGET_DIR)/etc/weblcm-python.ini
	$(SED) '/\[weblcm\]/a managed_software_devices: $(BR2_PACKAGE_WEBLCM_PYTHON_MANAGED_SOFTWARE_DEVICES)' $(TARGET_DIR)/etc/weblcm-python.ini

	$(SED) '/^unmanaged_hardware_devices/d' $(TARGET_DIR)/etc/weblcm-python.ini
	$(SED) '/\[weblcm\]/a unmanaged_hardware_devices: $(BR2_PACKAGE_WEBLCM_PYTHON_UNMANAGED_HARDWARE_DEVICES)' $(TARGET_DIR)/etc/weblcm-python.ini

	$(SED) '/^awm_cfg/d' $(TARGET_DIR)/etc/weblcm-python.ini
	$(SED) '/\[weblcm\]/a awm_cfg:$(BR2_PACKAGE_ADAPTIVE_WW_BINARIES_CFG_FILE)' $(TARGET_DIR)/etc/weblcm-python.ini
	$(SED) '/^enable_allow_unauthenticated_reboot_reset/d' $(TARGET_DIR)/etc/weblcm-python.ini
	$(SED) '/\[weblcm\]/a enable_allow_unauthenticated_reboot_reset: \
		$(if $(findstring y,$(BR2_PACKAGE_WEBLCM_PYTHON_UNAUTHENTICATED)),True,False)' $(TARGET_DIR)/etc/weblcm-python.ini

	$(SED) '/^server.socket_host/d' $(TARGET_DIR)/etc/weblcm-python.ini
	$(SED) '/\[global\]/a server.socket_host: $(BR2_PACKAGE_WEBLCM_PYTHON_BIND_IP)' $(TARGET_DIR)/etc/weblcm-python.ini

	$(SED) '/^allow_multiple_user_sessions/d' $(TARGET_DIR)/etc/weblcm-python.ini
	$(SED) '/\[weblcm\]/a allow_multiple_user_sessions: \
		$(if $(findstring y,$(BR2_PACKAGE_WEBLCM_ALLOW_MUTLIPLE_USER_SESSIONS)),True,False)' $(TARGET_DIR)/etc/weblcm-python.ini

	$(SED) 's,^tools.sessions.on:.*,tools.sessions.on: \
		$(if $(findstring y,$(BR2_PACKAGE_WEBLCM_ENABLE_SESSIONS)),True,False),' $(TARGET_DIR)/etc/weblcm-python.ini

	$(SED) '/^enable_client_auth/d' $(TARGET_DIR)/etc/weblcm-python.ini
	$(SED) '/\[weblcm\]/a enable_client_auth: \
		$(if $(findstring y,$(BR2_PACKAGE_WEBLCM_ENABLE_CLIENT_AUTHENTICATION)),True,False)' $(TARGET_DIR)/etc/weblcm-python.ini
endef

ifeq ($(BR2_PACKAGE_LRD_ENCRYPTED_STORAGE_TOOLKIT),y)
define WEBLCM_PYTHON_POST_INSTALL_TARGET_HOOK_CMDS2
	$(SED) 's,^server.ssl_certificate:.*,server.ssl_certificate: \"/rodata/secret/weblcm-python/ssl/server.crt\",' $(TARGET_DIR)/etc/weblcm-python.ini
	$(SED) 's,^server.ssl_private_key:.*,server.ssl_private_key: \"/rodata/secret/weblcm-python/ssl/server.key\",' $(TARGET_DIR)/etc/weblcm-python.ini
	$(SED) 's,^server.ssl_certificate_chain:.*,server.ssl_certificate_chain: \"/rodata/secret/weblcm-python/ssl/ca.crt\",' $(TARGET_DIR)/etc/weblcm-python.ini
endef
else
define WEBLCM_PYTHON_POST_INSTALL_TARGET_HOOK_CMDS2
	$(INSTALL) -D -t $(TARGET_DIR)/etc/weblcm-python/ssl -m 644 \
		$(@D)/ssl/server.key $(@D)/ssl/server.crt $(@D)/ssl/ca.crt
endef
endif

WEBLCM_PYTHON_POST_INSTALL_TARGET_HOOKS += WEBLCM_PYTHON_POST_INSTALL_TARGET_HOOK_CMDS WEBLCM_PYTHON_POST_INSTALL_TARGET_HOOK_CMDS2

define WEBLCM_PYTHON_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -t $(TARGET_DIR)/usr/lib/systemd/system -m 644 $(@D)/weblcm-python.service
	$(WEBLCM_PYTHON_FIX_TIME)
endef

$(eval $(python-package))
