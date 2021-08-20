#!/bin/bash

fbname=$(basename "$0" | cut -d. -f1)

LOGFILE=/tmp/$fbname.log
PYFILE=/tmp/$fbname.py

DNS=10.0.0.196

if [ -f "$LOGFILE" ]; then
    rm -f $LOGFILE
fi

touch $LOGFILE
touch $PYFILE

#apt-get update -y >> $LOGFILE
#apt-get upgrade -y >> $LOGFILE

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

echo "BEGIN: /srv" >> $LOGFILE
ls -la /srv >> $LOGFILE
echo "END!!! /srv" >> $LOGFILE

echo "-------------------------------------------------------------------" >> $LOGFILE

echo "BEGIN: /mnt" >> $LOGFILE
ls -la /mnt >> $LOGFILE
echo "END!!! /mnt" >> $LOGFILE

echo "====================================================================" >> $LOGFILE

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

echo "-------------------------------------------------------------------" >> $LOGFILE

echo "BEGIN: crontab -l" >> $LOGFILE
crontab -l >> $LOGFILE
echo "END!!! crontab -l" >> $LOGFILE

exit

DOMAIN=docker1.web-service.org
TEST=$(ping $DOMAIN -c 3 | grep "3 received" | grep "0% packet loss")
if [ -z "$TEST" ]; then
    echo "ERROR: $DOMAIN not found so cannot continue." >> $LOGFILE
    exit 1
fi
echo "$DOMAIN=$TEST" >> $LOGFILE

DOMAIN=docker2.web-service.org
TEST=$(ping $DOMAIN -c 3 | grep "3 received" | grep "0% packet loss")
if [ -z "$TEST" ]; then
    echo "ERROR: $DOMAIN not found so cannot continue." >> $LOGFILE
    exit 1
fi
echo "$DOMAIN=$TEST" >> $LOGFILE

DOMAIN=docker1-10.web-service.org
TEST=$(ping $DOMAIN -c 3 | grep "3 received" | grep "0% packet loss")
if [ -z "$TEST" ]; then
    echo "ERROR: $DOMAIN not found so cannot continue." >> $LOGFILE
    exit 1
fi

DOMAIN=docker2-10.web-service.org
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

DOMAIN=tower.web-service.org
TEST=$(ping $DOMAIN -c 3 | grep "3 received" | grep "0% packet loss")
if [ -z "$TEST" ]; then
    echo "ERROR: $DOMAIN not found so cannot continue." >> $LOGFILE
    exit 1
fi

DOMAIN=z820.web-service.org
TEST=$(ping $DOMAIN -c 3 | grep "3 received" | grep "0% packet loss")
if [ -z "$TEST" ]; then
    echo "ERROR: $DOMAIN not found so cannot continue." >> $LOGFILE
    exit 1
fi

echo "All tests passed." >> $LOGFILE
