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
echo "1" >> $LOGFILE
if [ "$HOSTNAME" == "server1" ]; then
    echo "HOSTNAME=$HOSTNAME" >> $LOGFILE >> $LOGFILE
    docker exec -d $(docker ps -qf "name=mongo1") chown mongodb:mongodb /mongocerts/keyfile.txt >> $LOGFILE
    docker exec -d $(docker ps -qf "name=mongo1") chmod 400 /mongocerts/keyfile.txt >> $LOGFILE
fi

echo "2" >> $LOGFILE
if [ "$HOSTNAME" == "server-jj95enl" ]; then
    echo "HOSTNAME=$HOSTNAME" >> $LOGFILE >> $LOGFILE
    docker exec -d $(docker ps -qf "name=mongo2") chown mongodb:mongodb /mongocerts/keyfile.txt >> $LOGFILE
    docker exec -d $(docker ps -qf "name=mongo2") chmod 400 /mongocerts/keyfile.txt >> $LOGFILE
fi

echo "3" >> $LOGFILE
if [ "$HOSTNAME" == "tp01-2066" ]; then
    echo "HOSTNAME=$HOSTNAME" >> $LOGFILE
    docker exec -d $(docker ps -qf "name=mongo3") chown mongodb:mongodb /mongocerts/keyfile.txt >> $LOGFILE
    docker exec -d $(docker ps -qf "name=mongo3") chmod 400 /mongocerts/keyfile.txt >> $LOGFILE
fi

cat << PYEOF > $PYFILE
#!/usr/bin/python
PYEOF

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
