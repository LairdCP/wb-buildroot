#####################################################################
# Laird Industrial Gateway ggsupport
#####################################################################

GGSUPPORT_VERSION = local
GGSUPPORT_SITE = package/lrd/externals/ig/ggsupport
GGSUPPORT_SITE_METHOD = local

define GGSUPPORT_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/setdate_http $(TARGET_DIR)/usr/bin/setdate_http
	$(INSTALL) -D -m 755 $(@D)/ggstart $(TARGET_DIR)/usr/bin/ggstart
	$(INSTALL) -D -m 755 $(@D)/ggrunner $(TARGET_DIR)/usr/bin/ggrunner
	$(INSTALL) -D -m 755 package/lrd/ig/ggsupport/S41ggrunner $(TARGET_DIR)/etc/init.d/S41ggrunner
endef

define GGSUPPORT_USERS
	ggc_user 201 ggc_group 201 * - - -
endef

$(eval $(generic-package))
