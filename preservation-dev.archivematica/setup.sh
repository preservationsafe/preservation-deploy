#!/bin/bash

export HOST=`hostname`
export HOSTNAME=$HOST.edu
echo "HOST: $HOST"
echo "HOSTNAME: $HOSTNAME"

# Make sure we are running from the correct directory
SETUP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
while [ ! -d "$SETUP_DIR/../$HOST.archivematica" ]; do
  SETUP_DIR="$( cd $SETUP_DIR/.. && pwd )"
done

echo "WORKINGDIR: $SETUP_DIR"
cd $SETUP_DIR

if [ "$1" = "firewall" ]; then
  export FIREWALL_OPTIONS="SED|HOST|DOCKER"
  sudo -E ../bin/archivematica-firewall.sh setup
else
  ../bin/archivematica-install.sh
fi
