#!/bin/bash
set -x

export DOCKER_CONTAINER=ace-audit-manager
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

export ACE_AM_DATABASE=$ACE2_AM_DATABASE
export ACE_AMDBA_USER=$ACE2_AMDBA_USER
export ACE_AMDBA_PASSWORD=$ACE2_AMDBA_PASSWORD
export ACE_AMDB_HOST=preservation-database.edu
export ACE_AMDB_PORT=3306
export ACE_AM_SMTP_HOST=smtpgate.edu
export ACE_AM_SMTP_TLS=false
export ACE_AM_SMTP_USER=glbrimhall
export ACE_AM_SMTP_FROM=payara@email.arizona.edu
export ACE_AM_SMTP_PASSWORD=" "
export ACE_AM_BOOTSTRAP_SLEEP=1

if [ "`docker ps -a | grep $DOCKER_CONTAINER`" = "" ]; then
  cd $DOCKER_CONTAINER/compose/fixity
  docker-compose up -d
  docker-compose logs --follow
fi
