#!/bin/bash

KEYFILE=~/.ssh/id_rsa_desktop-JJ95ENL_no_passphrase

echo "(1)"
ssh-add $KEYFILE &>/dev/null
if [ "$?" == 2 ]; then
  echo "(2)"
  test -r ~/.ssh-agent && \
    eval "$(<~/.ssh-agent)" >/dev/null

  ssh-add $KEYFILE &>/dev/null
  if [ "$?" == 2 ]; then
    echo "(3)"
    (umask 066; ssh-agent > ~/.ssh-agent)
    eval "$(<~/.ssh-agent)" >/dev/null
    ssh-add $KEYFILE &>/dev/null
  fi
fi
echo "Done."
