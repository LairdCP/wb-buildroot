#####################################################################
# Laird Web Configuration Utility
#####################################################################

WEBLCM_PYTHON_SET_KEY_LOCATION_VALUE = $(call qstrip,$(BR2_PACKAGE_WEBLCM_PYTHON_SWUPDATE_KEY_LOCATION))
WEBLCM_PYTHON_VERSION = local
WEBLCM_PYTHON_SITE = package/lrd/externals/weblcm-python
WEBLCM_PYTHON_SITE_METHOD = local
WEBLCM_PYTHON_SETUP_TYPE = setuptools
WEBLCM_PYTHON_BUILD_OPTS = bdist_egg --exclude-source-files
WEBLCM_PYTHON_DEPENDENCIES = lrd-swupdate-client

TARGET_PYTHON_VERSION := $$(find $(TARGET_DIR)/usr/lib -maxdepth 1 -type d -name python* -printf "%f\n" | egrep -o '[0-9].[0-9]')

ifeq ($(BR2_REPRODUCIBLE),y)
define WEBLCM_PYTHON_FIX_TIME
	sed -i -e 's/ExecStart=python/ExecStart=python --check-hash-based-pycs never/g' $(TARGET_DIR)/usr/lib/systemd/system/weblcm-python.service
endef
endif

define WEBLCM_PYTHON_SET_KEY_LOCATION
	 ! grep -q 'CONFIG_SIGNED_IMAGES=y' ${BUILD_DIR}/swupdate*/include/config/auto.conf \
		|| sed -i -e 's=swupdate=swupdate -k $(WEBLCM_PYTHON_SET_KEY_LOCATION_VALUE)=g' $(TARGET_DIR)/usr/sbin/swupdate.sh
endef

define WEBLCM_PYTHON_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/dist/weblcm_python-1.0-py$(TARGET_PYTHON_VERSION).egg $(TARGET_DIR)/usr/bin/weblcm-python

	$(INSTALL) -D -t $(TARGET_DIR)/var/www -m 644 $(WEBLCM_PYTHON_SITE)/*.html
	$(INSTALL) -D -t $(TARGET_DIR)/var/www/html -m 644 $(WEBLCM_PYTHON_SITE)/html/*
	$(INSTALL) -D -t $(TARGET_DIR)/var/www/assets/fonts -m 644 $(WEBLCM_PYTHON_SITE)/assets/fonts/*
	$(INSTALL) -D -t $(TARGET_DIR)/var/www/assets/css -m 644 $(WEBLCM_PYTHON_SITE)/assets/css/*.css
	$(INSTALL) -D -t $(TARGET_DIR)/var/www/assets/img -m 644 $(WEBLCM_PYTHON_SITE)/assets/img/*.png
	$(INSTALL) -D -t $(TARGET_DIR)/var/www/assets/js -m 644 $(WEBLCM_PYTHON_SITE)/assets/js/*.js
	$(INSTALL) -D -t $(TARGET_DIR)/var/www/assets/i18n -m 644 $(WEBLCM_PYTHON_SITE)/assets/i18n/*.json
	$(INSTALL) -D -t $(TARGET_DIR)/var/www -m 644 $(WEBLCM_PYTHON_SITE)/LICENSE

	cp -fr $(WEBLCM_PYTHON_SITE)/plugins $(TARGET_DIR)/var/www/

	$(INSTALL) -D -t $(TARGET_DIR)/usr/sbin -m 755 $(WEBLCM_PYTHON_SITE)/swupdate.sh
	$(WEBLCM_PYTHON_SET_KEY_LOCATION)
	$(INSTALL) -D -t $(TARGET_DIR)/usr/sbin -m 755 $(WEBLCM_PYTHON_SITE)/weblcm_file_import_export.sh
	$(INSTALL) -D -t $(TARGET_DIR)/usr/sbin -m 755 $(WEBLCM_PYTHON_SITE)/weblcm_update_checking.sh
	$(INSTALL) -D -t $(TARGET_DIR)/etc/weblcm-python -m 644 $(WEBLCM_PYTHON_SITE)/*.ini
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
	ln -rsf $(TARGET_DIR)/usr/lib/systemd/system/swupdate.service $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/swupdate.service
endef

$(eval $(python-package))
