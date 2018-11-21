#!/bin/bash
set -x

export DOCKER_CONTAINER=ace-integrity-management
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

. $SETUP_DIR/../preservation-database.mysql/ace.env

export ACE_IMSDB_HOST=preservation-database.edu
export ACE_IMSDB_PORT=3306
export ACE_IMS_SMTP_HOST=smtpgate.edu
export ACE_IMS_SMTP_TLS=false
export ACE_IMS_SMTP_USER=glbrimhall

export ACE_IMS_SMTP_FROM=payara@email.university.edu
export ACE_IMS_SMTP_PASSWORD=" "
export ACE_IMS_BOOTSTRAP_SLEEP=1

if [ "`docker ps -a | grep $DOCKER_CONTAINER`" = "" ]; then
  cd $DOCKER_CONTAINER/compose/integrity
  docker-compose up -d
  docker-compose logs --follow
fi
