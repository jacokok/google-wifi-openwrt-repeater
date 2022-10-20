#!/bin/ash

# Running on own risk


###############################
# Variables that you can change

HOSTNAME="asdf"
SSID="asdf"
PASSWORD="asdfasdfasdfasdf"
RADIO="radio0"
MOBILITY_DOMAIN="1234"

################################



# Do not need these services. Disable Daemons Persistently
for i in firewall dnsmasq odhcpd; do
  if /etc/init.d/"$i" enabled; then
    /etc/init.d/"$i" disable
    /etc/init.d/"$i" stop
  fi
done


# Become DHCP client
uci set network.lan.proto='dhcp'
uci delete network.wan
uci delete network.wan6
uci delete network.lan.ipaddr
uci delete network.lan.netmask
uci commit network

uci set network.lan.gateway="192.168.86.1"
uci set network.lan.dns="192.168.86.1"


# Hostname
uci set system.@system[0].hostname=$HOSTNAME
uci commit system

# delete conf for firewall
mv /etc/config/firewall /etc/config/firewall.unused

# delete default "OpenWrt" radios
uci delete wireless.default_radio0
uci delete wireless.default_radio1

# WIFI AP
uci set wireless.@wifi-device[0].disabled="0"
uci set wireless.@wifi-iface[0]=wifi-iface
uci set wireless.@wifi-iface[0].device=$RADIO
uci set wireless.@wifi-iface[0].mode='ap'
uci set wireless.@wifi-iface[0].ssid=$SSID
uci set wireless.@wifi-iface[0].key=$PASSWORD
uci set wireless.@wifi-iface[0].encryption=psk2
uci set wireless.@wifi-iface[0].network='lan'
uci set wireless.@wifi-iface[0].ieee80211r='1'
uci set wireless.@wifi-iface[0].mobility_domain=$MOBILITY_DOMAIN
uci set wireless.@wifi-iface[0].ft_over_ds='0'
uci set wireless.@wifi-iface[0].ft_psk_generate_local='1'
uci delete "wireless.$RADIO.disabled"
uci commit wireless

#wifi reload
wifi down
/etc/init.d/wpad restart
wifi up

# end with rebooting device
reboot