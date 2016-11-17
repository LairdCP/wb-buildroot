################################################################################
#
# host-composer
#
################################################################################

HOST_COMPOSER_VERSION = 1.2.2
HOST_COMPOSER_SITE = https://getcomposer.org/download/$(HOST_COMPOSER_VERSION)
HOST_COMPOSER_SOURCE = composer.phar
HOST_COMPOSER_DEPENDENCIES = host-php

define HOST_COMPOSER_EXTRACT_CMDS
	mv $(DL_DIR)/$(HOST_COMPOSER_SOURCE) $(@D)
endef

define HOST_COMPOSER_INSTALL_CMDS
	$(INSTALL) $(@D)/composer.phar $(HOST_DIR)/usr/bin/composer
endef


# Composer uses its own download script to install
$(eval $(host-generic-package))
