#!/bin/bash

fbname=$(basename "$0" | cut -d. -f1)

LOGFILE=/tmp/$fbname.log
PYFILE=/tmp/$fbname.py

DNS=10.0.0.196

rm 0f $LOGFILE

touch $LOGFILE
touch $PYFILE

cat << EOF > $PYFILE
import os
import shutil
import socket

try:
    print('1.0')
    hostname = socket.gethostname()
    ip_address = socket.gethostbyname(hostname)
    print('2.0')

    print('{} {}.web-service.org'.format(ip_address, hostname))
    print('3.0')

    fname = '/etc/resolv.conf'
    tempFname = '/tmp/resolv.conf'

    cache = {}
    was_output = False
    assert os.path.exists(fname), '{} does not exist'.format(fname)
    if (os.path.exists(fname)):
        fOut = open(tempFname, 'w')
        try:
            with open(fname, 'r') as fIn:
                for line in fIn:
                    if (line.startswith('nameserver')):
                        toks = line.split()
                        if (len(toks[-1].split('.')) == 4):
                            print('DEBUG: cache.get({}) -> {}'.format(toks[-1], cache.get(toks[-1])))
                            if (not cache.get(toks[-1])):
                                cache[toks[-1]] = toks[0]
                                print('nameserver 10.0.0.196', file=fOut)
                                was_output = True
                            print('DEBUG: cache -> {}'.format(cache))
                        continue
                    fOut.write(line)
        except Exception as ex:
            print('*** ERROR: {}'.format(ex))
        finally:
            fOut.close()
            if (was_output):
                shutil.move(tempFname, fname)
            else:
                os.remove(tempFname)

        if (not was_output):
            for k,v in cache.items():
                print('{} {}'.format(v, k))
except Exception as ex:
    print('EXCEPTION: {}'.format(ex))

EOF

PY=$(which python3.9)
echo "PY=$PY" >> $LOGFILE

if [ -z "$PY" ]; then
    echo "python3.9 not found so cannot continue." >> $LOGFILE
    exit 1
fi

PIP=$(which pip3)
#echo "PIP=$PIP" >> $LOGFILE

HOSTNAME=$(hostname)
echo "HOSTNAME=$HOSTNAME" >> $LOGFILE

echo "PYFILE=$PYFILE" >> $LOGFILE
$PY $PYFILE >> $LOGFILE

sudo apt install resolvconf -y >> $LOGFILE
sudo systemctl enable --now resolvconf.service >> $LOGFILE
sudo systemctl restart resolvconf.service >> $LOGFILE

sudo resolvconf -u >> $LOGFILE

