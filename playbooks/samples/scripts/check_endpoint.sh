#!/bin/bash

LOGFILE=/tmp/check_endpoint.log
PYFILE=/tmp/check_endpoint.py

touch $LOGFILE
touch $PYFILE

cat << EOF > $PYFILE
import os
import socket

roles = {
    '10.0.0.139': {
        'master': False,
        'label-add': ['mongo.role=data2 prod-mongodata-2', 'mongo.role=cfg3 prod-mongocfg-3', 'mongo.role=mongos1 prod-mongos-1'],
    },
    '10.0.0.239': {
        'master': False,
        'label-add': ['mongo.role=data3 prod-mongodata-3', 'mongo.role=cfg2 prod-mongocfg-2', 'mongo.role=mongos2 prod-mongos-2'],
    },
    '10.0.0.179': {
        'master': True,
        'label-add': ['mongo.role=data1 prod-mongodata-1', 'mongo.role=cfg1 prod-mongocfg-1'],
    },
}

hostname = socket.gethostname()
ip_address = socket.gethostbyname(hostname)

role = roles.get(ip_address, {})
label_add = role.get('label-add', [])
if (len(label_add) > 0):
    for label in label_add:
        print(label)
#print(role)

EOF

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
    $PIP install docker
fi

HOSTNAME=$(hostname)
echo "HOSTNAME=$HOSTNAME" >> $LOGFILE

if [ "$HOSTNAME" -eq "server1" ]; then
    docker node update --label-add mongo.role=data1 $HOSTNAME
    docker node update --label-add mongo.role=cfg1 $HOSTNAME
fi

if [ "$HOSTNAME" -eq "server-jj95enl" ]; then
    docker node update --label-add mongo.role=cfg2 $HOSTNAME
    docker node update --label-add mongo.role=data2 $HOSTNAME
    docker node update --label-add mongo.role=mongos1 $HOSTNAME
fi

if [ "$HOSTNAME" -eq "tp01-2066" ]; then
    docker node update --label-add mongo.role=cfg3 $HOSTNAME
    docker node update --label-add mongo.role=data3 $HOSTNAME
    docker node update --label-add mongo.role=mongos2 $HOSTNAME
fi

$PY $PYFILE >> $LOGFILE
