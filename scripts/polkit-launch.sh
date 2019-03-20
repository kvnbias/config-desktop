
os=$(echo -n $(cat /etc/*-release | grep ^ID= | sed -e "s/ID=//"))

if [ -f /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 ]; then
  /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
elif [ -f /usr/libexec/polkit-gnome-authentication-agent-1 ]; then
  /usr/libexec/polkit-gnome-authentication-agent-1 &
else
  echo "No polkit initialized."
fi

