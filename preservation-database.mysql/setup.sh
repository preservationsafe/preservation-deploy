#!/bin/bash
set -x

export DOCKER_CONTAINER=ace-dbstore-mysql
export DOCKER_CONTAINER_V=1.12
export HOST=`hostname`
export HOSTNAME=$HOST.edu
echo "HOST: $HOST"
echo "HOSTNAME: $HOSTNAME"

# Make sure we are running from the correct directory
SETUP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
while [ ! -d "$SETUP_DIR/../../dockercompose/bin" ]; do
  SETUP_DIR="$( cd $SETUP_DIR/.. && pwd )"
done

echo "WORKINGDIR: $SETUP_DIR"
cd $SETUP_DIR

if [ ! -f $DOCKER_CONTAINER/.git/config ]; then
  git clone -b $DOCKER_CONTAINER_V git@github.com:preservationsafe/$DOCKER_CONTAINER.git
fi

. $SETUP_DIR/ace.env

if [ ! -d "$ACE_DBSTORE" ]; then
  sudo mkdir -p "$ACE_DBSTORE"
fi

if [ "`docker ps -a | grep $DOCKER_CONTAINER`" = "" ]; then
  cd $DOCKER_CONTAINER/compose/ace
  docker-compose up -d
  docker-compose logs --follow
fi
