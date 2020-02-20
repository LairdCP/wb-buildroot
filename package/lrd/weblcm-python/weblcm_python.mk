#####################################################################
# Laird Web Configuration Utility
#####################################################################

WEBLCM_PYTHON_VERSION = local
WEBLCM_PYTHON_SITE = package/lrd/externals/weblcm-python
WEBLCM_PYTHON_SITE_METHOD = local
WEBLCM_PYTHON_SETUP_TYPE = setuptools
WEBLCM_PYTHON_BUILD_OPTS = bdist_egg --exclude-source-files
WEBLCM_PYTHON_DEPENDENCIES = lrd-swupdate-client

WEBLCM_PYTHON_POST_INSTALL_TARGET_HOOKS += WEBLCM_PYTHON_INSTALL_TARGET_FILES

TARGET_PYTHON_VERSION := $$(find $(TARGET_DIR)/usr/lib -maxdepth 1 -type d -name python* -printf "%f\n" | egrep -o '[0-9].[0-9]')

ifeq ($(BR2_REPRODUCIBLE),y)
define WEBLCM_PYTHON_FIX_TIME
	sed -i -e 's/ExecStart=python/ExecStart=python --check-hash-based-pycs never/g' $(TARGET_DIR)/usr/lib/systemd/system/weblcm-python.service
endef
endif

define WEBLCM_PYTHON_INSTALL_TARGET_FILES
	$(INSTALL) -D -m 755 $(@D)/dist/weblcm_python-1.0-py$(TARGET_PYTHON_VERSION).egg $(TARGET_DIR)/usr/bin/weblcm-python

	$(INSTALL) -D -t $(TARGET_DIR)/var/www -m 644 $(WEBLCM_PYTHON_SITE)/*.html
	$(INSTALL) -D -t $(TARGET_DIR)/var/www/html -m 644 $(WEBLCM_PYTHON_SITE)/html/*
	$(INSTALL) -D -t $(TARGET_DIR)/var/www/assets/fonts -m 644 $(WEBLCM_PYTHON_SITE)/assets/fonts/*
	$(INSTALL) -D -t $(TARGET_DIR)/var/www/assets/css -m 644 $(WEBLCM_PYTHON_SITE)/assets/css/*.css
	$(INSTALL) -D -t $(TARGET_DIR)/var/www/assets/img -m 644 $(WEBLCM_PYTHON_SITE)/assets/img/*.png
	$(INSTALL) -D -t $(TARGET_DIR)/var/www/assets/js -m 644 $(WEBLCM_PYTHON_SITE)/assets/js/*.js
	$(INSTALL) -D -t $(TARGET_DIR)/var/www -m 644 $(WEBLCM_PYTHON_SITE)/LICENSE

	cp -fr $(WEBLCM_PYTHON_SITE)/plugins $(TARGET_DIR)/var/www/

	$(INSTALL) -d $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	$(INSTALL) -m 644 $(WEBLCM_PYTHON_SITE)/weblcm-python.service $(TARGET_DIR)/usr/lib/systemd/system/
	ln -rsf $(TARGET_DIR)/usr/lib/systemd/system/weblcm-python.service $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/weblcm-python.service
	$(WEBLCM_PYTHON_FIX_TIME)

	$(INSTALL) -m 644 $(WEBLCM_PYTHON_SITE)/swupdate.service $(TARGET_DIR)/usr/lib/systemd/system/
	ln -rsf $(TARGET_DIR)/usr/lib/systemd/system/swupdate.service $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/swupdate.service
	$(INSTALL) -D -m 755 $(WEBLCM_PYTHON_SITE)/swupdate.sh  $(TARGET_DIR)/usr/sbin/swupdate.sh

	mkdir -p $(TARGET_DIR)/etc/weblcm-python/ssl
	$(INSTALL) -m 644 $(WEBLCM_PYTHON_SITE)/*.ini $(TARGET_DIR)/etc/weblcm-python/
	$(INSTALL) -m 644 $(WEBLCM_PYTHON_SITE)/ssl/server.key $(TARGET_DIR)/etc/weblcm-python/ssl/
	$(INSTALL) -m 644 $(WEBLCM_PYTHON_SITE)/ssl/server.crt $(TARGET_DIR)/etc/weblcm-python/ssl/
endef

$(eval $(python-package))
