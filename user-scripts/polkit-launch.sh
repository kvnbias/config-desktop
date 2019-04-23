
os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//"))

if [ -f /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 ]; then
  /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
elif [ -f /usr/libexec/polkit-gnome-authentication-agent-1 ]; then
  /usr/libexec/polkit-gnome-authentication-agent-1 &
elif [ -f /usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 ]; then
  /usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &
elif [ -f /usr/lib/polkit-gnome-authentication-agent-1 ]; then
  /usr/lib/polkit-gnome-authentication-agent-1 &
else
  echo "No polkit initialized."
fi

