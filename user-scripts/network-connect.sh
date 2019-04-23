#!/bin/bash

while true; do
  read -p "
[s]how all wifi devices
[w]ifi connect
[l]ist devices
[c]onnect device
[d]isconnect device
[e]xit
" wa
  case $wa in
    [Ss]* ) nmcli d wifi list;;
    [Ww]* )
      nmcli d wifi list;
      while true; do
        read -p "Enter SSID   " ssid
        case $ssid in
          * )
            while true; do
              read -p "Enter password   " pw
              case $pw in
                * ) nmcli d wifi connect $ssid password $pw; break 2;;
              esac 
            done;;
        esac
      done;;
    [Ll]* ) nmcli d;;
    [Cc]* )
      while true; do
        nmcli d;
        read -p "Enter device   " d
        case $d in
          * ) nmcli d connect $d; break;;
        esac
      done;;
    [Dd]* )
      while true; do
        nmcli d;
        read -p "Enter device   " d
        case $d in
          * ) nmcli d disconnect $d; break;;
        esac
      done;;
    [Ee]* ) break;;
  esac
done
