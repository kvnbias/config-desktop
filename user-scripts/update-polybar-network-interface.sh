
#!/bin/bash


user=$(whoami)
ethernet=$(nmcli device | grep ethernet | grep -Eo '^[^ ]+')
wifi=$(nmcli device | grep wifi | grep -Eo '^[^ ]+')

sed -i ":a;N;\$!ba;s/\[module\/eth\]\ntype = internal\/network\ninterface = [a-zA-Z0-9]*/\[module\/eth\]\ntype = internal\/network\ninterface = ETHERNET/g" /home/$user/.config/polybar/config
sed -i ":a;N;\$!ba;s/\[module\/wlan\]\ntype = internal\/network\ninterface = [a-zA-Z0-9]*/\[module\/wlan\]\ntype = internal\/network\ninterface = WIFI/g" /home/$user/.config/polybar/config


sed -i "s/interface = ETHERNET/interface = $ethernet/g" /home/$user/.config/polybar/config
sed -i "s/interface = WIFI/interface = $wifi/g" /home/$user/.config/polybar/config
