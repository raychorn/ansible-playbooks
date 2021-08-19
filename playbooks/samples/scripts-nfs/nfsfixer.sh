#! /bin/bash

list=$(mount | grep nfs)
while read -r line; do
    TARGET=$(echo $line | awk '{print $1}')
    MOUNT=$(echo $line | awk '{print $3}')
    STALE_TEST=$(ls $MOUNT |& grep "Stale file handle")
    if [ ! -z "$STALE_TEST" ]; then
        #echo "$MOUNT -> $TARGET -> $STALE_TEST"
        umount -l $MOUNT
        mount -t nfs $TARGET $MOUNT
    fi
done <<< "$list"

#echo "Done."