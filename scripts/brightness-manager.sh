
#!/bin/bash
# ~/config/display/brightness-manager.sh

boost=$1
notifsent=false

icon="/home/$user/.config/display/noicon";

# get connected monitors
xrandr | grep connected | grep -v disconnected | while read -r line ; do
  # get device id
  device=$(echo $line | cut -f 1 -d ' ')

  if find /sys/ -type f -iname '*brightness*' 2>&1 | grep -v "Permission denied" | grep -q ${device%?};
  then
    # EXECUTION FOR INTERNAL DISPLAY
    currbright=$(xbacklight)
    multboost=$(bc -l <<<"$boost*100")
    nextbright=$(bc -l <<<"$currbright + $multboost")

    xbacklight -set $(bc -l <<<"$nextbright")

    if [ "$notifsent" = false ]; then
      notifbright=$(xbacklight)
      notifbright=$(printf "%.0f\n" "$notifbright")

      if [ "$notifbright" -ge 99 ];then
        notifbright=100
      fi

      notify-send -i $icon -t 1000 "Brightness" "Brightness adjusted to $notifbright%";
      notifsent=true
    fi
  else
    # EXECUTION FOR EXTERNAL DISPLAY

    # check if there are displays that are not on 100% brightness
    # if none bump/reduce it anyway. if there is, exclude the 100%
    # and get the lower value.
    #
    # why check if there are displays not in 100% brightness?
    #
    # internal displays only shrinks the hardware brightness and
    # leave the software brightness to 1.0 unless the user sets it.
    # 
    # to get the external monitor's current brightness, the exclusion
    # of the internal display is a must, this script assumes you are
    # giving all displays the same value.
    if xrandr --verbose | grep -v "Brightness: 1.0" | grep -i brightness;
    then
      currbright=$(xrandr --verbose | grep -v "Brightness: 1.0" | grep -i brightness | cut -f2 -d ' ')
    else
      currbright=1.0
    fi

    nextbright=$(bc -l <<<"$currbright + $boost")

    if [ $(bc -l <<<"$nextbright > 1.0") == 1 ];
    then
      # prevent over brightness
      nextbright="1.0"
    fi
    
    if [ $(bc -l <<<"$nextbright < 0.0") == 1 ];
    then
      # prevent over brightness
      nextbright="0.0"
    fi

    if [ "$notifsent" = false ]; then
      notifbright=$(bc -l <<<"$nextbright*100")
      notifbright=${notifbright%.*}
      notify-send -i $icon -t 1000  "Brightness" "Brightness adjusted to $notifbright%";
      notifsent=true
    fi

    xrandr --output $device --brightness $nextbright
  fi

done


