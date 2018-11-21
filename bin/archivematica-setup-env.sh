#!/bin/bash
#set -x

HOST=`hostname`
HOSTNAME=$HOST.edu

if [ ! -d "../../dockercompose/${HOST}.archivematica" ]; then
  echo "ERROR: please 'cd' into the dockercompose/${HOST}.archivematica directory and re-run ../bin/${0##*/}"
  exit 1
fi

if [ ! -d archivematica/compose/shibboleth ]; then
  echo "ERROR: please run 'git clone -b 1.6.1-beta3 git@github.com:ualibraries/archivematica.git'"
  exit 1
fi

cd archivematica/compose/shibboleth

./setup-amatica-shib.sh $HOSTNAME /var/lib config_only

echo "COPYING: nginx configuration to /etc"
cp -vR web/nginx /etc

echo "COPYING: shibboleth configuration to /etc"
cp -vR shib/supervisor /etc
cd -

cp -vR ../etc.shibboleth /etc/shibboleth
cat ../etc.shibboleth/shibboleth2.xml | \
sed -e "s|{HOSTNAME}|$HOSTNAME|g" \
    > /etc/shibboleth/shibboleth2.xml

echo "COPYING: certs"
cp -vR ../$HOST.certs/web/* /etc/nginx/conf.d
cd /etc/nginx/conf.d
rm host.*
ln -vs $HOSTNAME.chained.crt host.crt
ln -vs $HOSTNAME.key host.key
chmod 644 $HOSTNAME.*
cd -

cp -vR ../$HOST.certs/shib/* /etc/shibboleth
cd /etc/shibboleth
rm sp-*.pem
ln -vs $HOSTNAME.crt sp-cert.pem
ln -vs $HOSTNAME.key sp-key.pem
chmod 644 $HOSTNAME.*
cd -

if [ ! -f /etc/fstab.pre-preservation ]; then
  cp /etc/fstab /etc/fstab.pre-preservation
fi

cp /etc/fstab.pre-preservation /etc/fstab
cat >>/etc/fstab <<EOF

# preservation incoming
//nas.edu/$HOST-workspace /mnt/incoming/workspace cifs vers=2.1,credentials=/home/buildmeister/.smbcredentials,uid=333,gid=333,file_mode=0664,dir_mode=0775,nounix,iocharset=utf8,sec=ntlm 0 0

//nas.edu/oral-history /mnt/incoming/oral-history cifs vers=2.1,credentials=/home/buildmeister/.smbcredentials,uid=333,gid=333,file_mode=0664,dir_mode=0775,nounix,iocharset=utf8,sec=ntlm 0 0

# preservation storage
nas.edu:/$HOST-storage /var/lib/archivematica/sharedDirectory nfs nfsvers=3,proto=tcp,hard,intr 0 0

EOF

apt-get update
apt-get install -y cifs-utils nfs-common

mkdir -p /mnt/incoming
chown archivematica.archivematica /mnt/incoming
INCOMING_DIRLIST="\
/mnt/incoming/workspace \
/mnt/incoming/oral-history \
/mnt/incoming/filesender \
/var/lib/archivematica/sharedDirectory"

for INCOMING_DIR in $INCOMING_DIRLIST; do
  mkdir -p $INCOMING_DIR
  chown archivematica.archivematica $INCOMING_DIR
  if [ "`mount | grep $INCOMING_DIR`" = "" ]; then
    mount $INCOMING_DIR
  fi
done
