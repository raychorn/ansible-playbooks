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
#MONGOCONF=$MONGOETC/mongod.conf
MONGOCONF=mongod.conf
echo "1" >> $LOGFILE
if [ "$HOSTNAME" == "server1" ]; then
    echo "HOSTNAME=$HOSTNAME" >> $LOGFILE
    docker node update --label-add mongo.replica=1 server1 >> $LOGFILE
    docker node update --label-add mongo.replica=2 server-jj95enl >> $LOGFILE
    docker node update --label-add mongo.replica=3 tp01-2066 >> $LOGFILE

    #docker volume rm mongoconf1 >> $LOGFILE

    docker volume create mongodata1 >> $LOGFILE
    docker volume create mongoconf1 >> $LOGFILE
    docker volume create mongoconfigdb1 >> $LOGFILE
    BASEDIR=/var/lib/docker/volumes/mongoconf1/_data
fi

echo "2" >> $LOGFILE
if [ "$HOSTNAME" == "server-jj95enl" ]; then
    echo "HOSTNAME=$HOSTNAME" >> $LOGFILE >> $LOGFILE
    #docker volume rm mongoconf2 >> $LOGFILE

    docker volume create --name mongodata2 >> $LOGFILE
    docker volume create --name mongoconf2 >> $LOGFILE
    docker volume create --name mongoconfigdb2 >> $LOGFILE
    BASEDIR=/var/lib/docker/volumes/mongoconf2/_data/
fi

echo "3" >> $LOGFILE
if [ "$HOSTNAME" == "tp01-2066" ]; then
    echo "HOSTNAME=$HOSTNAME" >> $LOGFILE
    #docker volume rm mongoconf3 >> $LOGFILE

    docker volume create --name mongodata3 >> $LOGFILE
    docker volume create --name mongoconf3 >> $LOGFILE
    docker volume create --name mongoconfigdb3 >> $LOGFILE
    BASEDIR=/var/lib/docker/volumes/mongoconf3/_data/
fi

MONGOCONF=$BASEDIR/$MONGOCONF

touch $MONGOCONF

cat << PYEOF > $PYFILE
#!/usr/bin/python
PYEOF

echo "MONGOCONF=$MONGOCONF" >> $LOGFILE
cat << MONGOCONFEOF > $MONGOCONF
# mongod.conf
 
# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/
 
# Where and how to store data.
storage:
  dbPath: /data/db
  journal:
    enabled: false
  directoryPerDB: false
#  engine:
#  mmapv1:
#  wiredTiger:
#    engineConfig:
#      cacheSizeGB: 4
    
 
# where to write logging data.
systemLog:
  quiet: true
  destination: syslog
  logAppend: true
 
# network interfaces
net:
  port: 27017
  bindIp: 0.0.0.0
  ipv6: false
 
 
# how the process runs
processManagement:
  timeZoneInfo: /usr/share/zoneinfo
 
security:
  authorization: enabled
 
#operationProfiling:
 
replication:
   replSetName: "rs0"

#sharding:
 
## Enterprise-Only Options:
 
#auditLog:
 
#snmp:
MONGOCONFEOF

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
