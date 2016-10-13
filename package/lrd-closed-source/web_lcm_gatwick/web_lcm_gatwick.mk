WEB_LCM_GATWICK_VERSION = local
WEB_LCM_GATWICK_SITE = package/lrd-closed-source/externals/web_lcm_gatwick
WEB_LCM_GATWICK_SITE_METHOD = local
WEB_LCM_GATWICK_DEPENDENCIES = host-angular-cli host-composer php_sdk

define WEB_LCM_GATWICK_BUILD_CMDS
	cd $(@D); $(HOST_DIR)/usr/bin/composer install --no-dev --optimize-autoloader --ignore-platform-reqs

	cd $(@D); \
		PATH=$(BR_PATH) \
		$(HOST_NPM) install $(@D)

	cd $(@D); \
		PATH=$(BR_PATH) \
		$(HOST_DIR)/usr/bin/ng build
endef

define WEB_LCM_GATWICK_INSTALL_TARGET_CMDS
	mkdir -p -m 0775 $(TARGET_DIR)/var/www/http/
	cp -rf $(@D)/api $(TARGET_DIR)/var/www/
	cp -rf $(@D)/dist/* $(TARGET_DIR)/var/www/http/

	mv $(TARGET_DIR)/var/www/api/api.php $(TARGET_DIR)/var/www/http/
	cp $(TARGET_DIR)/var/www/docs/lrd_php_sdk.php $(TARGET_DIR)/var/www/api/app/plugins/wifi/classes/

	$(INSTALL) -D -m 0755 $(@D)/lighttpd.conf \
				$(@D)/lighttpd.password \
				$(TARGET_DIR)/etc/lighttpd
endef

$(eval $(generic-package))
