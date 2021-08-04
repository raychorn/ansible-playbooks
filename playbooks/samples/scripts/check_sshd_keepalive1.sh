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
fi

echo "2" >> $LOGFILE
if [ "$HOSTNAME" == "server-jj95enl" ]; then
    echo "HOSTNAME=$HOSTNAME" >> $LOGFILE
fi

echo "3" >> $LOGFILE
if [ "$HOSTNAME" == "tp01-2066" ]; then
    echo "HOSTNAME=$HOSTNAME" >> $LOGFILE
fi

# comment out some stuff
TEST0=.
if [ "$TEST0." == "." ]; then
    echo "[1]" >> $LOGFILE
    TEST1=$(cat /etc/ssh/sshd_config | grep "^ServerAliveInterval")
    if [ -z "$TEST1" ]; then
        echo "ServerAliveInterval 60" >> /etc/ssh/sshd_config
        echo "[2]" >> $LOGFILE
    fi
    TEST2=$(lsb_release -r | egrep -o "[0-9]{1,2}\.[0-9]{1,2}")
    # if os release is ubuntu 20.04 or later, then we need to restart ssh service
    if [ "$TEST2" == "20.04" ]; then
        echo "[3]" >> $LOGFILE
        systemctl start ssh
    else
        echo "[4]" >> $LOGFILE
        service ssh restart
    fi
fi

SSHD_MONITOR_FILE=/root/sshd_monitor.sh
cat << BASHEOF > $SSHD_MONITOR_FILE
#!/bin/bash

NUMCONN=$(ss | grep -i ssh | egrep -o "([0-9]{1,3}\.){3}[0-9]{1,3}\:ssh.*([0-9]{1,3}\.){3}[0-9]{1,3}" | wc -l)

PANIC_COUNTER=/tmp/sshd_keep_alive_panic_counter.txt
PANIC_HISTORY=/tmp/sshd_keep_alive_panic_history.txt

if [ ! -f $PANIC_COUNTER ]; then
    echo "0" > $PANIC_COUNTER
fi

if [ $NUMCONN -ge 1 ]; then
    echo "Number of connections: $NUMCONN"
    echo "SSH is running"
else
    echo "SSH is not running so restarting."
    echo $(date) >> $PANIC_HISTORY

    if [ -f $PANIC_COUNTER ]; then
        PANIC_COUNTER_VALUE=$(cat $PANIC_COUNTER)
        echo $PANIC_COUNTER_VALUE >> $PANIC_COUNTER
    fi

    TEST2=$(lsb_release -r | egrep -o "[0-9]{1,2}\.[0-9]{1,2}")
    if [ "$TEST2" == "20.04" ]; then
        systemctl start ssh
    else
        service ssh restart
    fi
fi
BASHEOF
chmod +x $SSHD_MONITOR_FILE

if [ -f $SSHD_MONITOR_FILE ]; then
    echo "[5]" >> $LOGFILE
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
