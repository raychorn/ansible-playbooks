#!/bin/bash

fbname=$(basename "$0" | cut -d. -f1)

LOGFILE=/tmp/$fbname.log
PYFILE=/tmp/$fbname.py

if [ -f "$LOGFILE" ]; then
    rm -f $LOGFILE
fi

touch $LOGFILE
touch $PYFILE

HOSTNAME=$(hostname)
echo "(***) BEGIN: $HOSTNAME" >> $LOGFILE
echo "" >> $LOGFILE

sudo apt-get update -y >> $LOGFILE
sudo apt-get upgrade -y >> $LOGFILE

echo "" >> $LOGFILE
echo "---------------------------------------------------------------" >> $LOGFILE
echo "" >> $LOGFILE

#docker volume ls >> $LOGFILE 

HAS=
SUB=mongodata
xx=
while read x; do 
    if [[ "$x" == *"$SUB"* ]]; then
        xx=$(echo $x | awk '{ print $2 }')
        echo "(+)$xx" >> $LOGFILE
        HAS=.
    fi
    echo; 
done << EOF
$(docker volume ls)
EOF

if [[ "$HAS." == ".." ]]; then
    echo "(!)$xx" >> $LOGFILE
else
    echo "ERROR, cannot continue." >> $LOGFILE
    exit
fi

VOLUME_DIR=$(docker volume inspect $xx | jq -r '.[0].Mountpoint')

if [ ! -d $VOLUME_DIR ]; then
    echo "ERROR: $VOLUME_DIR is missing." >> $LOGFILE
    exit
fi

TARGET=server1

if [[ "$HOSTNAME" == "$TARGET" ]]; then
    echo "BEGIN: $VOLUME_DIR" >> $LOGFILE
    ls -la $VOLUME_DIR >> $LOGFILE
    echo "END!!! $VOLUME_DIR" >> $LOGFILE
    echo "=========================================" >> $LOGFILE
    mount >> $LOGFILE
    echo "=========================================" >> $LOGFILE
    ls -la /mnt >> $LOGFILE
    echo "=========================================" >> $LOGFILE
    ls -la /media >> $LOGFILE
fi

echo "" >> $LOGFILE
echo "---------------------------------------------------------------" >> $LOGFILE
echo "" >> $LOGFILE

echo "" >> $LOGFILE
echo "(***) END!!! $(hostname)" >> $LOGFILE

echo "(***) DONE !!!" >> $LOGFILE
exit

# bash function to test if directory is empty
function isEmpty {
    # $1 is the directory
    # $2 is the variable to return
    local  __resultvar=$2
    local  return_val=-1

    if [ ! -d "$1" ]; then
        #echo "Directory $1 does not exist"
        return_val=0
    fi
    if [ "$(ls -A $1)" ]; then
        #echo "Directory $1 is not empty"
        return_val=False
    else
        #echo "Directory $1 is empty"
        return_val=True
    fi

    if [[ "$__resultvar" ]]; then
        eval $__resultvar="'$return_val'"
    else
        echo "$return_val"
    fi
}

PY=$(which python3.9)
echo "PY=$PY" >> $LOGFILE

if [ -z "$PY" ]; then
    echo "python3.9 not found so cannot continue." >> $LOGFILE
    exit
fi

PIP=$(which pip3)
echo "PIP=$PIP" >> $LOGFILE

PIP_VERSION=$($PIP --version)
echo "(1) PIP_VERSION=$PIP_VERSION" >> $LOGFILE

BASEPY=$(basename $PY)
PIP_TEST1=$($PIP --version | grep $BASEPY)
echo "PIP_TEST1=$PIP_TEST1" >> $LOGFILE
echo "BASEPY=$BASEPY" >> $LOGFILE

if [ -z "$PIP_TEST1" ]; then
    echo "Cannot find PIP for $PY so install it." >> $LOGFILE
    exit
    su raychorn -
    curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
    $PY /tmp/get-pip.py
    su root -
fi

VIRTUALENV=$(which virtualenv)
echo "(1) VIRTUALENV=$VIRTUALENV" >> $LOGFILE

if [ -z "$VIRTUALENV" ]; then
    echo "virtualenv not found so install it." >> $LOGFILE
    su raychorn -
    $PIP install virtualenv
    su root -
fi

VIRTUALENV=$(which virtualenv)
echo "(2) VIRTUALENV=$VIRTUALENV" >> $LOGFILE

if [ -z "$VIRTUALENV" ]; then
    echo "virtualenv not found so cannot continue." >> $LOGFILE
    exit
fi

PIP_VERSION=$($PIP --version)
echo "(2) PIP_VERSION=$PIP_VERSION" >> $LOGFILE

PIP_TEST1=$($PIP --version | grep $(basename $PY))
echo "PIP_TEST1=$PIP_TEST1" >> $LOGFILE

if [ -z "$PIP_TEST1" ]; then
    echo "Cannot find PIP for $PY so cannot continue." >> $LOGFILE
    exit
fi

if [ -f ~/.venv/bin/activate ]; then
    echo "virtualenv exists." >> $LOGFILE
else
    echo "virtualenv does not exist so making it." >> $LOGFILE
    cd ~ && $VIRTUALENV -p $PY .venv
fi

if [ -f ~/.venv/bin/activate ]; then
    echo "virtualenv created." >> $LOGFILE
else
    echo "virtualenv not created." >> $LOGFILE
    exit
fi

. ~/.venv/bin/activate

PY=$(which python3.9)
echo "PY=$PY" >> $LOGFILE

PIP=$(which pip3)
echo "PIP=$PIP" >> $LOGFILE

PIP_NETIFACES_TEST1=$($PIP list | grep netifaces)
echo "(1) PIP_NETIFACES_TEST1=$PIP_NETIFACES_TEST1" >> $LOGFILE

if [ -z "$PIP_NETIFACES_TEST1" ]; then
    echo "Cannot find $PIP_NETIFACES_TEST1 so installing it." >> $LOGFILE
    $PIP install netifaces
fi

PIP_NETIFACES_TEST1=$($PIP list | grep netifaces)
echo "(2) PIP_NETIFACES_TEST1=$PIP_NETIFACES_TEST1" >> $LOGFILE

if [ -z "$PIP_NETIFACES_TEST1" ]; then
    echo "Cannot find $PIP_NETIFACES_TEST1 so cannot continue." >> $LOGFILE
    exit
fi

PIP_LIST=$($PIP list)
echo "PIP_LIST=$PIP_LIST" >> $LOGFILE

HOSTNAME=$(hostname)
echo "HOSTNAME=$HOSTNAME" >> $LOGFILE

PING=$(which ping)
echo "PING=$PING" >> $LOGFILE

APT_TEST=$(apt list --installed nfs-common | grep nfs-common)

if [ -z "$APT_TEST" ]; then
    echo "Cannot find nfs-common so installing it." >> $LOGFILE
    apt install nfs-common -y >> $LOGFILE
fi

APT_TEST2=$(apt list --installed jq | grep jq)

if [ -z "$APT_TEST2" ]; then
    echo "Cannot find jq so installing it." >> $LOGFILE
    apt install jq -y >> $LOGFILE
fi

HOSTS=/etc/hosts
echo "BEGIN: $HOSTS" >> $LOGFILE
cat $HOSTS >> $LOGFILE
echo "END!!! $HOSTS" >> $LOGFILE

cat << HOSTSEOF > /tmp/hosts.txt
127.0.0.1 localhost
IP_ADDRESS HOSTNAME
IP_ADDRESS FQ_HOSTNAME

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
HOSTSEOF

cat << EOF > $PYFILE
import os
import sys
import socket
is_netifaces = False
try:
    import netifaces
    is_netifaces = True
except ImportError:
    print('BEGIN: sys.path')
    for f in sys.path:
        print(f)
    print('END!!! sys.path')
    print("netifaces not installed")

def get_Host_name_IP():
    try:
        host_name = socket.gethostname()
        host_ip = socket.gethostbyname(host_name)
    except:
        host_name = None
        host_ip = None
        print("Unable to get Hostname and IP")
    return host_name, host_ip

fpath = sys.argv[1]
assert os.path.exists(fpath), '%s does not exist' % fpath
print('fpath=%s' % fpath)
host_name, host_ip = get_Host_name_IP()
print('host_name={}, host_ip={}'.format(host_name, host_ip))

current_ip_addrs = None
if (is_netifaces):
    target_ip = '10.0.0.'
    interfaces = netifaces.interfaces()
    for interface in interfaces:
        addrs = netifaces.ifaddresses(str(interface))
        if netifaces.AF_INET in addrs:
            for addr in addrs[netifaces.AF_INET]:
                if ('addr' in addr) and (addr['addr'].find(target_ip) > -1):
                    current_ip_addrs = addr['addr']
                    break
        if (current_ip_addrs):
            break
print('current_ip_addrs: {}'.format(current_ip_addrs))

hosts_file = '/etc/hosts'

changes_made_file = '/tmp/etc_hosts_changes'
if (os.path.exists(changes_made_file)):
    os.remove(changes_made_file)

with open(changes_made_file, 'w') as fOut2:
    print('no', file=fOut2)

if (host_ip != current_ip_addrs):
    print('WARNING: {} is not configured correctly.'.format(hosts_file))

    print('BEGIN: {}'.format(fpath))
    with open(fpath, 'r') as fIn:
        fOut = open(hosts_file, 'w')
        fOut2 = open(changes_made_file, 'w')
        for l in fIn:
            l = l.strip()
            if (l.find('IP_ADDRESS') > -1):
                l = l.replace('IP_ADDRESS', current_ip_addrs)
            if (l.find('FQ_HOSTNAME') > -1):
                l = l.replace('FQ_HOSTNAME', '{}.web-service.org'.format(host_name))
            if (l.find('HOSTNAME') > -1):
                l = l.replace('HOSTNAME', host_name)
            print(l, file=fOut)
        print('yes', file=fOut2)
        fOut2.flush()
        fOut2.close()
        fOut.flush()
        fOut.close()
    print('END!!! {}'.format(fpath))

print('Python done.')
EOF

$PY $PYFILE /tmp/hosts.txt >> $LOGFILE

CHANGES_MADE_TEST=$(cat /tmp/etc_hosts_changes)

if [ "$CHANGES_MADE_TEST" == "yes" ]; then
    echo "Changes made to /etc/hosts" >> $LOGFILE

    echo "Restarting networking" >> $LOGFILE
    /etc/init.d/networking restart
    echo "Restarted networking" >> $LOGFILE
else
    echo "No changes made to /etc/hosts" >> $LOGFILE
fi

SRV=/srv

if [ ! -d $SRV ]; then
    echo "Creating $SRV" >> $LOGFILE
    mkdir -p $SRV
fi

ISEMPTY_TEST=-1
isEmpty $SRV ISEMPTY_TEST
echo "(***) ISEMPTY_TEST -> $ISEMPTY_TEST" >> $LOGFILE

if [ "$ISEMPTY_TEST" == "0" ]; then
    echo "Creating $SRV" >> $LOGFILE
    mkdir -p $SRV
fi

if [ "$ISEMPTY_TEST" == "True" ]; then
    echo "$SRV is empty" >> $LOGFILE
    echo "(***) HOSTNAME=$HOSTNAME" >> $LOGFILE
    NFS_TEST=$(mount | grep nfs | grep "/mnt/user/docker_share")
    if [ "$HOSTNAME." == "docker1." ]; then
        echo "Connect to NFS ($HOSTNAME)" >> $LOGFILE
        if [ -z "$NFS_TEST" ]; then
            echo "Mounting NFS" >> $LOGFILE
            mount -t nfs 10.0.0.164:/mnt/user/docker_share /srv
            echo "Mounted NFS" >> $LOGFILE
        fi
        FSTAB_TEST=$(cat /etc/fstab | grep /mnt/user/docker_share)
        if [ -z "$FSTAB_TEST" ]; then
            echo "Adding /mnt/user/docker_share to /etc/fstab" >> $LOGFILE
            echo "10.0.0.164:/mnt/user/docker_share /srv nfs defaults 0 0" >> /etc/fstab
            echo "Added /mnt/user/docker_share to /etc/fstab" >> $LOGFILE
        fi
    fi
    if [ "$HOSTNAME." == "docker2." ]; then
        echo "Connect to NFS ($HOSTNAME)" >> $LOGFILE
        if [ -z "$NFS_TEST" ]; then
            echo "Mounting NFS" >> $LOGFILE
            mount -t nfs 10.0.0.177:/mnt/user/docker_share /srv
            echo "Mounted NFS" >> $LOGFILE
        fi
        FSTAB_TEST=$(cat /etc/fstab | grep /mnt/user/docker_share)
        if [ -z "$FSTAB_TEST" ]; then
            echo "Adding /mnt/user/docker_share to /etc/fstab" >> $LOGFILE
            echo "10.0.0.177:/mnt/user/docker_share /srv nfs defaults 0 0" >> /etc/fstab
            echo "Added /mnt/user/docker_share to /etc/fstab" >> $LOGFILE
        fi
    fi
fi

echo "-------------------------------------------------------------------" >> $LOGFILE

ROOT_SCRIPTS=/root/scripts

if [ ! -d $ROOT_SCRIPTS ]; then
    echo "Creating $ROOT_SCRIPTS" >> $LOGFILE
    mkdir -p $ROOT_SCRIPTS
fi

NFSFIXER_SCRIPT=$ROOT_SCRIPTS/nfsfixer.sh

if [ -f $NFSFIXER_SCRIPT ]; then
    #echo "Removing $NFSFIXER_SCRIPT" >> $LOGFILE
    echo "$NFSFIXER_SCRIPT exists."
    #rm -f $NFSFIXER_SCRIPT
fi

if [ ! -f $NFSFIXER_SCRIPT ]; then
    echo "Creating $NFSFIXER_SCRIPT" >> $LOGFILE
cat << NFSFIXEREOF > $NFSFIXER_SCRIPT
#! /bin/bash

list=\$(mount | grep nfs)
while read -r line; do
    TARGET=\$(echo \$line | awk '{print \$1}')
    MOUNT=\$(echo \$line | awk '{print \$3}')
    STALE_TEST=\$(ls \$MOUNT |& grep "Stale file handle")
    if [ ! -z "\$STALE_TEST" ]; then
        umount -l \$MOUNT
        mount -t nfs \$TARGET \$MOUNT
    fi
done <<< "\$list"
NFSFIXEREOF
fi

cat << CRONTABEOF > /tmp/crontab.txt
# m h  dom mon dow   command
0 0-23 * * * docker system prune -a -f
0 0-23 * * * docker system prune --volumes -f
CRONTABEOF

if [ "$HOSTNAME" == "tp01-2066" ]; then
    echo "BEGIN: /tmp/crontab.txt for $HOSTNAME" >> $LOGFILE
    echo "@reboot sleep 60 && /root/mount_raid_array_restart_docker.sh" >> /tmp/crontab.txt
    echo "END!!! /tmp/crontab.txt for $HOSTNAME" >> $LOGFILE
fi

if [ -f $NFSFIXER_SCRIPT ]; then
    echo "BEGIN: $NFSFIXER_SCRIPT" >> $LOGFILE
    chmod +x $NFSFIXER_SCRIPT
    echo "0-59 0-23 * * * /root/scripts/nfsfixer.sh" >> /tmp/crontab.txt
    echo "END!!! $NFSFIXER_SCRIPT" >> $LOGFILE
fi

cat /tmp/crontab.txt | crontab -

MONGOCERTS=/srv/mongocerts

if [ ! -d $MONGOCERTS ]; then
    echo "Creating $MONGOCERTS" >> $LOGFILE
    mkdir -p $MONGOCERTS
fi

ISEMPTY_TEST2=-1
isEmpty $MONGOCERTS ISEMPTY_TEST2
echo "(***) ISEMPTY_TEST2 -> $ISEMPTY_TEST2" >> $LOGFILE

#if [ "$ISEMPTY_TEST2" == "False" ]; then
#    echo "Emptying $MONGOCERTS" >> $LOGFILE
#    rm -R -f $MONGOCERTS/*
#fi

cat << MONGOCERTSEOF > $MONGOCERTS/keyfile.txt
orCIxyoAfMv6ebOq3HUmoWJH//WGmR/YP68q4hrcTDSsUk8i898q2eYnk0Zyc8mQ
2ki6mzGpOg7ebFXntX82i4ggp05RN6G9dDbcM3iDeeFtUjVRxCMthOgVUYjDZyOk
o3B0ZWuccHi1UkTMyiHxomVz6pXsNGtUnD8ZnOBwyktYosuvTpYxraqbt7W6bBnD
EXHo/5WKgDTobbny1YbLpVKZ0WHyALj3Pv9xAQvb8jk+lUHgMWZifKkU+zD+DTHJ
AzNzpBRjSy50AXoe4Te0FXSPfmhQ2QJpyBIX73tkBCOkwAXpt2sXJH7r/KxnwoNI
uakk/50cE9Sf0uYIXYIVDYrOWY/mekeaPNUnYMrvVz5FvpHLwy1pvlZp7e7n8C2r
Bog2afYoZHv9hp3hd4vBABV82St3gj2VZyBLvnJSkP8OyKM/+JIrmY1v/R2oz4GD
Q6Sj3x1PxoSc+ctM/t1Ah23rgNpJjBnQwEOMpZt6kYWJTmba7lxR2QF71JMrX6Z1
vE7L5LFbHHnVE8/eZLrzNZGz05BD8AuwYFATIO3ST0i1GvjPkXzkJl0GyECxqRYg
gJx5MrH/7r/JpMPVUljxibbAQCt0rag+ZpFJIN/f1a7gd0J2yKgkPNBRZytkBN5l
h98vOQs6XwHy1KGAl/TJ704uyBACccIwovr//jEjUA4r79GqzE/fg90iyZQ63G1o
nzmt9apOyJA01UzIDcYeV7O1kzuBPMSif/emaXIub8xMBSnXp0fUTZn/RGZ3T7qH
njRUoSCc9RgQLbPBV2lFGAPk+PyktdvSlMQW3IbTmm8XPFFSqTAyfbsz6IKAvo37
WCSd1tC1ot627yL/GeTE30noP3DGdg+6ebsm2i3AG0Wg23uVtlO+mxbeGQHS7Ps6
aLESkzWB1o+xL6U/hH1iKIHsKJ1+AKqlGmmmtzBxYIzlSAQn6XtwkOUR6VrKJzDf
cM+63oqQgHs42mH/b/kNJbSIMOHqMF3yXTKVkTW4Rgu8u03KJFe8lNHGNZyqmmMj
MONGOCERTSEOF

if [ -f $MONGOCERTS/keyfile.txt ]; then
    echo "$MONGOCERTS/keyfile.txt exists" >> $LOGFILE
    #chmod 600 $MONGOCERTS/keyfile.txt
    #echo "END!!! $MONGOCERTS/keyfile.txt" >> $LOGFILE
fi

MONGOCERTS_VOLUME=$(docker volume ls | grep mongocerts | awk '{print $2}' | head -n 1)

if [ -z "$MONGOCERTS_VOLUME" ]; then
    echo "Creating $MONGOCERTS_VOLUME" >> $LOGFILE
    MONGOCERTS_VOLUME=mongocerts
    docker volume create -d local -o o=bind -o type=volume -o device=$MONGOCERTS --name $MONGOCERTS_VOLUME
fi

MONGOCERTS_VOLUME_DIR=$(docker volume inspect $MONGOCERTS_VOLUME | jq -r '.[0].Mountpoint')

if [ ! -d $MONGOCERTS_VOLUME_DIR ]; then
    echo "ERROR: $MONGOCERTS_VOLUME_DIR is missing." >> $LOGFILE
    #exit 1
fi

LOCAL_SRV_DIR=/srv
if [ "$HOSTNAME." == "tp01-2066." ]; then
    LOCAL_SRV_DIR=$(ls -la /srv | awk '{print $11}' | head -n 1)
fi

NUMAVAIL=$(df -h $LOCAL_SRV_DIR | awk '{print $4}' | tail -1 )

IS_LOCAL_SRV_AVAIL=$($PY -c "x='$NUMAVAIL';  xn=''.join([ch for ch in x if (str(ch).isdigit() or (ch == '.'))]); units=x.replace(xn, ''); xn=eval(xn); m=0.0 if (units not in ['M', 'G', 'T']) else (1/1000000) if (units == 'M') else (1/1000) if (units == 'G') else 1.0; print('1' if (xn*m) > 0.0001 else 0);")

echo "-------------------------------------------------------------------" >> $LOGFILE

echo "BEGIN: /srv" >> $LOGFILE
ls -la /srv >> $LOGFILE
echo "END!!! /srv" >> $LOGFILE

if [ "$IS_LOCAL_SRV_AVAIL" == "0" ]; then
    echo "WARNING: $LOCAL_SRV_DIR may be out of space." >> $LOGFILE
    #exit 1
fi
echo "-------------------------------------------------------------------" >> $LOGFILE

MONGODATA=/srv/mongodata
echo "BEGIN: MONGODATA: $MONGODATA" >> $LOGFILE
MONGODATA_VOLUME=$(docker volume ls | grep mongodata | awk '{print $2}' | head -n 1)

if [ -z "$MONGODATA_VOLUME" ]; then
    echo "Creating $MONGODATA_VOLUME" >> $LOGFILE
    if [ ! -d $MONGODATA ]; then
        echo "Creating $MONGODATA" >> $LOGFILE
        mkdir -p $MONGODATA
    fi
    MONGODATA_VOLUME=mongodata
    docker volume create -d local -o o=bind -o type=volume -o device=$MONGODATA --name $MONGODATA_VOLUME >> $LOGFILE
else
    echo "MONGODATA: $MONGODATA_VOLUME exists" >> $LOGFILE
fi
echo "END!!! MONGODATA: $MONGODATA" >> $LOGFILE

echo "-------------------------------------------------------------------" >> $LOGFILE

MONGOCONF=/srv/mongoconf
echo "BEGIN: MONGOCONF: $MONGOCONF" >> $LOGFILE
MONGOCONF_VOLUME=$(docker volume ls | grep mongoconf | awk '{print $2}' | head -n 1)

if [ -z "$MONGOCONF_VOLUME" ]; then
    echo "Creating $MONGOCONF_VOLUME" >> $LOGFILE
    if [ ! -d $MONGOCONF ]; then
        echo "Creating $MONGOCONF" >> $LOGFILE
        mkdir -p $MONGOCONF
    fi
    MONGOCONF_VOLUME=mongoconf
    docker volume create -d local -o o=bind -o type=volume -o device=$MONGOCONF --name $MONGOCONF_VOLUME >> $LOGFILE
else
    echo "MONGOCONF: $MONGOCONF_VOLUME exists" >> $LOGFILE
fi

MONGOCONF_VOLUME_DIR=$(docker volume inspect $MONGOCONF_VOLUME | jq -r '.[0].Mountpoint')

if [ ! -d $MONGOCONF_VOLUME_DIR ]; then
    echo "ERROR: $MONGOCONF_VOLUME_DIR is missing." >> $LOGFILE
else
    echo "$MONGOCONF_VOLUME_DIR exists" >> $LOGFILE
fi

cat << MONGOCONFEOF > $MONGOCONF/mongod.conf
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

if [ -f $MONGOCONF/mongod.conf ]; then
    echo "$MONGOCONF/mongod.conf exists" >> $LOGFILE
else
    echo "ERROR: $MONGOCONF/mongod.conf is missing." >> $LOGFILE

    if [ -f $MONGOCONF_VOLUME_DIR/mongod.conf ]; then
        echo "$MONGOCONF_VOLUME_DIR/mongod.conf exists" >> $LOGFILE
    else
        echo "ERROR: $MONGOCONF_VOLUME_DIR/mongod.conf is missing." >> $LOGFILE
    fi
fi
echo "END!!! $MONGOCONF" >> $LOGFILE

echo "-------------------------------------------------------------------" >> $LOGFILE

MONGOCONFIG=/srv/mongoconfigdb
echo "BEGIN: MONGOCONFIG: $MONGOCONFIG" >> $LOGFILE
MONGOCONFIG_VOLUME=$(docker volume ls | grep mongoconfigdb | awk '{print $2}' | head -n 1)

if [ -z "$MONGOCONFIG_VOLUME" ]; then
    echo "Creating $MONGOCONFIG_VOLUME" >> $LOGFILE
    if [ ! -d $MONGOCONFIG ]; then
        echo "Creating $MONGOCONFIG" >> $LOGFILE
        mkdir -p $MONGOCONFIG
    fi
    MONGOCONFIG_VOLUME=mongoconfigdb
    docker volume create -d local -o o=bind -o type=volume -o device=$MONGOCONFIG --name $MONGOCONFIG_VOLUME >> $LOGFILE
else
    echo "MONGOCONFIG: $MONGOCONFIG_VOLUME exists" >> $LOGFILE
fi
echo "END!!! MONGOCONFIG: $MONGOCONFIG" >> $LOGFILE

echo "-------------------------------------------------------------------" >> $LOGFILE

MONGOLOGS=/srv/mongologs
echo "(***) BEGIN: MONGOLOGS: $MONGOLOGS" >> $LOGFILE
MONGOLOGS_VOLUME=$(docker volume ls | grep mongologs | awk '{print $2}' | head -n 1)
echo "(***) MONGOLOGS_VOLUME: $MONGOLOGS_VOLUME" >> $LOGFILE

if [ -z "$MONGOLOGS_VOLUME" ]; then
    echo "Creating MONGOLOGS_VOLUME: $MONGOLOGS_VOLUME" >> $LOGFILE
    if [ ! -d $MONGOLOGS ]; then
        echo "Creating MONGOLOGS: $MONGOLOGS" >> $LOGFILE
        mkdir -p $MONGOLOGS
    fi
    MONGOCONFIG_VOLUME=mongologs
    docker volume create -d local -o o=bind -o type=volume -o device=$MONGOLOGS --name $MONGOLOGS_VOLUME >> $LOGFILE
else
    echo "MONGOLOGS: $MONGOLOGS_VOLUME exists" >> $LOGFILE
fi
echo "(***) END!!! MONGOLOGS: $MONGOLOGS" >> $LOGFILE

echo "-------------------------------------------------------------------" >> $LOGFILE

if [ "$HOSTNAME." != "tp01-2066." ]; then
    echo "BEGIN: /mnt" >> $LOGFILE
    ls -la /mnt >> $LOGFILE
    echo "END!!! /mnt" >> $LOGFILE
fi

echo "-------------------------------------------------------------------" >> $LOGFILE

echo "BEGIN: docker volume ls" >> $LOGFILE
docker volume ls >> $LOGFILE
echo "END!!! docker volume ls" >> $LOGFILE

echo "-------------------------------------------------------------------" >> $LOGFILE

echo "BEGIN: MONGOCERTS -> $MONGOCERTS -> $MONGOCERTS_VOLUME -> $MONGOCERTS_VOLUME_DIR" >> $LOGFILE
ls -la $MONGOCERTS >> $LOGFILE
echo "END!!! MONGOCERTS" >> $LOGFILE

echo "-------------------------------------------------------------------" >> $LOGFILE

echo "BEGIN: MONGODATA -> $MONGODATA -> $MONGODATA_VOLUME -> $MONGODATA_VOLUME_DIR" >> $LOGFILE
ls -la $MONGODATA >> $LOGFILE
echo "END!!! MONGODATA" >> $LOGFILE

echo "-------------------------------------------------------------------" >> $LOGFILE

echo "BEGIN: MONGOCONF -> $MONGOCONF -> $MONGOCONF_VOLUME -> $MONGOCONF_VOLUME_DIR" >> $LOGFILE
ls -la $MONGOCONF >> $LOGFILE
echo "END!!! MONGOCONF" >> $LOGFILE

echo "-------------------------------------------------------------------" >> $LOGFILE

echo "BEGIN: MONGOCONFIG -> $MONGOCONFIG -> $MONGOCONFIG_VOLUME -> $MONGOCONFIG_VOLUME_DIR" >> $LOGFILE
ls -la $MONGOCONFIG >> $LOGFILE
echo "END!!! MONGOCONFIG" >> $LOGFILE

echo "-------------------------------------------------------------------" >> $LOGFILE

echo "BEGIN: MONGOLOGS -> $MONGOLOGS -> $MONGOLOGS_VOLUME -> $MONGOLOGS_VOLUME_DIR" >> $LOGFILE
ls -la $MONGOLOGS >> $LOGFILE
echo "END!!! MONGOLOGS" >> $LOGFILE

echo "-------------------------------------------------------------------" >> $LOGFILE

echo "BEGIN: crontab -l" >> $LOGFILE
crontab -l >> $LOGFILE
echo "END!!! crontab -l" >> $LOGFILE

echo "Ansible job done." >> $LOGFILE
