#!/bin/bash

fbname=$(basename "$0" | cut -d. -f1)

LOGFILE=/tmp/$fbname.log
PYFILE=/tmp/$fbname.py

DNS=10.0.0.196

rm 0f $LOGFILE

touch $LOGFILE
touch $PYFILE

cat << EOF > $PYFILE
EOF

PY=$(which python3.9)
#echo "PY=$PY" >> $LOGFILE

if [ -z "$PY" ]; then
    echo "python3.9 not found so cannot continue." >> $LOGFILE
    exit 1
fi

PIP=$(which pip3)
#echo "PIP=$PIP" >> $LOGFILE

HOSTNAME=$(hostname)
#echo "HOSTNAME=$HOSTNAME" >> $LOGFILE

$PY $PYFILE >> $LOGFILE

DOMAIN=server-jj95enl.web-service.org
TEST=$(ping $DOMAIN -c 3 | grep "3 received" | grep "0% packet loss")
if [ -z "$TEST" ]; then
    echo "ERROR: $DOMAIN not found so cannot continue." >> $LOGFILE
    exit 1
fi

DOMAIN=tp01-2066.web-service.org
TEST=$(ping $DOMAIN -c 3 | grep "3 received" | grep "0% packet loss")
if [ -z "$TEST" ]; then
    echo "ERROR: $DOMAIN not found so cannot continue." >> $LOGFILE
    exit 1
fi

DOMAIN=server1.web-service.org
TEST=$(ping $DOMAIN -c 3 | grep "3 received" | grep "0% packet loss")
if [ -z "$TEST" ]; then
    echo "ERROR: $DOMAIN not found so cannot continue." >> $LOGFILE
    exit 1
fi

DOMAIN=controller.web-service.org
TEST=$(ping $DOMAIN -c 3 | grep "3 received" | grep "0% packet loss")
if [ -z "$TEST" ]; then
    echo "ERROR: $DOMAIN not found so cannot continue." >> $LOGFILE
    exit 1
fi

echo "All tests passed." >> $LOGFILE
