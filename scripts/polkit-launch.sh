
os=$(echo -n $(cat /etc/*-release | grep ^ID= | sed -e "s/ID=//"))

if [ "$os" = "arch" ]; then
  /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
fi

if [ "$os" = "fedora" ]; then
  /usr/libexec/polkit-gnome-authentication-agent-1 &
fi
