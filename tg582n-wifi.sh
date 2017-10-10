#!/bin/bash
clear
declare -a Guest=()
echo " Guest wifi creator script for TG582N "
echo ""
echo ""
echo "How many guest wifi connections?"
read WifiCount
echo ""

for ((i=1; i<=WifiCount; i++))
do
WifiEncryption="n"
WifiPassword=""
echo "Settings for Wifi $i"
echo ""
echo "Wifi Name"
read WifiName
echo ""
echo "Encryption? y/n"
read WifiEncryption
echo ""
if [[ $WifiEncryption == "y" ]]; then
echo "Wifi Password"
read WifiPassword
fi
echo ""
echo "Gateway Address for new wifi"
read WifiGateway
echo ""
echo "DHCP Pool Start"
read WifiDHCPPoolS
echo ""
echo "DHCP Pool End"
read WifiDHCPPoolE

if [[ $WifiEncryption == "y" ]]; then
Guest[$i]=":wireless mssid ifconfig ssid_id=$i ssid=\"$WifiName\" apisolation=enabled any=enabled secmode=wpa-psk WPAPSKkey=\"$WifiPassword\" WPAPSKversion=WPA+WPA2 radio_id=0
:wireless mssid ifattach ssid_id $i
:eth ifadd intf=ETH_IF_GUEST$i
:eth ifconfig intf=ETH_IF_GUEST$i dest=wl_ssid${i}_local0
:eth ifattach intf=ETH_IF_GUEST$i
:ip ifadd intf=IP_IF_GUEST$i dest=ETH_IF_GUEST$i
:ip ifconfig intf=IP_IF_GUEST$i group guest
:ip ifattach intf=IP_IF_GUEST$i
:ip ipadd intf=IP_IF_GUEST$i addr=$WifiGateway/24
:dhcp relay ifconfig intf=IP_IF_GUEST$i relay enabled
:dhcp relay add name=GUEST${i}_to_127.0.0.1
:dhcp relay modify name=GUEST${1}_to_127.0.0.1 addr 127.0.0.1 intf=IP_IF_GUEST$i giaddr $WifiGateway
:dhcp server pool add name=POOL_GUEST$i
:dhcp server pool config name=POOL_GUEST$i intf=ETH_IF_GUEST$i poolstart=$WifiDHCPPoolS poolend=$WifiDHCPPoolE netmask=24 gateway $WifiGateway"
fi
if [[ $WifiEncryption == "n" ]]; then
Guest[$i]=":wireless mssid ifconfig ssid_id=$i ssid=\"$WifiName\" apisolation=enabled any=enabled secmode=disable radio_id=0
:wireless mssid ifattach ssid_id $i
:eth ifadd intf=ETH_IF_GUEST$i
:eth ifconfig intf=ETH_IF_GUEST$i dest=wl_ssid${i}_local0
:eth ifattach intf=ETH_IF_GUEST$i
:ip ifadd intf=IP_IF_GUEST$i dest=ETH_IF_GUEST$i
:ip ifconfig intf=IP_IF_GUEST$i group guest
:ip ifattach intf=IP_IF_GUEST$i
:ip ipadd intf=IP_IF_GUEST$i addr=$WifiGateway/24
:dhcp relay ifconfig intf=IP_IF_GUEST$i relay enabled
:dhcp relay add name=GUEST${i}_to_127.0.0.1
:dhcp relay modify name=GUEST${1}_to_127.0.0.1 addr 127.0.0.1 intf=IP_IF_GUEST$i giaddr $WifiGateway
:dhcp server pool add name=POOL_GUEST$i
:dhcp server pool config name=POOL_GUEST$i intf=ETH_IF_GUEST$i poolstart=$WifiDHCPPoolS poolend=$WifiDHCPPoolE netmask=24 gateway $WifiGateway"
fi
echo ""
done
clear
echo ""
echo "Config for the router is below"
echo ""
echo ""
echo ""
for ((z=1; z<=WifiCount; z++)) do echo ":wireless mssid ifadd"
done
for ((z=1; z<=WifiCount; z++)) do
echo "${Guest[$z]}"
done
echo ":service system ifadd name DNS-S group guest
:service system ifadd name SSDP group guest
:firewall rule add chain=forward_level_Standard name=From_Guest_to_WAN srcintf=guest dstintf=wan action=accept"
