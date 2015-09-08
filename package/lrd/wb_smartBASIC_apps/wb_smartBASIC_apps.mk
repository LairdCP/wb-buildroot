#############################################################
#
# Laird smartBASIC apps for the WB
#
#############################################################

WB_SMARTBASIC_APPS_VERSION = local
WB_SMARTBASIC_APPS_SITE = package/lrd/externals/wb_smartBASIC_apps
WB_SMARTBASIC_APPS_SITE_METHOD = local
SB_APPS_DIR = $(TARGET_DIR)/usr/share/smartBASIC/apps

define WB_SMARTBASIC_APPS_INSTALL_TARGET_CMDS
	mkdir -p $(SB_APPS_DIR)
	mkdir -p $(SB_APPS_DIR)/lib
	$(INSTALL) -D -m 755 $(@D)/'$$autorun$$.SPPBridge.Socket.wb.sb' $(SB_APPS_DIR)/'$$autorun$$.SPPBridge.Socket.wb.sb'
	$(INSTALL) -D -m 755 $(@D)/lib/advert.report.manager.sblib $(SB_APPS_DIR)/lib/advert.report.manager.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/ble.sblib $(SB_APPS_DIR)/lib/ble.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/cli.blood.pressure.custom.sblib $(SB_APPS_DIR)/lib/cli.blood.pressure.custom.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/cli.findme.custom.sblib $(SB_APPS_DIR)/lib/cli.findme.custom.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/cli.health.thermometer.custom.sblib $(SB_APPS_DIR)/lib/cli.health.thermometer.custom.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/cli.heart.rate.custom.sblib $(SB_APPS_DIR)/lib/cli.heart.rate.custom.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/cli.proximity.custom.sblib $(SB_APPS_DIR)/lib/cli.proximity.custom.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/cmd.btc.manager.sblib $(SB_APPS_DIR)/lib/cmd.btc.manager.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/connection.manager.sblib $(SB_APPS_DIR)/lib/connection.manager.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/custom.battery.service.sblib $(SB_APPS_DIR)/lib/custom.battery.service.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/custom.blood.pressure.service.sblib $(SB_APPS_DIR)/lib/custom.blood.pressure.service.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/custom.health.thermometer.service.sblib $(SB_APPS_DIR)/lib/custom.health.thermometer.service.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/custom.heart.rate.service.sblib $(SB_APPS_DIR)/lib/custom.heart.rate.service.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/custom.immediate.alert.service.sblib $(SB_APPS_DIR)/lib/custom.immediate.alert.service.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/custom.link.loss.service.sblib $(SB_APPS_DIR)/lib/custom.link.loss.service.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/custom.tx.power.service.sblib $(SB_APPS_DIR)/lib/custom.tx.power.service.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/debugging.routines.sblib $(SB_APPS_DIR)/lib/debugging.routines.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/device.information.service.sblib $(SB_APPS_DIR)/lib/device.information.service.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/fast.slow.advert.mngr.sblib $(SB_APPS_DIR)/lib/fast.slow.advert.mngr.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/gap.service.sblib $(SB_APPS_DIR)/lib/gap.service.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/iBeacon.sblib $(SB_APPS_DIR)/lib/iBeacon.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/security.manager.sblib $(SB_APPS_DIR)/lib/security.manager.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/smartZ.gatttool.sblib $(SB_APPS_DIR)/lib/smartZ.gatttool.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/smartZ.hciconfig.sblib $(SB_APPS_DIR)/lib/smartZ.hciconfig.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/smartZ.hcitool.sblib $(SB_APPS_DIR)/lib/smartZ.hcitool.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/smartZ.rfcomm.sblib $(SB_APPS_DIR)/lib/smartZ.rfcomm.sblib
	$(INSTALL) -D -m 755 $(@D)/lib/standard.advert.mngr.sblib $(SB_APPS_DIR)/lib/standard.advert.mngr.sblib
	$(INSTALL) -D -m 755 $(@D)/'$$autorun$$.iBeacon.sb' $(SB_APPS_DIR)/'$$autorun$$.iBeacon.sb'
	$(INSTALL) -D -m 755 $(@D)/bps.blood.pressure.custom.sb $(SB_APPS_DIR)/bps.blood.pressure.custom.sb
	$(INSTALL) -D -m 755 $(@D)/cmd.manager.sb $(SB_APPS_DIR)/cmd.manager.sb
	$(INSTALL) -D -m 755 $(@D)/fms.find.me.custom.sb $(SB_APPS_DIR)/fms.find.me.custom.sb
	$(INSTALL) -D -m 755 $(@D)/hrs.heart.rate.custom.sb $(SB_APPS_DIR)/hrs.heart.rate.custom.sb
	$(INSTALL) -D -m 755 $(@D)/hts.health.thermometer.custom.sb $(SB_APPS_DIR)/hts.health.thermometer.custom.sb
	$(INSTALL) -D -m 755 $(@D)/hw.hello.world.sb $(SB_APPS_DIR)/hw.hello.world.sb
	$(INSTALL) -D -m 755 $(@D)/prx.proximity.custom.sb $(SB_APPS_DIR)/prx.proximity.custom.sb
	$(INSTALL) -D -m 755 $(@D)/smartZ.sb $(SB_APPS_DIR)/smartZ.sb
endef

define WB_SMARTBASIC_APPS_UNINSTALL_TARGET_CMDS
	rm -f $(SB_APPS_DIR)/'$$autorun$$.SPPBridge.Socket.wb.sb'
	rm -f $(SB_APPS_DIR)/lib/advert.report.manager.sblib
	rm -f $(SB_APPS_DIR)/lib/ble.sblib
	rm -f $(SB_APPS_DIR)/lib/cli.blood.pressure.custom.sblib
	rm -f $(SB_APPS_DIR)/lib/cli.findme.custom.sblib
	rm -f $(SB_APPS_DIR)/lib/cli.health.thermometer.custom.sblib
	rm -f $(SB_APPS_DIR)/lib/cli.heart.rate.custom.sblib
	rm -f $(SB_APPS_DIR)/lib/cli.proximity.custom.sblib
	rm -f $(SB_APPS_DIR)/lib/cmd.btc.manager.sblib
	rm -f $(SB_APPS_DIR)/lib/connection.manager.sblib
	rm -f $(SB_APPS_DIR)/lib/custom.battery.service.sblib
	rm -f $(SB_APPS_DIR)/lib/custom.blood.pressure.service.sblib
	rm -f $(SB_APPS_DIR)/lib/custom.health.thermometer.service.sblib
	rm -f $(SB_APPS_DIR)/lib/custom.heart.rate.service.sblib
	rm -f $(SB_APPS_DIR)/lib/custom.immediate.alert.service.sblib
	rm -f $(SB_APPS_DIR)/lib/custom.link.loss.service.sblib
	rm -f $(SB_APPS_DIR)/lib/custom.tx.power.service.sblib
	rm -f $(SB_APPS_DIR)/lib/debugging.routines.sblib
	rm -f $(SB_APPS_DIR)/lib/device.information.service.sblib
	rm -f $(SB_APPS_DIR)/lib/fast.slow.advert.mngr.sblib
	rm -f $(SB_APPS_DIR)/lib/gap.service.sblib
	rm -f $(SB_APPS_DIR)/lib/iBeacon.sblib
	rm -f $(SB_APPS_DIR)/lib/security.manager.sblib
	rm -f $(SB_APPS_DIR)/lib/smartZ.gatttool.sblib
	rm -f $(SB_APPS_DIR)/lib/smartZ.hciconfig.sblib
	rm -f $(SB_APPS_DIR)/lib/smartZ.hcitool.sblib
	rm -f $(SB_APPS_DIR)/lib/smartZ.rfcomm.sblib
	rm -f $(SB_APPS_DIR)/lib/standard.advert.mngr.sblib
	rm -f $(SB_APPS_DIR)/'$$autorun$$.iBeacon.sb'
	rm -f $(SB_APPS_DIR)/bps.blood.pressure.custom.sb
	rm -f $(SB_APPS_DIR)/cmd.manager.sb
	rm -f $(SB_APPS_DIR)/fms.find.me.custom.sb
	rm -f $(SB_APPS_DIR)/hrs.heart.rate.custom.sb
	rm -f $(SB_APPS_DIR)/hts.health.thermometer.custom.sb
	rm -f $(SB_APPS_DIR)/hw.hello.world.sb
	rm -f $(SB_APPS_DIR)/prx.proximity.custom.sb
	rm -f $(SB_APPS_DIR)/smartZ.sb
	rm -f $(SB_APPS_DIR)/lib
endef

$(eval $(generic-package))
