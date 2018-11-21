#!/bin/bash
#set -x

HOST=`hostname`
HOSTNAME=$HOST.edu

if [ ! -d "../../dockercompose/${HOST}.archivematica" ]; then
  echo "ERROR: please 'cd' into the dockercompose/${HOST}.archivematica directory and re-run ../bin/${0##*/}"
  exit 1
fi

DOCKERCOMPOSE_DIR="$( cd ../../dockercompose && pwd )"

export NGINX_ICON_DIR=$DOCKERCOMPOSE_DIR/icon
export NGINX_ETC_DIR=/etc/nginx/conf.d
export SHIBBOLETH_ETC_DIR=/etc/shibboleth
export SMTP_DOMAIN=email.edu
export SMTP_SERVER=smtpgate.edu
export SMTP_FROM=admin@email.edu
export AMATICA_ADMIN_EMAIL="$SMTP_FROM"
export AMATICA_NOSERVICE=mysql
export AMATICA_INC_DIR=/mnt/incoming
export FILESENDER_ADMIN_EMAIL="$SMTP_FROM"
export FILESENDER_DAT_DIR=/mnt/incoming/filesender
export FILESENDER_MAIL_ATTR=HTTP_SHIB_MAIL
export FILESENDER_NAME_ATTR=HTTP_SHIB_CN
export FILESENDER_UID_ATTR=HTTP_SHIB_UID
export SHIB_UID='\$shib_uid'
export SHIB_LNAME='\$shib_sn'
export SHIB_FNAME='\$shib_givenname'
export SHIB_CNAME='\$shib_cn'
export SHIB_MAIL='\$shib_mail'

if [ ! -f archivematica/.git/config ]; then
  git clone -b 1.7.1 git@github.com:preservationsafe/archivematica.git
  sudo -E ../bin/archivematica-setup-env.sh
fi

cd archivematica/compose/shibboleth
  ./setup-amatica-shib.sh $HOSTNAME /var/lib fresh_install
cd -
