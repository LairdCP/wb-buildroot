WEB_LCM_VERSION = local
WEB_LCM_SITE = package/lrd-closed-source/externals/web_lcm
WEB_LCM_SITE_METHOD = local

define WEB_LCM_INSTALL_TARGET_CMDS
	mkdir -p -m 0775 $(TARGET_DIR)/var/www/docs/assets/css
	mkdir -p -m 0775 $(TARGET_DIR)/var/www/docs/assets/img
	mkdir -p -m 0775 $(TARGET_DIR)/var/www/docs/assets/js
	mkdir -p -m 0775 $(TARGET_DIR)/var/www/docs/assets/fonts
	mkdir -p -m 0775 $(TARGET_DIR)/var/www/docs/html
	mkdir -p -m 0775 $(TARGET_DIR)/var/www/docs/php
	mkdir -p -m 0775 $(TARGET_DIR)/var/www/docs/plugins
	mkdir -p -m 0775 $(TARGET_DIR)/etc/lighttpd
	cp -r $(@D)/php/* $(TARGET_DIR)/var/www/docs/php
	cp -r $(@D)/plugins/* $(TARGET_DIR)/var/www/docs/plugins
	cp -r $(@D)/html/* $(TARGET_DIR)/var/www/docs/html
	$(INSTALL) -D -m 0755 $(@D)/webLCM.* $(TARGET_DIR)/var/www/docs/
	$(INSTALL) -D -m 0775 $(@D)/assets/css/*.css $(TARGET_DIR)/var/www/docs/assets/css
	$(INSTALL) -D -m 0755 $(@D)/assets/img/*.png $(TARGET_DIR)/var/www/docs/assets/img
	$(INSTALL) -D -m 0755 $(@D)/assets/js/*.js $(TARGET_DIR)/var/www/docs/assets/js
	$(INSTALL) -D -m 0755 $(@D)/assets/fonts/* $(TARGET_DIR)/var/www/docs/assets/fonts
	$(INSTALL) -D -m 0755 $(@D)/lighttpd.conf $(@D)/lighttpd.password \
		$(TARGET_DIR)/etc/lighttpd
endef

$(eval $(generic-package))
