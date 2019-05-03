
#!/bin/bash

# Make sure other notification service exists to give way to dunst
if [ -f /usr/share/dbus-1/services/org.freedesktop.Notifications.service ]; then
  sudo rm /usr/share/dbus-1/services/org.freedesktop.Notifications.service
fi

if [ -f /usr/share/dbus-1/services/org.xfce.xfce4-notifyd.Notifications.service ]; then
  sudo rm /usr/share/dbus-1/services/org.xfce.xfce4-notifyd.Notifications.service
fi
