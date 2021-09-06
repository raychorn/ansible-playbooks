#!/bin/bash

fbname=$(basename "$0" | cut -d. -f1)

LOGFILE=/tmp/$fbname.log
PYFILE=/tmp/$fbname.py

rm -f $LOGFILE

touch $LOGFILE
touch $PYFILE

HOSTNAME=$(hostname)
echo "HOSTNAME=$HOSTNAME" >> $LOGFILE

cat << PYEOF > $PYFILE
#!/usr/bin/python
PYEOF

$PY $PYFILE >> $LOGFILE

#df -h >> $LOGFILE

if [ -d /srv/mongodb5 ]; then
    rm -R -f /srv/mongodb5 
fi

if [ -f /tmp/mongodb-27017.sock ]; then
    echo "/tmp/mongodb-27017.sock exists" >> $LOGFILE
fi

DIR1=/var/lib/docker/volumes/mongodata1/_data
DIR2=/var/lib/docker/volumes/mongodata2/_data
DIR3=/var/lib/docker/volumes/mongodata3/_data

if [ -d $DIR1 ]; then
    echo "Directory $DIR1 exists" >> $LOGFILE
    rm -R -f $DIR1 >> $LOGFILE 
fi

mkdir -p $DIR1 >> $LOGFILE

if [ -d $DIR2 ]; then
    echo "Directory $DIR2 exists" >> $LOGFILE
    rm -R -f $DIR2 >> $LOGFILE 
fi

mkdir -p $DIR2 >> $LOGFILE

if [ -d $DIR3 ]; then
    echo "Directory $DIR3 exists" >> $LOGFILE
    rm -R -f $DIR3 >> $LOGFILE 
fi

mkdir -p $DIR3 >> $LOGFILE

echo "" >> $LOGFILE

DIR1=/var/lib/docker/volumes/mongoconfig1/_data
DIR2=/var/lib/docker/volumes/mongoconfig2/_data
DIR3=/var/lib/docker/volumes/mongoconfig3/_data

if [ -d $DIR1 ]; then
    echo "Directory $DIR1 exists" >> $LOGFILE
    rm -R -f $DIR1 >> $LOGFILE 
fi

mkdir -p $DIR1 >> $LOGFILE

if [ -d $DIR2 ]; then
    echo "Directory $DIR2 exists" >> $LOGFILE
    rm -R -f $DIR2 >> $LOGFILE 
fi

mkdir -p $DIR2 >> $LOGFILE

if [ -d $DIR3 ]; then
    echo "Directory $DIR3 exists" >> $LOGFILE
    rm -R -f $DIR3 >> $LOGFILE 
fi

mkdir -p $DIR3 >> $LOGFILE

echo "DONE" >> $LOGFILE
