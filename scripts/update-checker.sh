#!/bin/sh
os=$(echo -n $(cat /etc/*-release | grep ^ID= | sed -e "s/ID=//"))
updates=0

if [ "$os" = "arch" ]; then
  if ! updates_arch=$(checkupdates 2> /dev/null | wc -l ); then
    updates_arch=0
  fi

  if ! updates_aur=$(yay -Qum 2> /dev/null | wc -l); then
    updates_aur=0
  fi

  updates=$(("$updates_arch" + "$updates_aur"))
fi

if [ "$os" = "fedora" ]; then
  dnf=$(sudo dnf upgrade --refresh --assumeno 2> /dev/null)

  upgrade=$(echo "$dnf" | grep '^Upgrade ' | awk '{ print $2 }')

  install=$(echo "$dnf" | grep '^Install ' | awk '{ print $2 }')

updates=$(( upgrade + install ))
fi

if [ "$updates" -gt 0 ]; then
  echo " $updates"
else 
  echo ""
fi
