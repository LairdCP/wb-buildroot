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

define WEBLCM_PYTHON_INSTALL_TARGET_FILES
	$(INSTALL) -D -m 755 $(@D)/dist/weblcm_python-1.0-py$(TARGET_PYTHON_VERSION).egg $(TARGET_DIR)/usr/bin/weblcm-python
	mkdir -p -m 0775 $(TARGET_DIR)/etc/weblcm-python
	mkdir -p -m 0775 $(TARGET_DIR)/var/www/
	mkdir -p -m 0775 $(TARGET_DIR)/var/www/assets/css
	mkdir -p -m 0775 $(TARGET_DIR)/var/www/assets/img
	mkdir -p -m 0775 $(TARGET_DIR)/var/www/assets/js
	mkdir -p -m 0775 $(TARGET_DIR)/var/www/assets/fonts
	mkdir -p -m 0775 $(TARGET_DIR)/var/www/html
	mkdir -p -m 0775 $(TARGET_DIR)/var/www/plugins/
	$(INSTALL) -D -m 644 $(WEBLCM_PYTHON_SITE)/*.ini $(TARGET_DIR)/etc/weblcm-python/
	$(INSTALL) -D -m 755 $(WEBLCM_PYTHON_SITE)/html/* $(TARGET_DIR)/var/www/html/
	$(INSTALL) -D -m 755 $(WEBLCM_PYTHON_SITE)/assets/fonts/* $(TARGET_DIR)/var/www/assets/fonts/
	$(INSTALL) -D -m 644 $(WEBLCM_PYTHON_SITE)/assets/css/*.css $(TARGET_DIR)/var/www/assets/css/
	$(INSTALL) -D -m 644 $(WEBLCM_PYTHON_SITE)/assets/img/*.png $(TARGET_DIR)/var/www/assets/img/
	$(INSTALL) -D -m 644 $(WEBLCM_PYTHON_SITE)/assets/js/*.js $(TARGET_DIR)/var/www/assets/js/
	$(INSTALL) -D -m 644 $(WEBLCM_PYTHON_SITE)/*.html $(TARGET_DIR)/var/www/
	$(INSTALL) -D -m 644 $(WEBLCM_PYTHON_SITE)/LICENSE $(TARGET_DIR)/var/www/
	cp -r $(WEBLCM_PYTHON_SITE)/plugins/* $(TARGET_DIR)/var/www/plugins/

	$(INSTALL) -D -m 644 $(WEBLCM_PYTHON_SITE)/weblcm-python.service $(TARGET_DIR)/etc/systemd/system
	mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	ln -sf $(TARGET_DIR)/etc/systemd/system/weblcm-python.service $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants

endef

$(eval $(python-package))
