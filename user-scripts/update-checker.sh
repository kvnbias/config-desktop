
#!/bin/sh
os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//"))
updates=0

if [ -f /usr/bin/pacman ]; then
  manexec=$(ps aux | grep "checkupdates" 2> /dev/null | wc -l)
  if [ "$manexec" -lt 2 ]; then
    if ! updates_arch=$(checkupdates 2> /dev/null | wc -l ); then
      updates_arch=0
    fi

    if ! updates_aur=$(yay -Qum 2> /dev/null | wc -l); then
      updates_aur=0
    fi

    updates=$(("$updates_arch" + "$updates_aur"))
  fi

elif [ -f /usr/bin/dnf ]; then
  manexec=$(ps aux | grep "dnf upgrade" 2> /dev/null | wc -l)
  if [ "$manexec" -lt 2 ]; then
    dnf=$(sudo dnf upgrade --refresh --assumeno 2> /dev/null)

    upgrade=$(echo "$dnf" | grep '^Upgrade ' | awk '{ print $2 }')
    install=$(echo "$dnf" | grep '^Install ' | awk '{ print $2 }')

    updates=$(( upgrade + install ))
  fi

elif [ -f /usr/bin/zypper ]; then
  manexec=$(ps aux | grep "zypper refresh" 2> /dev/null | wc -l)
  if [ "$manexec" -lt 2 ]; then
    refresh=$(sudo zypper refresh > /dev/null)
    updates=$(sudo zypper list-updates | grep -v "+-" | grep -v "Available Version" | grep -v "\.\.\." | grep -v "No updates found." | wc -l 2> /dev/null);

    if echo "$updates" | grep "No updates found."; then
      updates=0
    fi
  fi

elif [ -f /usr/bin/emerge ]; then
  manexec=$(ps aux | grep "emerge --pretend" 2> /dev/null | wc -l)
  if [ "$manexec" -lt 2 ]; then
    lastdate=$(date -f  /usr/portage/metadata/timestamp.chk +%j)
    currdate=$(date +%j)
    diffdate=$(( currdate - lastdate ))

    if [ "$diffdate" -gt 2 ]; then
      $(sudo emerge --sync > /dev/null)
    fi

    updates=$(sudo emerge --pretend --verbose --update --deep --newuse @world 2> /dev/null | grep "\[ebuild.*\]" | sed -e "s/\[ebuild.*/\[ebuild/g" |  wc -l)
  fi

elif [ -f /usr/bin/apt ]; then
  manexec=$(ps aux | grep "apt update" 2> /dev/null | wc -l)
  if [ "$manexec" -lt 2 ]; then
    apt=$(sudo apt update 2> /dev/null)

    updates=0
    if echo "$apt" | grep -q "upgraded"; then
      updates=$(echo "$apt" | grep 'upgraded' | awk '{ print $1 }')
    fi
  fi

fi

if [ "$updates" -gt 0 ]; then
  echo " $updates"
else 
  echo ""
fi
