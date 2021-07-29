#!/bin/bash

DNSFILE=/srv/__projects/portainer-ce/docker/pi-hole/etc-pihole/custom.list

if [ -f $DNSFILE ]; then
    echo "DNS file found"
else
    echo "DNS file not found so cannot continue."
    exit 1
fi

STUFF=$(ansible-playbook /srv/__projects/ansible-playbooks/playbooks/samples/query_endpoints.yml | grep .web-service.org)

echo "STUFF=$STUFF"

echo "$(hostname -i) $(hostname)" > $DNSFILE
IFS='
'
count=0
for item in $STUFF
do
  count=$((count+1))
  echo $item | xargs >> $DNSFILE
done

CID=$(docker ps -qf "name=pihole")

if [ -z $CID ]; then
    echo "Container not found so cannot continue."
    exit 1
fi

echo "CID=$CID"
docker exec -it $CID /usr/local/bin/pihole restartdns
