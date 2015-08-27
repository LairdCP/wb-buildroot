#############################################################
#
# Laird smartBASIC apps for the WB
#
#############################################################

WB_SMARTBASIC_APPS_VERSION = local
WB_SMARTBASIC_APPS_SITE = package/lrd/externals/wb_smartBASIC_apps
WB_SMARTBASIC_APPS_SITE_METHOD = local

define WB_SMARTBASIC_APPS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/'$$autorun$$.SPPBridge.Socket.wb.sb' $(TARGET_DIR)/etc/summit/'$$autorun$$.SPPBridge.Socket.wb.sb'
	mkdir -p $(TARGET_DIR)/home/summit/lib
	$(INSTALL) -D -m 755 $(@D)/lib/advert.report.manager.sblib $(TARGET_DIR)/etc/summit/lib/advert.report.manager.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/ble.sblib $(TARGET_DIR)/etc/summit/lib/ble.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/cli.blood.pressure.custom.sblib $(TARGET_DIR)/etc/summit/lib/cli.blood.pressure.custom.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/cli.findme.custom.sblib $(TARGET_DIR)/etc/summit/lib/cli.findme.custom.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/cli.health.thermometer.custom.sblib $(TARGET_DIR)/etc/summit/lib/cli.health.thermometer.custom.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/cli.heart.rate.custom.sblib $(TARGET_DIR)/etc/summit/lib/cli.heart.rate.custom.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/cli.proximity.custom.sblib $(TARGET_DIR)/etc/summit/lib/cli.proximity.custom.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/cmd.btc.manager.sblib $(TARGET_DIR)/etc/summit/lib/cmd.btc.manager.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/connection.manager.sblib $(TARGET_DIR)/etc/summit/lib/connection.manager.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/custom.battery.service.sblib $(TARGET_DIR)/etc/summit/lib/custom.battery.service.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/custom.blood.pressure.service.sblib $(TARGET_DIR)/etc/summit/lib/custom.blood.pressure.service.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/custom.health.thermometer.service.sblib $(TARGET_DIR)/etc/summit/lib/custom.health.thermometer.service.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/custom.heart.rate.service.sblib $(TARGET_DIR)/etc/summit/lib/custom.heart.rate.service.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/custom.immediate.alert.service.sblib $(TARGET_DIR)/etc/summit/lib/custom.immediate.alert.service.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/custom.link.loss.service.sblib $(TARGET_DIR)/etc/summit/lib/custom.link.loss.service.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/custom.tx.power.service.sblib $(TARGET_DIR)/etc/summit/lib/custom.tx.power.service.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/debugging.routines.sblib $(TARGET_DIR)/etc/summit/lib/debugging.routines.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/device.information.service.sblib $(TARGET_DIR)/etc/summit/lib/device.information.service.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/fast.slow.advert.mngr.sblib $(TARGET_DIR)/etc/summit/lib/fast.slow.advert.mngr.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/gap.service.sblib $(TARGET_DIR)/etc/summit/lib/gap.service.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/iBeacon.sblib $(TARGET_DIR)/etc/summit/lib/iBeacon.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/security.manager.sblib $(TARGET_DIR)/etc/summit/lib/security.manager.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/smartZ.gatttool.sblib $(TARGET_DIR)/etc/summit/lib/smartZ.gatttool.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/smartZ.hciconfig.sblib $(TARGET_DIR)/etc/summit/lib/smartZ.hciconfig.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/smartZ.hcitool.sblib $(TARGET_DIR)/etc/summit/lib/smartZ.hcitool.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/smartZ.rfcomm.sblib $(TARGET_DIR)/etc/summit/lib/smartZ.rfcomm.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/standard.advert.mngr.sblib $(TARGET_DIR)/etc/summit/lib/standard.advert.mngr.sblib
	$(INSTALL) -D -m 755 $(@D)/'$$autorun$$.iBeacon.sb' $(TARGET_DIR)/etc/summit/'$$autorun$$.iBeacon.sb'
	$(INSTALL) -D -m 755 $(@D)/bps.blood.pressure.custom.sb $(TARGET_DIR)/etc/summit/bps.blood.pressure.custom.sb
	$(INSTALL) -D -m 755 $(@D)/cmd.manager.sb $(TARGET_DIR)/etc/summit/cmd.manager.sb
	$(INSTALL) -D -m 755 $(@D)/fms.find.me.custom.sb $(TARGET_DIR)/etc/summit/fms.find.me.custom.sb
	$(INSTALL) -D -m 755 $(@D)/hrs.heart.rate.custom.sb $(TARGET_DIR)/etc/summit/hrs.heart.rate.custom.sb
	$(INSTALL) -D -m 755 $(@D)/hts.health.thermometer.custom.sb $(TARGET_DIR)/etc/summit/hts.health.thermometer.custom.sb
	$(INSTALL) -D -m 755 $(@D)/hw.hello.world.sb $(TARGET_DIR)/etc/summit/hw.hello.world.sb
	$(INSTALL) -D -m 755 $(@D)/prx.proximity.custom.sb $(TARGET_DIR)/etc/summit/prx.proximity.custom.sb
	$(INSTALL) -D -m 755 $(@D)/smartZ.sb $(TARGET_DIR)/etc/summit/smartZ.sb
endef

define WB_SMARTBASIC_APPS_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/etc/summit/'$$autorun$$.SPPBridge.Socket.wb.sb'
	rm -f $(TARGET_DIR)/etc/summit/lib/advert.report.manager.sblib
	rm -f $(TARGET_DIR)/etc/summit/lib/ble.sblib
	rm -f $(TARGET_DIR)/etc/summit/lib/cli.blood.pressure.custom.sblib
	rm -f $(TARGET_DIR)/etc/summit/lib/cli.findme.custom.sblib
	rm -f $(TARGET_DIR)/etc/summit/lib/cli.health.thermometer.custom.sblib
	rm -f $(TARGET_DIR)/etc/summit/lib/cli.heart.rate.custom.sblib
	rm -f $(TARGET_DIR)/etc/summit/lib/cli.proximity.custom.sblib
	rm -f $(TARGET_DIR)/etc/summit/lib/cmd.btc.manager.sblib
	rm -f $(TARGET_DIR)/etc/summit/lib/connection.manager.sblib
	rm -f $(TARGET_DIR)/etc/summit/lib/custom.battery.service.sblib
	rm -f $(TARGET_DIR)/etc/summit/lib/custom.blood.pressure.service.sblib
	rm -f $(TARGET_DIR)/etc/summit/lib/custom.health.thermometer.service.sblib
	rm -f $(TARGET_DIR)/etc/summit/lib/custom.heart.rate.service.sblib
	rm -f $(TARGET_DIR)/etc/summit/lib/custom.immediate.alert.service.sblib
	rm -f $(TARGET_DIR)/etc/summit/lib/custom.link.loss.service.sblib
	rm -f $(TARGET_DIR)/etc/summit/lib/custom.tx.power.service.sblib
	rm -f $(TARGET_DIR)/etc/summit/lib/debugging.routines.sblib
	rm -f $(TARGET_DIR)/etc/summit/lib/device.information.service.sblib
	rm -f $(TARGET_DIR)/etc/summit/lib/fast.slow.advert.mngr.sblib
	rm -f $(TARGET_DIR)/etc/summit/lib/gap.service.sblib
	rm -f $(TARGET_DIR)/etc/summit/lib/iBeacon.sblib
	rm -f $(TARGET_DIR)/etc/summit/lib/security.manager.sblib
	rm -f $(TARGET_DIR)/etc/summit/lib/smartZ.gatttool.sblib
	rm -f $(TARGET_DIR)/etc/summit/lib/smartZ.hciconfig.sblib
	rm -f $(TARGET_DIR)/etc/summit/lib/smartZ.hcitool.sblib
	rm -f $(TARGET_DIR)/etc/summit/lib/smartZ.rfcomm.sblib
	rm -f $(TARGET_DIR)/etc/summit/lib/standard.advert.mngr.sblib
	rm -f $(TARGET_DIR)/etc/summit/'$$autorun$$.iBeacon.sb'
	rm -f $(TARGET_DIR)/etc/summit/bps.blood.pressure.custom.sb
	rm -f $(TARGET_DIR)/etc/summit/cmd.manager.sb
	rm -f $(TARGET_DIR)/etc/summit/fms.find.me.custom.sb
	rm -f $(TARGET_DIR)/etc/summit/hrs.heart.rate.custom.sb
	rm -f $(TARGET_DIR)/etc/summit/hts.health.thermometer.custom.sb
	rm -f $(TARGET_DIR)/etc/summit/hw.hello.world.sb
	rm -f $(TARGET_DIR)/etc/summit/prx.proximity.custom.sb
	rm -f $(TARGET_DIR)/etc/summit/smartZ.sb
	rm -f $(TARGET_DIR)/etc/summit/lib
endef

$(eval $(generic-package))
