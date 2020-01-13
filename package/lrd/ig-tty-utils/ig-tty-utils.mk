##########################################################################
# Sentrius IG60 TTY Utils
##########################################################################

IG_TTY_UTILS_DEPENDENCIES = systemd

define IG_TTY_UTILS_INSTALL_TARGET_FILES
	$(INSTALL) -D -m 644 $(IG_TTY_UTILS_PKGDIR)/ig-card-detect.service $(TARGET_DIR)/usr/lib/systemd/system
	$(INSTALL) -D -m 644 $(IG_TTY_UTILS_PKGDIR)/ttyS2-startup.conf $(TARGET_DIR)/etc/systemd/system/serial-getty@ttyS2.service.d/ttyS2-startup.conf
	ln -srf $(TARGET_DIR)/usr/lib/systemd/system/ig-card-detect.service $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	ln -srf $(TARGET_DIR)/usr/lib/systemd/system/serial-getty@.service $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/serial-getty@ttyS2.service
	ln -srf $(TARGET_DIR)/usr/lib/systemd/system/serial-getty@.service $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/serial-getty@ttyUSB0.service
endef

IG_TTY_UTILS_POST_INSTALL_TARGET_HOOKS += IG_TTY_UTILS_INSTALL_TARGET_FILES

$(eval $(generic-package))

