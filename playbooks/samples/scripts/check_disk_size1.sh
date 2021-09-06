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
    echo "HOSTNAME=$HOSTNAME" >> $LOGFILE
    echo "[1]" >> $LOGFILE
    df -h >> $LOGFILE
    echo "[2]" >> $LOGFILE
    lsblk >> $LOGFILE
    echo "[3]" >> $LOGFILE
    free -m -h >> $LOGFILE
fi

echo "2" >> $LOGFILE
if [ "$HOSTNAME" == "server-jj95enl" ]; then
    echo "HOSTNAME=$HOSTNAME" >> $LOGFILE
    echo "[1]" >> $LOGFILE
    df -h >> $LOGFILE
    echo "[2]" >> $LOGFILE
    lsblk >> $LOGFILE
    echo "[3]" >> $LOGFILE
    free -m -h >> $LOGFILE
fi

echo "3" >> $LOGFILE
if [ "$HOSTNAME" == "tp01-2066" ]; then
    echo "HOSTNAME=$HOSTNAME" >> $LOGFILE
    echo "[1]" >> $LOGFILE
    df -h >> $LOGFILE
    echo "[2]" >> $LOGFILE
    lsblk >> $LOGFILE
    echo "[3]" >> $LOGFILE
    free -m -h >> $LOGFILE
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
    echo ""
fi

$PY $PYFILE >> $LOGFILE

echo "DONE" >> $LOGFILE
