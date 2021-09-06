#!/bin/bash

fbname=$(basename "$0" | cut -d. -f1)

LOGFILE=/tmp/$fbname.log
PYFILE=/tmp/$fbname.py

HOSTNAME=$(hostname)
echo "HOSTNAME=$HOSTNAME" >> $LOGFILE

rm -f $LOGFILE
rm -f $PYFILE

touch $LOGFILE
touch $PYFILE

MONGOETC=
MONGOCONF=mongod.conf
echo "1" >> $LOGFILE
if [ "$HOSTNAME" == "server1" ]; then
  echo "HOSTNAME=$HOSTNAME" >> $LOGFILE
  docker volume create mongodata1 >> $LOGFILE
  docker volume create mongoconf1 >> $LOGFILE
  docker volume create mongoconfigdb1 >> $LOGFILE
  docker volume create mongocerts1 >> $LOGFILE
  BASEDIR=/var/lib/docker/volumes/mongocerts1/_data
  KEYFILE=$BASEDIR/keyfile.txt 
  ls -la $BASEDIR >> $LOGFILE
  docker volume create mongologs1 >> $LOGFILE
  docker volume create mongoconf1 >> $LOGFILE
  BASEDIR=/var/lib/docker/volumes/mongoconf1/_data
  ls -la $BASEDIR >> $LOGFILE
  ls -la /etc/mongo* >> $LOGFILE
fi

echo "2" >> $LOGFILE
if [ "$HOSTNAME" == "server-jj95enl" ]; then
    echo "HOSTNAME=$HOSTNAME" >> $LOGFILE
    docker volume create mongodata2 >> $LOGFILE
    docker volume create mongoconf2 >> $LOGFILE
    docker volume create mongoconfigdb2 >> $LOGFILE
    docker volume create mongocerts2 >> $LOGFILE
    BASEDIR=/var/lib/docker/volumes/mongocerts2/_data
    KEYFILE=$BASEDIR/keyfile.txt 
    ls -la $BASEDIR >> $LOGFILE
    docker volume create mongologs2 >> $LOGFILE
    docker volume create mongoconf2 >> $LOGFILE
    BASEDIR=/var/lib/docker/volumes/mongoconf2/_data
    ls -la $BASEDIR >> $LOGFILE
    ls -la /etc/mongo* >> $LOGFILE
fi

echo "3" >> $LOGFILE
if [ "$HOSTNAME" == "tp01-2066" ]; then
    echo "HOSTNAME=$HOSTNAME" >> $LOGFILE
    docker volume create mongodata3 >> $LOGFILE
    docker volume create mongoconf3 >> $LOGFILE
    docker volume create mongoconfigdb3 >> $LOGFILE
    docker volume create mongocerts3 >> $LOGFILE
    BASEDIR=/var/lib/docker/volumes/mongocerts3/_data
    KEYFILE=$BASEDIR/keyfile.txt 
    ls -la $BASEDIR >> $LOGFILE
    docker volume create mongologs3 >> $LOGFILE
    docker volume create mongoconf3 >> $LOGFILE
    BASEDIR=/var/lib/docker/volumes/mongoconf3/_data
    ls -la $BASEDIR >> $LOGFILE
    ls -la /etc/mongo* >> $LOGFILE
fi

MONGOCONF=$BASEDIR/$MONGOCONF

touch $MONGOCONF

echo "PYFILE=$PYFILE" >> $LOGFILE
cat << PYEOF > $PYFILE
#!/usr/bin/python
PYEOF


echo "KEYFILE=$KEYFILE" >> $LOGFILE
cat << KEYEOF > $KEYFILE
PT2Us30w6ToKz4dq2rOGvu5Vab5H4DoVL6OcUKTs9fDBRuzYfL2CedR5wRcgds/z
CNpslWgNYsSs8NEQnE+WsY5iaZzEp44wjbWm6KmplGsL05nhiQK6SSkvZsx9XQ9L
ppYN4K43KEgindDoQ2JcTen+7kHcptDAXqcbObkrRri9leKOsLPwJdIGy8J8VPG+
VNZhy0QIaK+bA3KhDlZrfgIwE22tQv/YJZmgq1ZoWluOZSXjuSPke5IrUZiFJDgD
iZK3K7EYcnDltoIFSMiAwlF5ytIXZzBW1HzhqnXX8N1Mn1cQGRkkwWVbeQEqBEyx
li7+1TxiERbeaYj8+duweZUBgCl1j8kwrl3IR/6sIi8lZIq3OTCKm2jlVWdW5xgr
nTt+jzo+aw1pFl91xC0E8IEU5wzslc2LBLhp8LhlAfa4QqBZyAjB6+cNgxAYKUD5
O0Xg06VuBd90TMMfmzx2QetIQ/SzTkT++ps2EP2bWzU64+0E430CT9lij8LMSpOf
OlDKq9ki/z9uCPSJAspxr0btXKOEgSsrtV9lQ24G+J7WnEYStIGb309pUGYDgXga
a2uC2gwe0+KjeT1U2A1YexEMZJslEFhkFmIchDMMWvCURa4VtUmqYrf6uNn/51Hx
S4el/mb5YiidWYsZpNWZz2P+PeTzskEOjR/hLLCkBd4G3ZPWFdgVa0DmoPksRScx
WIQKCStLabKDRyiiPV2RgmJPnyv7qpYEB16HYeJosp8+2oxLv0pTA577aei1VY22
2aMs1wweXK76bZNHtn+GU7VTg8j/9VtFJkuh6ZJJo10fQURT/1d3ZB0rOE4731+h
/4CtvFhCSAuGaNHtYsiSUpCWYZe9L5LsGzzDraUwnzoLLXZG99O7ebQtH4IPlCZx
xuLgqa9RF6pgKKgvrtAXd6WOTugmBXnGZiye5k2jZCrNCrkR5vtdVJmRW2VO6LVo
8wp5OwGz9WUwA+0SSpEQv+FdPbalJQu2wLj9rEA+tdypyvTL
KEYEOF


echo "MONGOCONF=$MONGOCONF" >> $LOGFILE
cat << MONGOCONFEOF > $MONGOCONF
# Where and how to store data.
storage:
  dbPath: /data/db
  journal:
    enabled: true
#  engine:
#  mmapv1:
#  wiredTiger:
#    engineConfig:
#      cacheSizeGB: 4
    
 
# where to write logging data.
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log
 
# network interfaces
net:
  port: 27017
  bindIp: 0.0.0.0
  ipv6: false
 
# how the process runs
processManagement:
  timeZoneInfo: /usr/share/zoneinfo
 
security:
  keyFile: /mongocerts/keyfile.txt
  transitionToAuth: true

#operationProfiling:
 
replication:
   replSetName: rs0

#sharding:
 
## Enterprise-Only Options:
 
#auditLog:
 
#snmp:
MONGOCONFEOF

chown mongodb:mongodb $MONGOCONF

PY=$(which python3.9)
echo "PY=$PY" >> $LOGFILE

if [ -z "$PY" ]; then
    echo "python3.9 not found so cannot continue." >> $LOGFILE
    exit 1
fi

PIP=$(which pip3)
echo "PIP=$PIP" >> $LOGFILE

if [ -z "$PIP" ]; then
    echo "pip3 not found so cannot continue." >> $LOGFILE
    exit 1
fi

TEST=$($PIP list | grep docker)

if [ -z "$TEST" ]; then
    echo $PIP install docker
fi

$PY $PYFILE >> $LOGFILE

echo "DONE" >> $LOGFILE
