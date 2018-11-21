#!/bin/sh

HOST=`hostname`
HOSTNAME=$HOST.edu
PURGE="$1"

if [ ! -d "../../dockercompose/${HOST}.archivematica" ]; then
  echo "ERROR: please 'cd' into the dockercompose/${HOST}.archivematica directory and re-run ../bin/${0##*/}"
  exit 0
fi

if [ ! -d archivematica/compose/shibboleth ]; then
  echo "Archivematica docker-compose does not appear to be present, exiting"
  exit 1
fi


echo "DESTROYING archivematica instance and all persistant data"

cd archivematica/compose/shibboleth
docker-compose rm -fsv
echo "y" | docker volume prune
cd -

echo "CLEANING archivematica firewall rules"

cd archivematica/compose/shibboleth/firewall
./setup-firewall.sh CLEAN
cd -

LOGGING_DIR=/var/log
LOGDIR_LIST="shibboleth amatica nginx filesender mysql supervisor"

for LOGDIR in $LOGDIR_LIST; do
  sudo rm -vfr "$LOGGING_DIR/$LOGDIR"
done

ETCDIR_LIST="shibboleth nginx"

for ETCDIR in $ETCDIR_LIST; do
  sudo rm -vfr "/etc/$ETCDIR"
done

if [ "$PURGE" != "" ]; then
  DATDIR_LIST="_shibd elasticsearch gearman nginx clamav mysql archivematica filesender"
  
  for DATDIR in $DATDIR_LIST; do
    sudo rm -vfr "/var/lib/$DATDIR"
  done
fi

sudo rm -vfr archivematica
