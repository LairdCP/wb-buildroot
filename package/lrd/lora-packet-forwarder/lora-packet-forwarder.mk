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
	$(INSTALL) -D -t $(TARGET_DIR)/usr/sbin -m 755 $(@D)/lora_pkt_fwd/lora_pkt_fwd
	$(INSTALL) -D -t $(TARGET_DIR)/opt/lora -m 755 $(@D)/lora_pkt_fwd/*.json
	$(INSTALL) -D -m 755 $(@D)/lora_pkt_fwd/update_gwid.sh $(TARGET_DIR)/usr/sbin/update_gwid
endef

define LORA_PACKET_FORWARDER_INSTALL_INIT_SYSV
	$(INSTALL) -D -t $(TARGET_DIR)/etc/init.d -m 755 package/lrd/lora-packet-forwarder/S95lora_pkt_fwd
endef

$(eval $(generic-package))

