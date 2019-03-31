
#!/bin/bash

# set startup volume
pactl set-sink-volume 0 25%

# set startup brightness
xrandr | grep connected | grep -v disconnected | while read -r line ; do
    # get device id
    device=$(echo $line | cut -f 1 -d ' ')
    if find /sys/ -type f -iname '*brightness*' 2>&1 | grep -v "Permission denied" | grep -q ${device%?};
    then
      # EXECUTION FOR INTERNAL DISPLAY
      xbacklight -set 50%
    else
      xrandr --output $device --brightness 0.50
    fi
done
