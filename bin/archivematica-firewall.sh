#!/bin/sh

echo "IPTABLES: protecting host system"

if [ "$1" = "disable" ]; then
  iptables -F DOCKER-USER
else
if [ "$1" = "setup" ]; then

export FIREWALL_SUBNET_1="150.135.118.0/23"
export FIREWALL_SUBNET_2="150.135.238.0/23"
export FIREWALL_SUBNET_3="150.135.113.192/255.255.255.240"
export FIREWALL_SUBNET_4="150.135.135.64/26"
export FIREWALL_SUBNET_5="10.130.155.0/24"
export FIREWALL_SHIBBOLETH="shibboleth.university.edu"
export FIREWALL_SMTP="smtpgate.email.university.edu"
export FIREWALL_DEVICE="ens160"
   
cd archivematica/compose/shibboleth/firewall
./setup-firewall.sh "$FIREWALL_OPTIONS"
cd -

else
  iptables-restore -n /etc/iptables.docker-firewall.rules
  iptables -L
fi
fi
