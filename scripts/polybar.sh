
#!/bin/bash
# ~/.i3/polybar.sh

# this script your display are aligned left to right
# only the main monitor (first) will render the tray
killall -q polybar

while pgrep -u $UID -x polybar > /dev/null; do sleep 0.5; done

if type "xrandr"; then

  trayrendered=true
  xrandr | grep connected | grep -v disconnected | while read -r line; do
  echo $line

    device=$(echo $line | cut -f 1 -d ' ')
    if $trayrendered == true;
    then
      trayrendered=false
      MONITOR=$device polybar --reload kev &
    else
      MONITOR=$device polybar --reload sub &
    fi

  done
else
  polybar --reload kev &
fi
