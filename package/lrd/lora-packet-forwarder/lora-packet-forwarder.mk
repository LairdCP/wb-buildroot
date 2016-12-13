################################################################################
#
# lora-packet-forwarder
#
################################################################################

LORA_PACKET_FORWARDER_VERSION = v3.1.0
LORA_PACKET_FORWARDER_SITE = https://github.com/Lora-net/packet_forwarder.git
LORA_PACKET_FORWARDER_SITE_METHOD = git
LORA_PACKET_FORWARDER_DEPENDENCIES = libloragw

define  LORA_PACKET_FORWARDER_BUILD_CMDS
	CC="$(TARGET_CC)" LGW_PATH="$(STAGING_DIR)/usr/lib/libloragw" $(MAKE) -C $(@D)
endef

define LORA_PACKET_FORWARDER_INSTALL_TARGET_CMDS
	$(INSTALL) -d $(TARGET_DIR)/opt/lora/
	$(INSTALL) -D -m 755 $(@D)/lora_pkt_fwd/lora_pkt_fwd $(TARGET_DIR)/usr/sbin/
	$(INSTALL) -D -m 755 $(@D)/lora_pkt_fwd/*.json $(TARGET_DIR)/opt/lora/
	$(INSTALL) -D -m 755 $(@D)/lora_pkt_fwd/update_gwid.sh $(TARGET_DIR)/usr/sbin/update_gwid
endef

define LORA_PACKET_FORWARDER_INSTALL_INITSCRIPT
	mkdir -p $(TARGET_DIR)/etc/init.d/
	$(INSTALL) -m 0755 package/lrd/lora-packet-forwarder/S95lora_pkt_fwd $(TARGET_DIR)/etc/init.d/S95lora_pkt_fwd
endef

LORA_PACKET_FORWARDER_POST_INSTALL_TARGET_HOOKS += LORA_PACKET_FORWARDER_INSTALL_INITSCRIPT

$(eval $(generic-package))

