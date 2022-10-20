#!/bin/ash

# Running on own risk


###############################
# Variables that you can change

HOSTNAME="Whyfive2"
SSID="Wazzup"
PASSWORD="Wazzup"
RADIO=radio1
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

# Hostname
uci set system.@system[0].hostname=$HOSTNAME

# delete conf for firewall
mv /etc/config/firewall /etc/config/firewall.unused

# delete default "OpenWrt" radios
uci delete wireless.default_radio0
uci delete wireless.default_radio1

# WIFI AP
uci set wireless.wifinet1=wifi-iface
uci set wireless.wifinet1.device=$RADIO
uci set wireless.wifinet1.mode='ap'
uci set wireless.wifinet1.ssid=$SSID
uci set wireless.wifinet1.encryption='psk2'
uci set wireless.wifinet1.key=$PASSWORD
uci set wireless.wifinet1.ieee80211r='1'
uci set wireless.wifinet1.mobility_domain=$MOBILITY_DOMAIN
uci set wireless.wifinet1.ft_over_ds='0'
uci set wireless.wifinet1.ft_psk_generate_local='1'
uci set wireless.wifinet1.network='lan'
uci delete "wireless.$RADIO.disabled"

uci commit

wifi down
/etc/init.d/wpad restart
wifi up


# end with rebooting device
reboot