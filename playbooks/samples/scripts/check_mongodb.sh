#!/bin/bash

LOGFILE=/tmp/check_mongodb.log
PYFILE=/tmp/check_mongodb.py
MONGOCONF=/etc/mongod.conf

touch $LOGFILE
touch $PYFILE
touch $MONGOCONF

HOSTNAME=$(hostname)
echo "HOSTNAME=$HOSTNAME" >> $LOGFILE

cat << PYEOF > $PYFILE
#!/usr/bin/python
PYEOF

BASDIR=/srv

if [ -d "$BASDIR" ]; then
    echo "BASDIR=$BASDIR exists" >> $LOGFILE
else
    echo "BASDIR=$BASDIR does not exist so cannot continue." >> $LOGFILE
    exit 1
fi

MONGODBBASDIR=$BASDIR/mongodb5

if [ -d "$MONGODBBASDIR" ]; then
    echo "MONGODBBASDIR=$MONGODBBASDIR exists" >> $LOGFILE
else
    mkdir -p $MONGODBBASDIR/data/db
    rm -R -f $MONGODBBASDIR
fi

cat << MONGOCONFEOF > $MONGOCONF
# mongod.conf
 
# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/
 
# Where and how to store data.
storage:
  dbPath: $MONGODBBASDIR/data/db
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
 
#security:
#  authorization: enabled
 
#operationProfiling:
 
#replication:
 
#sharding:
 
## Enterprise-Only Options:
 
#auditLog:
 
#snmp:
MONGOCONFEOF

if [ -f "$MONGOCONF" ]; then
    rm $MONGOCONF # not using this for now but may do so later.
fi

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

echo "1" >> $LOGFILE
if [ "$HOSTNAME" == "server1" ]; then
    echo "HOSTNAME=$HOSTNAME" >> $LOGFILE
    docker node update --label-add mongo.replica=1 server1 >> $LOGFILE
    docker node update --label-add mongo.replica=2 server-jj95enl >> $LOGFILE
    docker node update --label-add mongo.replica=3 tp01-2066 >> $LOGFILE
    #docker network create --attachable -d overlay mongo >> $LOGFILE
    docker volume create --name mongodata1 >> $LOGFILE
    docker volume create --name mongoconfig1 >> $LOGFILE
fi

echo "2" >> $LOGFILE
if [ "$HOSTNAME" == "server-jj95enl" ]; then
    echo "HOSTNAME=$HOSTNAME" >> $LOGFILE >> $LOGFILE
    docker volume create --name mongodata2 >> $LOGFILE
    docker volume create --name mongoconfig2 >> $LOGFILE
fi

echo "3" >> $LOGFILE
if [ "$HOSTNAME" == "tp01-2066" ]; then
    echo "HOSTNAME=$HOSTNAME" >> $LOGFILE
    docker volume create --name mongodata3 >> $LOGFILE
    docker volume create --name mongoconfig3 >> $LOGFILE
fi

$PY $PYFILE >> $LOGFILE

echo "DONE" >> $LOGFILE
