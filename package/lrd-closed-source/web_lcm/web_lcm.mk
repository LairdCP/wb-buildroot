WEB_LCM_VERSION = local
WEB_LCM_SITE = package/lrd-closed-source/externals/web_lcm
WEB_LCM_SITE_METHOD = local

define WEB_LCM_INSTALL_TARGET_CMDS
	mkdir -p -m 0775 $(TARGET_DIR)/var/www/docs/assets/css
	mkdir -p -m 0775 $(TARGET_DIR)/var/www/docs/assets/img
	mkdir -p -m 0775 $(TARGET_DIR)/var/www/docs/assets/js
	mkdir -p -m 0775 $(TARGET_DIR)/etc/lighttpd
	$(INSTALL) -D -m 0755 $(@D)/advancedconfig.html \
				$(@D)/about.html \
				$(@D)/globalconfig.html \
				$(@D)/ifaceconfig.html \
				$(@D)/profileconfig.html \
				$(@D)/status.html \
				$(@D)/status_update.php \
				$(@D)/title_update.php \
				$(@D)/remote_update.php \
		 $(TARGET_DIR)/var/www/docs
	$(INSTALL) -D -m 0775 $(@D)/assets/css/bootstrap-responsive.min.css $(TARGET_DIR)/var/www/docs/assets/css
	$(INSTALL) -D -m 0755 $(@D)/assets/css/bootstrap.min.css $(TARGET_DIR)/var/www/docs/assets/css
	$(INSTALL) -D -m 0755 $(@D)/assets/img/logo.png $(TARGET_DIR)/var/www/docs/assets/img
	$(INSTALL) -D -m 0755 $(@D)/assets/js/bootstrap.min.js \
							$(@D)/assets/js/jquery.min.js \
			$(TARGET_DIR)/var/www/docs/assets/js
	$(INSTALL) -D -m 0755 $(@D)/lighttpd.conf \
				$(@D)/lighttpd.password \
		$(TARGET_DIR)/etc/lighttpd
endef

$(eval $(generic-package))
